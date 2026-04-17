## 1. Repository Layout

- [x] 1.1 Create a top-level `flakes/` directory for standalone helper flakes
- [x] 1.2 Add a minimal placeholder or README in `flakes/` so the directory purpose is explicit in the repo
- [x] 1.3 Add `flakes/oh-my-claudecode/` as an independent helper flake that packages `Yeachan-Heo/oh-my-claudecode`
- [x] 1.4 Add `flakes/oh-my-codex/` as an independent helper flake for `Yeachan-Heo/oh-my-codex`

## 2. Helper Flake Packaging

- [x] 2.1 Use the hosted `oh-my-claudecode` helper-flake identity consistently in public-facing descriptions, docs, and output names where this repo defines them
- [x] 2.2 Keep upstream references accurate where `oh-my-claudecode` must remain for source URLs or upstream naming
- [x] 2.3 Define at least one usable package output for `flakes/oh-my-codex/`
- [x] 2.4 Expose both a default package and a files-only package for `flakes/oh-my-codex/`
- [x] 2.5 Ensure `flakes/oh-my-claudecode/` exposes both a default package and a files-only package

## 3. Root Flake Integration

- [x] 3.1 Re-export the default and files-only packages from `flakes/oh-my-claudecode/` in the root flake
- [x] 3.2 Re-export the default and files-only packages from `flakes/oh-my-codex/` in the root flake
- [x] 3.3 Keep helper-flake re-exports outside `outputs.templates`

## 4. Documentation

- [x] 4.1 Update the root `README.md` to describe the repo as both a template hub and a host for smaller standalone helper flakes
- [x] 4.2 Update repo conventions documentation such as `AGENTS.md` to distinguish `templates/` from `flakes/`
- [x] 4.3 Document that helper flakes stay independently usable and may be selectively re-exported from the root flake as a convenience
- [x] 4.4 Document the hosted helper flakes `oh-my-claudecode` and `oh-my-codex` in the root README
- [x] 4.5 Write `flakes/oh-my-codex/README.md` in a structure similar to the existing claudecode packaging README, adapted for `oh-my-codex`

## 5. Validation

- [x] 5.1 Verify that existing templates remain under `templates/` and that no template paths were moved as part of this change
- [x] 5.2 Verify that the root flake's `outputs.templates` interface remains template-only after the helper-flake additions
- [x] 5.3 Verify that `flakes/oh-my-claudecode/` and `flakes/oh-my-codex/` are each directly evaluable as standalone flakes
- [x] 5.4 Verify that the root flake exposes the intended helper-flake package re-exports for both default and files-only installation paths

## 6. Test Coverage

- [x] 6.1 Add `tests/oh-my-claudecode/test.sh` for direct helper-flake builds and root package re-exports
- [x] 6.2 Add `tests/oh-my-codex/test.sh` for direct helper-flake builds and root package re-exports
- [x] 6.3 Update shared `tests/README.md` and `tests/run-all.sh` wording so helper flakes are covered alongside templates
- [x] 6.4 Extend `.github/workflows/nix-tests.yml` so helper flakes are included in the CI matrix

## 7. Lock Updates

- [x] 7.1 Extend `.github/workflows/update-template-flakes.yml` to update helper flakes under `flakes/*/`
- [x] 7.2 Refresh the root `flake.lock` in the update workflow after helper-flake lock updates
- [x] 7.3 Include helper-flake paths and the root `flake.lock` in the update PR
