## Why

The repo currently presents itself only as a template hub, but you also want to keep small standalone flakes here when they are too minor to justify a separate repository. That need is already concrete: you want to bring in the existing `oh-my-claudecode` packaging flake under the new public name `oh-my-cloudcode`, and you want a sibling helper flake for `oh-my-codex`. Without an explicit place and contract for those flakes, they either clutter the repo root or get conflated with `nix flake new` templates.

## What Changes

- Add a dedicated `flakes/` area for non-template flakes that are hosted in this repo.
- Keep all existing project templates under `templates/` with no change to their `nix flake new` interface or physical location.
- Document the distinction between templates and helper flakes so future additions do not mix the two concerns.
- Define the repository contract for helper flakes so they can live in this repo without being exposed as template outputs.
- Allow the root flake to optionally re-export selected outputs from independent helper flakes as a convenience interface without making those helper flakes part of the template system.
- Import the existing flake at `https://github.com/Larusso/oh-my-claudecode-flake` as an independent helper flake under `flakes/oh-my-cloudcode/`, renaming its public-facing identifiers from `claudecode` to `cloudcode`.
- Add a new independent helper flake under `flakes/oh-my-codex/` that packages the upstream project at `https://github.com/Yeachan-Heo/oh-my-codex`.
- Re-export both helper flakes from the root flake for easier installation, including each flake's default package and files-only package.
- Add a README for `oh-my-codex` similar in structure and usage guidance to the existing `oh-my-claudecode` packaging README, and list the extra helper flakes in the root README.

## Capabilities

### New Capabilities

- `helper-flakes`: Repository layout and documentation for standalone helper flakes under `flakes/`, explicitly separate from `templates/`.
- `oh-my-cloudcode-flake`: Independent helper flake for the upstream `oh-my-claudecode` ecosystem, hosted in this repo under the renamed public identity `oh-my-cloudcode`.
- `oh-my-codex-flake`: Independent helper flake for the upstream `oh-my-codex` project, hosted in this repo as a standalone helper flake.

### Modified Capabilities

- (None)

## Impact

- **Repository layout:** a new `flakes/` subtree is introduced for small non-template flakes, including `flakes/oh-my-cloudcode/` and `flakes/oh-my-codex/`.
- **Packaging work:** the repo gains one imported-and-renamed helper flake based on `Larusso/oh-my-claudecode-flake` and one new helper flake for `Yeachan-Heo/oh-my-codex`.
- **Root flake UX:** the root flake re-exports selected helper-flake packages so installation can happen from the repo root.
- **Documentation:** root docs and repo conventions need to describe the repo as both a template hub and a host for standalone helper flakes, including the concrete helper flakes now shipped here.
- **Template behavior:** no change to `templates/`, root `outputs.templates`, or template test contracts.
