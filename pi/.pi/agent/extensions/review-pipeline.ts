import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type ReviewScope = "base" | "local" | "unstaged" | "custom";
type ReviewMode = "review_only" | "review_then_ask_before_fix" | "implement_review_fix_automatically";

interface ScopeSelection {
	scope: ReviewScope;
	baseBranch?: string;
	customInstructions?: string;
}

function parseLines(text: string): string[] {
	return text
		.split("\n")
		.map((line) => line.trim())
		.filter(Boolean)
		.filter((line) => !line.startsWith("#"));
}

function unique<T>(items: T[]): T[] {
	return Array.from(new Set(items));
}

function sanitizeForSlashTask(text: string): string {
	return text.replace(/\s->\s/g, " → ").replace(/\s--\s/g, " — ").trim();
}

export default function reviewPipeline(pi: ExtensionAPI) {
	async function run(command: string, args: string[], timeout?: number) {
		const result = await pi.exec(command, args, timeout ? { timeout } : {});
		if (result.code !== 0) {
			throw new Error((result.stderr || result.stdout || `${command} failed`).trim());
		}
		return result.stdout.trim();
	}

	async function chooseMode(ctx: Parameters<Parameters<typeof pi.registerCommand>[1]["handler"]>[1]): Promise<ReviewMode | null> {
		const selected = await ctx.ui.select("Review mode", [
			"1. Review only",
			"2. Review, then ask before fixing",
			"3. Implement/review/fix automatically",
		]);
		if (!selected) return null;
		if (selected.startsWith("1.")) return "review_only";
		if (selected.startsWith("2.")) return "review_then_ask_before_fix";
		return "implement_review_fix_automatically";
	}

	async function chooseScope(ctx: Parameters<Parameters<typeof pi.registerCommand>[1]["handler"]>[1]): Promise<ScopeSelection | null> {
		const selected = await ctx.ui.select("File scope / context", [
			"1. Review against base branch",
			"2. Review local changes",
			"3. Review unstaged changes only",
			"4. Custom/manual",
		]);
		if (!selected) return null;
		if (selected.startsWith("1.")) {
			const baseBranch = await ctx.ui.input("Base branch", "main");
			if (!baseBranch?.trim()) return null;
			return { scope: "base", baseBranch: baseBranch.trim() };
		}
		if (selected.startsWith("2.")) return { scope: "local" };
		if (selected.startsWith("3.")) return { scope: "unstaged" };
		const customInstructions = await ctx.ui.editor(
			"Custom/manual context",
			"Optional notes about what to focus on, constraints, or files to consider:\n",
		);
		return { scope: "custom", customInstructions: customInstructions?.trim() || undefined };
	}

	async function getBaseBranchFiles(baseBranch: string): Promise<string[]> {
		return parseLines(await run("git", ["diff", "--name-only", `${baseBranch}...HEAD`]));
	}

	async function getLocalChangedFiles(): Promise<string[]> {
		const tracked = parseLines(await run("git", ["diff", "--name-only", "HEAD"]));
		const untracked = parseLines(await run("git", ["ls-files", "--others", "--exclude-standard"]));
		return unique([...tracked, ...untracked]);
	}

	async function getUnstagedFiles(): Promise<string[]> {
		const unstaged = parseLines(await run("git", ["diff", "--name-only"]));
		const untracked = parseLines(await run("git", ["ls-files", "--others", "--exclude-standard"]));
		return unique([...unstaged, ...untracked]);
	}

	async function deriveCandidateFiles(scope: ScopeSelection): Promise<string[]> {
		if (scope.scope === "base") return await getBaseBranchFiles(scope.baseBranch!);
		if (scope.scope === "local") return await getLocalChangedFiles();
		if (scope.scope === "unstaged") return await getUnstagedFiles();
		return [];
	}

	async function chooseFiles(candidateFiles: string[], ctx: Parameters<Parameters<typeof pi.registerCommand>[1]["handler"]>[1]): Promise<string[] | null> {
		if (candidateFiles.length === 0) {
			const edited = await ctx.ui.editor(
				"Files to include",
				"# One relative path per line\n# Delete this help text and enter the files to include\n",
			);
			if (!edited?.trim()) return [];
			return parseLines(edited);
		}

		const choice = await ctx.ui.select("File selection", ["1. Use all files from scope", "2. Choose files interactively"]);
		if (!choice) return null;
		if (choice.startsWith("1.")) return candidateFiles;

		const edited = await ctx.ui.editor("Choose files", candidateFiles.join("\n"));
		if (!edited?.trim()) return [];
		return parseLines(edited).filter((file) => candidateFiles.includes(file));
	}

	function buildTask({
		mode,
		scope,
		selectedFiles,
		userTask,
	}: {
		mode: ReviewMode;
		scope: ScopeSelection;
		selectedFiles: string[];
		userTask?: string;
	}): string {
		const sections = [
			`Mode: ${mode}`,
			`Scope: ${scope.scope}`,
			scope.baseBranch ? `Base branch: ${scope.baseBranch}` : undefined,
			selectedFiles.length ? `Allowed files:\n${selectedFiles.map((file) => `- ${file}`).join("\n")}` : "Allowed files: none specified",
			userTask ? `Primary task / focus:\n${userTask}` : undefined,
			scope.customInstructions ? `Additional context:\n${scope.customInstructions}` : undefined,
			mode === "implement_review_fix_automatically"
				? "Implement the requested work, but only within the allowed files unless the task explicitly justifies more."
				: "Review only the relevant changes in the allowed files. If a file outside the allowed list matters, mention it instead of drifting scope.",
		].filter(Boolean);
		return sanitizeForSlashTask(sections.join("\n\n"));
	}

	async function runSlashCommand(command: string, ctx: Parameters<Parameters<typeof pi.registerCommand>[1]["handler"]>[1]) {
		pi.sendUserMessage(command);
		await ctx.waitForIdle();
	}

	pi.registerCommand("review", {
		description: "Run Elixir review/fix workflows on top of pi-subagents",
		handler: async (args, ctx) => {
			try {
				const mode = await chooseMode(ctx);
				if (!mode) return;

				const scope = await chooseScope(ctx);
				if (!scope) return;

				const candidateFiles = await deriveCandidateFiles(scope);
				const selectedFiles = await chooseFiles(candidateFiles, ctx);
				if (!selectedFiles) return;
				if (selectedFiles.length === 0) {
					ctx.ui.notify("No files selected", "warning");
					return;
				}

				let userTask = args.trim() || scope.customInstructions;
				if (mode === "implement_review_fix_automatically" && !userTask) {
					const entered = await ctx.ui.editor(
						"Implementation task",
						"Describe what should be implemented:\n",
					);
					userTask = entered?.trim() || undefined;
					if (!userTask) return;
				}

				const task = buildTask({ mode, scope, selectedFiles, userTask });

				if (mode === "review_only") {
					await runSlashCommand(`/run elixir-reviewer ${task}`, ctx);
					ctx.ui.notify("Review completed", "info");
					return;
				}

				if (mode === "review_then_ask_before_fix") {
					await runSlashCommand(`/run elixir-reviewer ${task}`, ctx);
					const proceed = await ctx.ui.confirm(
						"Apply fixes?",
						"Run the full reviewer -> fixer -> verifier chain on the selected files?",
					);
					if (!proceed) return;
					await runSlashCommand(`/chain elixir-reviewer elixir-fixer elixir-verifier -- ${task}`, ctx);
					ctx.ui.notify("Review + fix completed", "info");
					return;
				}

				await runSlashCommand(`/chain elixir-writer elixir-reviewer elixir-fixer elixir-verifier -- ${task}`, ctx);
				ctx.ui.notify("Implement/review/fix completed", "info");
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
			}
		},
	});
}
