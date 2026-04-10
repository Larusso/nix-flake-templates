## 1. Repository Layout

- [ ] 1.1 Create a top-level `flakes/` directory for standalone helper flakes
- [ ] 1.2 Add a minimal placeholder or README in `flakes/` so the directory purpose is explicit in the repo
- [ ] 1.3 Add `flakes/oh-my-cloudcode/` as an independent helper flake derived from `Larusso/oh-my-claudecode-flake`
- [ ] 1.4 Add `flakes/oh-my-codex/` as an independent helper flake for `Yeachan-Heo/oh-my-codex`

## 2. Helper Flake Packaging

- [ ] 2.1 Rename the hosted `oh-my-claudecode` helper-flake identity to `oh-my-cloudcode` in public-facing descriptions, docs, and output names where this repo defines them
- [ ] 2.2 Keep upstream references accurate where `oh-my-claudecode` must remain for source URLs or upstream naming
- [ ] 2.3 Define at least one usable package output for `flakes/oh-my-codex/`
- [ ] 2.4 Expose both a default package and a files-only package for `flakes/oh-my-codex/`
- [ ] 2.5 Ensure `flakes/oh-my-cloudcode/` exposes both a default package and a files-only package

## 3. Root Flake Integration

- [ ] 3.1 Re-export the default and files-only packages from `flakes/oh-my-cloudcode/` in the root flake
- [ ] 3.2 Re-export the default and files-only packages from `flakes/oh-my-codex/` in the root flake
- [ ] 3.3 Keep helper-flake re-exports outside `outputs.templates`

## 4. Documentation

- [ ] 4.1 Update the root `README.md` to describe the repo as both a template hub and a host for smaller standalone helper flakes
- [ ] 4.2 Update repo conventions documentation such as `AGENTS.md` to distinguish `templates/` from `flakes/`
- [ ] 4.3 Document that helper flakes stay independently usable and may be selectively re-exported from the root flake as a convenience
- [ ] 4.4 Document the hosted helper flakes `oh-my-cloudcode` and `oh-my-codex` in the root README
- [ ] 4.5 Write `flakes/oh-my-codex/README.md` in a structure similar to the existing cloudcode packaging README, adapted for `oh-my-codex`

## 5. Validation

- [ ] 5.1 Verify that existing templates remain under `templates/` and that no template paths were moved as part of this change
- [ ] 5.2 Verify that the root flake's `outputs.templates` interface remains template-only after the helper-flake additions
- [ ] 5.3 Verify that `flakes/oh-my-cloudcode/` and `flakes/oh-my-codex/` are each directly evaluable as standalone flakes
- [ ] 5.4 Verify that the root flake exposes the intended helper-flake package re-exports for both default and files-only installation paths
