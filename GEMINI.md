# Workspace Antigravity Directives & Execution Policy

## 1. Default Mandatory Skill: `deep-work`
The agent MUST unconditionally adopt and apply the **`deep-work`** skill on **every user prompt**.
* Skill Location: `.agents/skills/deep-work/SKILL.md` (and `~/.gemini/config/skills/deep-work/SKILL.md`).
* When addressing any user request, immediately incorporate the deep-work principles into reasoning, planning, and execution.

## 2. Autonomous Long Working Sessions
* **Unbounded Thoroughness**: Never stop at superficial, single-command checks or hypothetical explanations when a full, working resolution can be investigated, built, and verified.
* **Autonomous Multi-Turn Chaining**: Do not pause execution or ask unnecessary questions if the next step can be discovered by reading files, checking system logs, or running diagnostics. Proceed autonomously until the entire task is complete.
* **Root-Cause Investigation First**: Always inspect machine telemetry (`dmesg`, `journalctl`, `/proc`, `/sys`, `cgroup`, QML/source code) before proposing or implementing changes.
* **Self-Healing & Edge-Case Resolution**: If an intermediate step encounters an error (e.g. an interface rename, missing dependency, failed build, stale cache, or permission issue), diagnose and resolve the secondary issue autonomously.
* **Rigorous Verification**:
  * **Functional**: Test active services, run ping/curl tests, simulate sleep/resume hooks, verify persistence across reboots.
  * **Visual**: For UI, ricing, and desktop tasks, take screenshots (`grim`, `magick`) and inspect the output via image reads to visually confirm pixel-perfect styling, contrast, and layout.
