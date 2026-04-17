## Why

The repo currently presents itself only as a template hub, but you also want to keep small standalone flakes here when they are too minor to justify a separate repository. That need is already concrete: you want to host a helper flake for the upstream `oh-my-claudecode` project, and you want a sibling helper flake for `oh-my-codex`. Without an explicit place and contract for those flakes, they either clutter the repo root or get conflated with `nix flake new` templates.

## What Changes

- Add a dedicated `flakes/` area for non-template flakes that are hosted in this repo.
- Keep all existing project templates under `templates/` with no change to their `nix flake new` interface or physical location.
- Document the distinction between templates and helper flakes so future additions do not mix the two concerns.
- Define the repository contract for helper flakes so they can live in this repo without being exposed as template outputs.
- Allow the root flake to optionally re-export selected outputs from independent helper flakes as a convenience interface without making those helper flakes part of the template system.
- Add an independent helper flake under `flakes/oh-my-claudecode/` that packages the upstream project at `https://github.com/Yeachan-Heo/oh-my-claudecode`.
- Add a new independent helper flake under `flakes/oh-my-codex/` that packages the upstream project at `https://github.com/Yeachan-Heo/oh-my-codex`.
- Re-export both helper flakes from the root flake for easier installation, including each flake's default package and files-only package.
- Add a README for `oh-my-codex` similar in structure and usage guidance to the existing `oh-my-claudecode` packaging README, and list the extra helper flakes in the root README.
- Extend the repo test and lock-update workflows so helper flakes are tested and updated alongside templates.

## Capabilities

### New Capabilities

- `helper-flakes`: Repository layout and documentation for standalone helper flakes under `flakes/`, explicitly separate from `templates/`.
- `oh-my-claudecode-flake`: Independent helper flake for the upstream `oh-my-claudecode` ecosystem, hosted in this repo under the `oh-my-claudecode` identity.
- `oh-my-codex-flake`: Independent helper flake for the upstream `oh-my-codex` project, hosted in this repo as a standalone helper flake.

### Modified Capabilities

- `ci-nix-tests`: Extend the GitHub Actions test workflow and `tests/` layout so helper flakes under `flakes/` also have dedicated test scripts and CI coverage.
- `template-flake-updates`: Extend the scheduled lock-update workflow so it updates helper flakes under `flakes/*/` and refreshes the root lock file after path-input changes.

## Impact

- **Repository layout:** a new `flakes/` subtree is introduced for small non-template flakes, including `flakes/oh-my-claudecode/` and `flakes/oh-my-codex/`.
- **Packaging work:** the repo gains two hosted helper flakes that package upstream projects directly: `oh-my-claudecode` for `Yeachan-Heo/oh-my-claudecode` and `oh-my-codex` for `Yeachan-Heo/oh-my-codex`.
- **Root flake UX:** the root flake re-exports selected helper-flake packages so installation can happen from the repo root.
- **Documentation:** root docs and repo conventions need to describe the repo as both a template hub and a host for standalone helper flakes, including the concrete helper flakes now shipped here.
- **Automation:** GitHub workflows and local `tests/` coverage now include helper flakes as first-class checked repo flakes.
- **Template behavior:** no change to `templates/`, root `outputs.templates`, or template test contracts.
