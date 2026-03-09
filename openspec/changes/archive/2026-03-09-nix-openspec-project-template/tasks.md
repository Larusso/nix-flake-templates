## 1. Create OpenSpec template directory

- [x] 1.1 Create `templates/openspec/` directory
- [x] 1.2 Copy current root `flake.nix` into `templates/openspec/flake.nix`
- [x] 1.3 Copy current root `.envrc` into `templates/openspec/.envrc`
- [x] 1.4 Copy current root `.gitignore` into `templates/openspec/.gitignore` (or create one that ignores `.direnv`)

## 2. Replace root flake with template hub

- [x] 2.1 Replace root `flake.nix` with template-hub flake: same inputs (nixpkgs, flake-parts, openspec), outputs `templates.openspec` (path `./templates/openspec`, description) and `templates.default` pointing at the same template
- [x] 2.2 Add root devShell with OpenSpec (same inputs/packages as current root flake) so `nix develop` at repo root works for developing this repo with OpenSpec

## 3. Verify

- [x] 3.1 Run `nix flake new -t .#openspec ./test-out` and confirm `templates/openspec` content is copied to `test-out`
- [x] 3.2 Run `cd test-out && nix develop` and confirm devShell enters and `openspec --version` (or equivalent) works
- [x] 3.3 Confirm generated project flake has no `templates` output

## 4. Template tests

- [x] 4.1 Add `checks.devShell-builds` to the OpenSpec template flake so `nix flake check ./templates/openspec` verifies the template builds
- [x] 4.2 Add `tests/check-openspec-template.sh` that runs the OpenSpec template flake check from repo root
- [x] 4.3 Add `tests/check-all-templates.sh` that runs all template check scripts
- [x] 4.4 Add `tests/README.md` documenting how to run tests and how to add tests for new templates
- [x] 4.5 Add content tests to `check-openspec-template.sh`: copy template to temp dir, run `nix develop -c openspec --version` to verify openspec is on PATH
- [x] 4.6 Add content test: assert template flake.nix does not expose `templates` output (generated projects stay consumers)
