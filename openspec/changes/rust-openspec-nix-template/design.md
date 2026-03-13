## Context

The repo is already structured as a template hub with a thin root flake, dedicated template directories under `templates/`, and per-template test scripts under `tests/`. Existing templates establish the current conventions:

- `templates/openspec/` provides an OpenSpec-only flake and README.
- `templates/rust/`, `templates/rust-bin/`, and `templates/rust-lib/` provide Rust-focused variants built around the shared `runtimeDeps` / `buildDeps` / `devDeps` / `libPath` layout.
- The root flake registers template outputs, and tests validate both flake evaluation and generated-project behavior.

This change adds three dedicated Rust+OpenSpec combination templates: `rust-openspec`, `rust-bin-openspec`, and `rust-lib-openspec`. Nix templates are not composable: `nix flake new -t <ref>#name` copies exactly one template directory, so the only workable approach is to maintain an explicit combined template for each supported Rust project shape rather than trying to merge `rust*` and `openspec` at generation time.

## Goals / Non-Goals

**Goals:**

- Add `templates/rust-openspec/`, `templates/rust-bin-openspec/`, and `templates/rust-lib-openspec/` as first-class templates that give generated projects both a Rust toolchain and OpenSpec.
- Keep all three combined templates consistent with the existing flake conventions, especially the dependency grouping and `flake-parts` structure from AGENTS.md.
- Register the templates in the root flake so users can run `nix flake new -t <repo>#rust-openspec <dir>`, `#rust-bin-openspec`, and `#rust-lib-openspec`.
- Extend tests so each new template is checked for evaluation and expected shell contents (`rustc`, `cargo`, and `openspec` available; generated project does not expose `templates`), with build verification for the bin/lib variants.
- Provide a README in each template explaining what it provides and how to get started with that project shape.

**Non-Goals:**

- Replacing or restructuring the existing `rust`, `rust-bin`, `rust-lib`, or `openspec` templates.
- Introducing template composition machinery in the root flake; the combined template remains an explicitly maintained directory.
- Reworking the existing standalone Rust templates; the new templates are additive OpenSpec-enabled variants of those shapes.
- Changing the broader hub layout or test harness beyond what is needed to register and validate the new template.

## Decisions

### 1. Implement three standalone combination template directories

**Decision:** Add `templates/rust-openspec/`, `templates/rust-bin-openspec/`, and `templates/rust-lib-openspec/`, each with its own `flake.nix`, `.envrc`, `.gitignore`, `README.md`, and lockfile. The bin/lib variants also include the corresponding Cargo scaffold files.

**Rationale:** This matches how Nix templates actually work and keeps generation deterministic. Each combined template becomes a normal project flake after `nix flake new`, with no `templates` output leaked into generated projects.

**Alternatives considered:** Attempting to reuse or merge two template directories at generation time. Rejected because `nix flake new` copies only one template path.

### 2. Base each combination template on its existing Rust counterpart, then add OpenSpec

**Decision:** Start from the current `rust`, `rust-bin`, and `rust-lib` template structures respectively and extend each one with the OpenSpec package/input in `devDeps`, while preserving the established dependency buckets and shell layout.

**Rationale:** The existing Rust templates already define the toolchain shape, package behavior, `mkDevShell`, and developer ergonomics expected for each project shape in this repo. Adding OpenSpec on top of each of them yields the desired combined environments with minimal divergence. Using the AGENTS.md dependency pattern keeps the templates easy to reason about and consistent with the rest of the hub.

**Alternatives considered:** Start from the OpenSpec template and bolt on Rust behavior, or invent a new flake shape shared only by the combination templates. Rejected because that would either discard the Rust-specific conventions already in use or create an unnecessary parallel structure.

### 3. Preserve the three Rust project shapes rather than collapsing them into one combined template

**Decision:** `rust-openspec` remains the devShell-only variant, while `rust-bin-openspec` and `rust-lib-openspec` preserve the package outputs and Cargo scaffolding of `rust-bin` and `rust-lib`.

**Rationale:** The repo already distinguishes between a devShell-only Rust template and ready-to-build binary/library scaffolds. Users who want OpenSpec support need those same entry points, not a single generalized combination template. Mirroring the existing split keeps user expectations aligned and avoids removing functionality from the bin/lib variants.

**Alternatives considered:** Offer only `rust-openspec` and ask users to adapt it manually into bin/lib projects. Rejected because it would be less capable than the current standalone Rust template set and would not match the stated requirement.

### 4. Expose the template through the root flake alongside existing templates

**Decision:** Add `templates.rust-openspec`, `templates.rust-bin-openspec`, and `templates.rust-lib-openspec` to the root flake with explicit paths and descriptions, without changing the default template selection.

**Rationale:** This preserves the hub’s thin-root design and keeps `openspec` or current defaults stable for existing users while making the new template discoverable through standard flake template listing and selection.

### 5. Extend the existing test strategy with dedicated scripts for each combination template

**Decision:** Add test scripts under `tests/` for `rust-openspec`, `rust-bin-openspec`, and `rust-lib-openspec` that follow the same pattern as the current template tests: verify the template flake checks/evaluates, generate a temporary project from the template, confirm `rustc`, `cargo`, and `openspec` are on `PATH` in the devShell, assert the generated flake does not expose `templates`, and verify `nix build` output for the bin/lib variants.

**Rationale:** The current repo already validates templates through shell scripts rather than inventing a separate framework. Reusing that pattern keeps maintenance low and ensures all three new templates are tested the same way users consume them.

**Alternatives considered:** Rely only on `nix flake check` for the template directory. Rejected because build-only checks do not prove that generated projects expose the right developer tools or omit `templates` outputs.

### 6. Tailor each README to its corresponding combined template

**Decision:** `templates/rust-openspec/README.md` should explain how to initialize a crate or workspace after generation, while `templates/rust-bin-openspec/README.md` and `templates/rust-lib-openspec/README.md` should explain the scaffold they ship with and how to extend it.

**Rationale:** AGENTS.md requires every template README to cover what the template provides and how to get started. The three combined templates serve different entry points, so the documentation should match those starting states instead of forcing one generic README.

## Risks / Trade-offs

- **[Trade-off]** The three combination templates duplicate flake logic already present in `templates/rust*` and `templates/openspec/`. → Mitigation: keep each combination template structurally aligned with its Rust counterpart so updates can be ported mechanically.
- **[Risk]** Rust toolchain setup and OpenSpec input may drift independently across six related templates over time. → Mitigation: keep the combination templates close to the existing Rust templates as the primary bases and cover them with dedicated tests.
- **[Trade-off]** The template matrix grows, increasing maintenance and test runtime. → Mitigation: each template has a narrow purpose and can reuse the existing test-script pattern with minimal custom logic.
- **[Risk]** Root template registration or test aggregation may miss one of the new templates, leaving it partially integrated. → Mitigation: include explicit root-flake registration and `tests/run-all.sh` updates as part of implementation tasks.

## Migration Plan

1. Create `templates/rust-openspec/`, `templates/rust-bin-openspec/`, and `templates/rust-lib-openspec/` from their existing Rust counterparts with OpenSpec added.
2. Register the three new templates in the root `flake.nix`.
3. Add dedicated test scripts and aggregate-runner entries for all three combination templates.
4. Verify each template by generating a throwaway project and checking shell tool availability plus absence of `templates` output, with build verification for the bin/lib variants.

Rollback: remove the template directory, revert the root flake registration, and drop the test script.

## Open Questions

- Whether all three combination templates can share a small helper pattern without obscuring the current one-template-per-directory structure is an implementation detail, but the design assumes consistency with the current Rust templates unless implementation pressure justifies a small local abstraction.
