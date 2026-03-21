import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

type AmbiguityMode = "conservative" | "moderate" | "aggressive";

interface AmbiguityConfig {
	mode: AmbiguityMode;
}

interface GuidanceOption {
	value: string;
	label: string;
	description?: string;
}

interface GuidanceDetails {
	decision: string;
	question: string;
	whyThisMatters?: string;
	mode: AmbiguityMode;
	options: GuidanceOption[];
	selected?: {
		value: string;
		label: string;
		index: number;
	};
	note?: string;
	outcome: "selected" | "chat" | "cancelled" | "unavailable" | "invalid";
}

const OptionSchema = Type.Object({
	value: Type.String({ description: "Stable machine-readable value for this option" }),
	label: Type.String({ description: "Human-readable option label" }),
	description: Type.Optional(Type.String({ description: "Optional explanation shown to the user" })),
});

const AskForGuidanceParams = Type.Object({
	decision: Type.String({
		description: "Short label for the decision being made, e.g. 'error_handling_strategy'",
	}),
	question: Type.String({
		description: "A concise, user-facing question that asks for the missing guidance",
	}),
	whyThisMatters: Type.Optional(
		Type.String({
			description: "Brief explanation of why the decision matters and how it changes the implementation",
		}),
	),
	options: Type.Array(OptionSchema, {
		description: "Concrete options the user can choose from. Prefer 2-5 options.",
	}),
	allowFreeformNote: Type.Optional(
		Type.Boolean({
			description: "Whether to ask the user for an optional note after selecting an option. Defaults to false.",
		}),
	),
});

function defaultConfig(): AmbiguityConfig {
	return { mode: "moderate" };
}

function isMode(value: string): value is AmbiguityMode {
	return value === "conservative" || value === "moderate" || value === "aggressive";
}

function statusText(mode: AmbiguityMode): string {
	return `ambiguity:${mode}`;
}

function modePolicy(mode: AmbiguityMode): string {
	if (mode === "conservative") {
		return "Only ask when ambiguity is high-impact: architecture, public interfaces, failure semantics, invariants, trust boundaries, or broad refactors that would be annoying to undo.";
	}
	if (mode === "aggressive") {
		return "Ask whenever an assumption could materially change the implementation, even for medium-sized edits. Prefer asking over guessing when invariants, boundaries, error handling, or scope are not explicit.";
	}
	return "Ask when ambiguity is consequential: choices about invariants, boundary vs internal assumptions, error-handling strategy, or implementation scope that would be annoying to correct after a large edit.";
}

function restoreConfig(ctx: ExtensionContext): AmbiguityConfig {
	let config = defaultConfig();
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type === "custom" && entry.customType === "ambiguity-config") {
			const data = entry.data as Partial<AmbiguityConfig> | undefined;
			if (data?.mode && isMode(data.mode)) {
				config = { mode: data.mode };
			}
		}
	}
	return config;
}

export default function ambiguityGate(pi: ExtensionAPI) {
	let config = defaultConfig();

	function syncStatus(ctx: ExtensionContext) {
		if (ctx.hasUI) {
			ctx.ui.setStatus("ambiguity-gate", statusText(config.mode));
		}
	}

	function persistConfig() {
		pi.appendEntry<AmbiguityConfig>("ambiguity-config", { ...config });
	}

	pi.registerCommand("ambiguity", {
		description: "Show or set ambiguity guidance mode: conservative, moderate, aggressive",
		handler: async (args, ctx) => {
			const value = args.trim().toLowerCase();
			if (!value || value === "show" || value === "status") {
				ctx.ui.notify(`Ambiguity mode: ${config.mode}`, "info");
				syncStatus(ctx);
				return;
			}

			if (!isMode(value)) {
				ctx.ui.notify("Usage: /ambiguity [conservative|moderate|aggressive|show]", "warning");
				return;
			}

			config = { mode: value };
			persistConfig();
			syncStatus(ctx);
			ctx.ui.notify(`Ambiguity mode set to ${config.mode}`, "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		config = restoreConfig(ctx);
		syncStatus(ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		config = restoreConfig(ctx);
		syncStatus(ctx);
	});

	pi.on("session_fork", async (_event, ctx) => {
		config = restoreConfig(ctx);
		syncStatus(ctx);
	});

	pi.on("before_agent_start", async (event) => {
		const policy = modePolicy(config.mode);
		return {
			systemPrompt:
				event.systemPrompt +
				`\n\nAmbiguity guidance policy (${config.mode}): ${policy} When that happens, call the ask_for_guidance tool before making edits. Ask concise, decision-focused questions with concrete options. If the user chooses chat, stop editing, discuss the tradeoffs conversationally, and wait for clear direction before proceeding.`,
		};
	});

	pi.registerTool({
		name: "ask_for_guidance",
		label: "Ask for Guidance",
		description:
			"Pause and ask the user to resolve a consequential ambiguity before continuing. Use this when the implementation depends on an unclear decision about scope, invariants, error handling, trust boundaries, architecture, or similar high-impact tradeoffs.",
		promptSnippet: "Ask the user to resolve a consequential ambiguity before continuing edits.",
		promptGuidelines: [
			"Use this tool instead of guessing when an unclear decision would materially change the implementation or be annoying to undo.",
			"Provide 2-5 concrete options with clear labels. Ask one concise question, not an essay.",
			"If the user chooses chat, stop editing and discuss before continuing.",
		],
		parameters: AskForGuidanceParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const detailsBase = {
				decision: params.decision,
				question: params.question,
				whyThisMatters: params.whyThisMatters,
				mode: config.mode,
				options: params.options,
			} satisfies Omit<GuidanceDetails, "outcome">;

			if (!ctx.hasUI) {
				return {
					content: [
						{
							type: "text",
							text: "Guidance requested, but UI is not available in this mode.",
						},
					],
					details: {
						...detailsBase,
						outcome: "unavailable",
					} satisfies GuidanceDetails,
				};
			}

			if (!params.options.length) {
				return {
					content: [{ type: "text", text: "Invalid guidance request: no options were provided." }],
					details: {
						...detailsBase,
						outcome: "invalid",
					} satisfies GuidanceDetails,
				};
			}

			const optionLines = params.options.map((option, index) => {
				const suffix = option.description ? ` — ${option.description}` : "";
				return `${index + 1}. ${option.label}${suffix}`;
			});
			const prompt = [
				params.question,
				params.whyThisMatters ? `\nWhy this matters: ${params.whyThisMatters}` : undefined,
				"\nOptions:",
				...optionLines,
				`${params.options.length + 1}. Chat about this`,
			].filter(Boolean).join("\n");

			const selected = await ctx.ui.select(prompt, [
				...params.options.map((option, index) => `${index + 1}. ${option.label}`),
				`${params.options.length + 1}. Chat about this`,
			]);

			if (!selected) {
				return {
					content: [
						{
							type: "text",
							text: "The user cancelled the guidance request. Do not continue making assumptions; explain briefly what needs clarification.",
						},
					],
					details: {
						...detailsBase,
						outcome: "cancelled",
					} satisfies GuidanceDetails,
				};
			}

			const selectedIndex = [
				...params.options.map((option, index) => `${index + 1}. ${option.label}`),
				`${params.options.length + 1}. Chat about this`,
			].indexOf(selected);

			if (selectedIndex === params.options.length) {
				return {
					content: [
						{
							type: "text",
							text: "The user chose to chat about this before proceeding. Stop editing, discuss the tradeoffs conversationally, and wait for clear direction before making changes.",
						},
					],
					details: {
						...detailsBase,
						outcome: "chat",
					} satisfies GuidanceDetails,
				};
			}

			const chosen = params.options[selectedIndex];
			let note: string | undefined;
			if (params.allowFreeformNote === true) {
				const noteResult = await ctx.ui.input(
					"Optional note",
					"Add any extra guidance, or leave blank to continue",
				);
				note = noteResult?.trim() || undefined;
			}

			const noteText = note ? `\nAdditional user note: ${note}` : "";
			return {
				content: [
					{
						type: "text",
						text:
							`The user selected option ${selectedIndex + 1}: ${chosen.label}.` +
							noteText +
							" Continue using this decision.",
					},
				],
				details: {
					...detailsBase,
					selected: {
						value: chosen.value,
						label: chosen.label,
						index: selectedIndex + 1,
					},
					note,
					outcome: "selected",
				} satisfies GuidanceDetails,
			};
		},

		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("ask_for_guidance "));
			text += theme.fg("muted", args.question);
			if (args.decision) {
				text += `\n${theme.fg("dim", `decision: ${args.decision}`)}`;
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme) {
			const details = result.details as GuidanceDetails | undefined;
			if (!details) {
				const first = result.content[0];
				return new Text(first?.type === "text" ? first.text : "", 0, 0);
			}

			if (details.outcome === "chat") {
				return new Text(theme.fg("warning", "Chat requested before continuing"), 0, 0);
			}
			if (details.outcome === "cancelled") {
				return new Text(theme.fg("warning", "Guidance request cancelled"), 0, 0);
			}
			if (details.outcome === "unavailable" || details.outcome === "invalid") {
				return new Text(theme.fg("error", result.content[0]?.type === "text" ? result.content[0].text : "Error"), 0, 0);
			}

			const lines = [
				`${theme.fg("success", "✓ ")}${theme.fg("accent", details.selected?.label ?? "Selected")}`,
			];
			if (details.note) {
				lines.push(theme.fg("dim", `note: ${details.note}`));
			}
			return new Text(lines.join("\n"), 0, 0);
		},
	});
}
