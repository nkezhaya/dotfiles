import { readFile } from "node:fs/promises";
import { complete, type UserMessage } from "@mariozechner/pi-ai";
import { BorderedLoader } from "@mariozechner/pi-coding-agent";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";

type TargetKind = "pr" | "issue";

interface ActiveTarget {
	kind: TargetKind;
	number: number;
}

interface GithubState {
	activeTarget?: ActiveTarget;
}

interface RepoRef {
	owner: string;
	repo: string;
	nameWithOwner: string;
}

interface ReviewComment {
	id: string;
	databaseId: number;
	body: string;
	author: { login: string } | null;
	createdAt: string;
	url: string;
	diffHunk?: string;
	path?: string;
	line?: number | null;
}

interface ReviewThread {
	id: string;
	isResolved: boolean;
	isOutdated: boolean;
	viewerCanReply: boolean;
	viewerCanResolve: boolean;
	path?: string | null;
	line?: number | null;
	originalLine?: number | null;
	comments: { nodes: ReviewComment[] };
}

interface PullRequestData {
	id: string;
	number: number;
	title: string;
	body: string;
	url: string;
	author: { login: string } | null;
	reviewDecision?: string | null;
}

interface IssueComment {
	author: { login: string } | null;
	body: string;
	createdAt: string;
	url: string;
}

interface IssueData {
	number: number;
	title: string;
	body: string;
	url: string;
	state: string;
	author: { login: string } | null;
	comments: IssueComment[];
}

const DRAFT_SYSTEM_PROMPT = `You draft GitHub pull request review replies.

Goals:
- Write a reply to the selected review thread comment.
- Sound like the user's natural technical voice when a voice guide is provided.
- Be direct, concise, and grounded in the thread context.
- Do not be overly enthusiastic, corporate, or verbose.
- Do not include markdown code fences unless they are clearly needed.
- Output only the reply body text, with no preamble and no surrounding quotes.
- Do not claim changes were made unless the context says they were made.
- If the best reply is a short acknowledgment plus a concrete action, do that.
- If the right response is to explain a tradeoff, do that plainly.
`;

function defaultState(): GithubState {
	return {};
}

function truncate(text: string, max = 12_000): string {
	if (text.length <= max) return text;
	return `${text.slice(0, max)}\n\n[truncated ${text.length - max} chars]`;
}

function summarizeText(text: string, max = 120): string {
	const single = text.replace(/\s+/g, " ").trim();
	if (single.length <= max) return single;
	return `${single.slice(0, max - 1)}…`;
}

function restoreState(ctx: ExtensionContext): GithubState {
	let state = defaultState();
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type === "custom" && entry.customType === "github-helper-state") {
			const data = entry.data as GithubState | undefined;
			if (data) state = data;
		}
	}
	return state;
}

export default function githubHelper(pi: ExtensionAPI) {
	let state = defaultState();

	function persistState() {
		pi.appendEntry<GithubState>("github-helper-state", state);
	}

	function syncStatus(ctx: ExtensionContext) {
		if (!ctx.hasUI) return;
		if (!state.activeTarget) {
			ctx.ui.setStatus("github-helper", undefined);
			return;
		}
		ctx.ui.setStatus("github-helper", `gh:${state.activeTarget.kind}#${state.activeTarget.number}`);
	}

	async function runGh(args: string[], ctx: ExtensionContext): Promise<string> {
		const result = await pi.exec("gh", args, {});
		if (result.code !== 0) {
			throw new Error((result.stderr || result.stdout || `gh ${args.join(" ")} failed`).trim());
		}
		return result.stdout.trim();
	}

	async function runGhJson<T>(args: string[], ctx: ExtensionContext): Promise<T> {
		const output = await runGh(args, ctx);
		return JSON.parse(output) as T;
	}

	async function getRepo(ctx: ExtensionContext): Promise<RepoRef> {
		const repo = await runGhJson<{ owner: { login: string }; name: string; nameWithOwner: string }>(
			["repo", "view", "--json", "owner,name,nameWithOwner"],
			ctx,
		);
		return { owner: repo.owner.login, repo: repo.name, nameWithOwner: repo.nameWithOwner };
	}

	async function resolvePrNumberFromCurrentBranch(ctx: ExtensionContext): Promise<number> {
		const pr = await runGhJson<{ number: number }>(["pr", "view", "--json", "number"], ctx);
		return pr.number;
	}

	async function getPrData(number: number, ctx: ExtensionContext): Promise<PullRequestData> {
		return await runGhJson<PullRequestData>(
			["pr", "view", String(number), "--json", "id,number,title,body,url,author,reviewDecision"],
			ctx,
		);
	}

	async function getIssueData(number: number, ctx: ExtensionContext): Promise<IssueData> {
		return await runGhJson<IssueData>(
			["issue", "view", String(number), "--json", "number,title,body,url,state,author,comments"],
			ctx,
		);
	}

	async function getReviewThreads(number: number, ctx: ExtensionContext): Promise<{ pr: PullRequestData; threads: ReviewThread[] }> {
		const repo = await getRepo(ctx);
		const query = `query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      id
      number
      title
      body
      url
      reviewDecision
      author { login }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          viewerCanReply
          viewerCanResolve
          path
          line
          originalLine
          comments(first: 100) {
            nodes {
              id
              databaseId
              body
              createdAt
              url
              diffHunk
              path
              line
              author { login }
            }
          }
        }
      }
    }
  }
}`;
		const data = await runGhJson<{ data: { repository: { pullRequest: PullRequestData & { reviewThreads: { nodes: ReviewThread[] } } | null } | null } }>(
			[
				"api",
				"graphql",
				"-f",
				`query=${query}`,
				"-F",
				`owner=${repo.owner}`,
				"-F",
				`repo=${repo.repo}`,
				"-F",
				`number=${number}`,
			],
			ctx,
		);
		const pr = data.data.repository?.pullRequest;
		if (!pr) throw new Error(`PR #${number} not found in ${repo.nameWithOwner}`);
		return { pr, threads: pr.reviewThreads.nodes };
	}

	function formatThreadOption(thread: ReviewThread, index: number): string {
		const first = thread.comments.nodes[0];
		const last = thread.comments.nodes[thread.comments.nodes.length - 1] ?? first;
		const location = thread.path ? `${thread.path}:${thread.line ?? thread.originalLine ?? "?"}` : "unknown";
		const status = thread.isOutdated ? "outdated" : thread.isResolved ? "resolved" : "open";
		const author = first?.author?.login ?? "unknown";
		const summary = summarizeText(last?.body ?? first?.body ?? "", 90);
		return `${index + 1}. [${status}] ${location} — ${author}: ${summary}`;
	}

	function buildIssueContext(issue: IssueData): string {
		const header = `GitHub issue #${issue.number}: ${issue.title}\nURL: ${issue.url}\nState: ${issue.state}\nAuthor: ${issue.author?.login ?? "unknown"}`;
		const body = issue.body ? `\n\nBody:\n${issue.body}` : "\n\nBody: (empty)";
		const comments = issue.comments.length
			? `\n\nComments:\n${issue.comments
				.map(
					(comment, index) =>
						`[${index + 1}] ${comment.author?.login ?? "unknown"} at ${comment.createdAt}\n${comment.body}`,
				)
				.join("\n\n---\n\n")}`
			: "\n\nComments: none";
		return truncate(`${header}${body}${comments}`);
	}

	function buildPrContext(pr: PullRequestData, threads: ReviewThread[]): string {
		const openThreads = threads.filter((thread) => !thread.isResolved);
		const header = `GitHub pull request #${pr.number}: ${pr.title}\nURL: ${pr.url}\nAuthor: ${pr.author?.login ?? "unknown"}\nReview decision: ${pr.reviewDecision ?? "none"}\nOpen review threads: ${openThreads.length}`;
		const body = pr.body ? `\n\nBody:\n${pr.body}` : "\n\nBody: (empty)";
		const threadSummary = openThreads.length
			? `\n\nOpen review threads:\n${openThreads
				.map((thread, index) => {
					const first = thread.comments.nodes[0];
					const location = thread.path ? `${thread.path}:${thread.line ?? thread.originalLine ?? "?"}` : "unknown";
					return `[${index + 1}] ${location} — ${first?.author?.login ?? "unknown"}: ${summarizeText(first?.body ?? "", 140)}`;
				})
				.join("\n")}`
			: "\n\nOpen review threads: none";
		return truncate(`${header}${body}${threadSummary}`);
	}

	function buildDraftPrompt(pr: PullRequestData, thread: ReviewThread, voice: string | undefined): string {
		const comments = thread.comments.nodes
			.map(
				(comment, index) =>
					`[${index + 1}] ${comment.author?.login ?? "unknown"} at ${comment.createdAt}\n${comment.body}`,
			)
			.join("\n\n---\n\n");
		const location = thread.path ? `${thread.path}:${thread.line ?? thread.originalLine ?? "?"}` : "unknown";
		const diffHunk = thread.comments.nodes.find((comment) => comment.diffHunk)?.diffHunk;
		return [
			voice ? `User voice guide:\n${voice}` : undefined,
			`Draft a GitHub PR review reply for this thread. Reply only to the review feedback shown here.`,
			`PR #${pr.number}: ${pr.title}`,
			`PR URL: ${pr.url}`,
			`Thread location: ${location}`,
			thread.isOutdated ? `Thread status: outdated` : undefined,
			diffHunk ? `Diff hunk:\n${diffHunk}` : undefined,
			`Thread comments:\n${comments}`,
			"Return only the reply body text. Keep it natural and concise.",
		]
			.filter(Boolean)
			.join("\n\n");
	}

	async function readVoiceGuide(ctx: ExtensionContext): Promise<string | undefined> {
		const candidates = [
			`${ctx.cwd}/.pi/agent/VOICE.md`,
			`${ctx.cwd}/VOICE.md`,
			`${ctx.cwd}/PR_STYLE.md`,
		];
		for (const path of candidates) {
			try {
				const text = await readFile(path, "utf8");
				const trimmed = text.trim();
				if (trimmed) return truncate(trimmed, 8_000);
			} catch {
				// ignore missing files
			}
		}
		return undefined;
	}

	async function generateDraft(prompt: string, ctx: ExtensionContext): Promise<string> {
		if (!ctx.model) throw new Error("No model selected");
		const apiKey = await ctx.modelRegistry.getApiKey(ctx.model);
		if (!apiKey) throw new Error(`No API key available for ${ctx.model.provider}/${ctx.model.id}`);
		const userMessage: UserMessage = {
			role: "user",
			content: [{ type: "text", text: prompt }],
			timestamp: Date.now(),
		};
		const response = await complete(ctx.model, { systemPrompt: DRAFT_SYSTEM_PROMPT, messages: [userMessage] }, { apiKey });
		const text = response.content
			.filter((part): part is { type: "text"; text: string } => part.type === "text")
			.map((part) => part.text)
			.join("\n")
			.trim();
		if (!text) throw new Error("Model returned an empty draft");
		return text;
	}

	async function postThreadReply(threadId: string, body: string, ctx: ExtensionContext): Promise<void> {
		const mutation = `mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: { pullRequestReviewThreadId: $threadId, body: $body }) {
    comment { id url }
  }
}`;
		await runGhJson(
			["api", "graphql", "-f", `query=${mutation}`, "-F", `threadId=${threadId}`, "-F", `body=${body}`],
			ctx,
		);
	}

	async function resolveThread(threadId: string, ctx: ExtensionContext): Promise<void> {
		const mutation = `mutation($threadId: ID!) {
  resolveReviewThread(input: { threadId: $threadId }) {
    thread { id isResolved }
  }
}`;
		await runGhJson(["api", "graphql", "-f", `query=${mutation}`, "-F", `threadId=${threadId}`], ctx);
	}

	pi.on("session_start", async (_event, ctx) => {
		state = restoreState(ctx);
		syncStatus(ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		state = restoreState(ctx);
		syncStatus(ctx);
	});

	pi.on("session_fork", async (_event, ctx) => {
		state = restoreState(ctx);
		syncStatus(ctx);
	});

	pi.registerCommand("gh", {
		description: "GitHub helper: /gh pr [number], /gh issue <number>, /gh context, /gh reply, /gh status, /gh clear",
		handler: async (args, ctx) => {
			const [subcommandRaw, ...rest] = args.trim().split(/\s+/).filter(Boolean);
			const subcommand = subcommandRaw?.toLowerCase();

			if (!subcommand) {
				ctx.ui.notify("Usage: /gh pr [number] | issue <number> | context | reply | status | clear", "info");
				return;
			}

			if (subcommand === "status") {
				if (!state.activeTarget) {
					ctx.ui.notify("No active GitHub target", "info");
					return;
				}
				ctx.ui.notify(`Active target: ${state.activeTarget.kind}#${state.activeTarget.number}`, "info");
				return;
			}

			if (subcommand === "clear") {
				state = {};
				persistState();
				syncStatus(ctx);
				ctx.ui.notify("Cleared active GitHub target", "info");
				return;
			}

			if (subcommand === "pr") {
				const number = rest[0] ? Number(rest[0]) : await resolvePrNumberFromCurrentBranch(ctx);
				if (!Number.isInteger(number) || number <= 0) {
					ctx.ui.notify("Usage: /gh pr [number]", "warning");
					return;
				}
				const pr = await getPrData(number, ctx);
				state = { activeTarget: { kind: "pr", number } };
				persistState();
				syncStatus(ctx);
				ctx.ui.notify(`Active PR set to #${pr.number}: ${pr.title}`, "info");
				return;
			}

			if (subcommand === "issue") {
				const number = Number(rest[0]);
				if (!Number.isInteger(number) || number <= 0) {
					ctx.ui.notify("Usage: /gh issue <number>", "warning");
					return;
				}
				const issue = await getIssueData(number, ctx);
				state = { activeTarget: { kind: "issue", number } };
				persistState();
				syncStatus(ctx);
				ctx.ui.notify(`Active issue set to #${issue.number}: ${issue.title}`, "info");
				return;
			}

			if (subcommand === "context") {
				if (!state.activeTarget) {
					ctx.ui.notify("Set an active target first with /gh pr [number] or /gh issue <number>", "warning");
					return;
				}
				if (state.activeTarget.kind === "issue") {
					const issue = await getIssueData(state.activeTarget.number, ctx);
					pi.sendMessage(
						{ customType: "github-context", content: buildIssueContext(issue), display: true },
						{ triggerTurn: false },
					);
					ctx.ui.notify(`Loaded issue #${issue.number} context into the session`, "info");
					return;
				}
				const { pr, threads } = await getReviewThreads(state.activeTarget.number, ctx);
				pi.sendMessage(
					{ customType: "github-context", content: buildPrContext(pr, threads), display: true },
					{ triggerTurn: false },
				);
				ctx.ui.notify(`Loaded PR #${pr.number} context into the session`, "info");
				return;
			}

			if (subcommand === "reply") {
				if (!state.activeTarget || state.activeTarget.kind !== "pr") {
					ctx.ui.notify("Set an active PR first with /gh pr [number]", "warning");
					return;
				}
				const { pr, threads } = await getReviewThreads(state.activeTarget.number, ctx);
				const openThreads = threads.filter((thread) => !thread.isResolved && thread.viewerCanReply && thread.comments.nodes.length > 0);
				if (!openThreads.length) {
					ctx.ui.notify(`No unresolved replyable review threads found on PR #${pr.number}`, "info");
					return;
				}

				const options = openThreads.map((thread, index) => formatThreadOption(thread, index));
				const selected = await ctx.ui.select(`Select a review thread from PR #${pr.number}`, options);
				if (!selected) return;
				const selectedIndex = options.indexOf(selected);
				const thread = openThreads[selectedIndex];
				if (!thread) {
					ctx.ui.notify("Could not resolve selected thread", "error");
					return;
				}

				const voiceGuide = await readVoiceGuide(ctx);
				const prompt = buildDraftPrompt(pr, thread, voiceGuide);
				const draft = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
					const loader = new BorderedLoader(tui, theme, `Drafting GitHub reply with ${ctx.model?.id ?? "current model"}...`);
					loader.onAbort = () => done(null);
					generateDraft(prompt, ctx)
						.then(done)
						.catch((error) => done(`__ERROR__${error instanceof Error ? error.message : String(error)}`));
					return loader;
				});

				if (!draft) return;
				if (draft.startsWith("__ERROR__")) {
					ctx.ui.notify(draft.replace(/^__ERROR__/, ""), "error");
					return;
				}

				let finalBody = draft.trim();
				const action = await ctx.ui.select(
					`Draft reply:\n\n${truncate(finalBody, 3000)}`,
					["Post", "Edit then post", "Cancel"],
				);
				if (!action || action === "Cancel") return;

				if (action === "Edit then post") {
					const edited = await ctx.ui.editor("Edit reply", finalBody);
					if (!edited?.trim()) {
						ctx.ui.notify("Reply was empty; cancelled", "warning");
						return;
					}
					finalBody = edited.trim();
					const confirmEdited = await ctx.ui.confirm("Post reply?", truncate(finalBody, 2000));
					if (!confirmEdited) return;
				}

				await postThreadReply(thread.id, finalBody, ctx);
				ctx.ui.notify("Posted review reply", "info");

				if (thread.viewerCanResolve) {
					const shouldResolve = await ctx.ui.confirm("Resolve thread?", "Mark this review thread as resolved?");
					if (shouldResolve) {
						await resolveThread(thread.id, ctx);
						ctx.ui.notify("Resolved review thread", "info");
					}
				}
				return;
			}

			ctx.ui.notify("Unknown subcommand. Use: pr, issue, context, reply, status, clear", "warning");
		},
	});

	pi.registerMessageRenderer("github-context", (message, options, theme) => {
		const text = String(message.content ?? "");
		const rendered = options.expanded ? text : truncate(text, 1200);
		return new Text(`${theme.fg("accent", "[github-context]")}\n\n${rendered}`, 0, 0);
	});
}
