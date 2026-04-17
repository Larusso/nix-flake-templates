## Context

The repository already has a clear template contract: template projects live under `templates/`, are exposed through the root flake's `outputs.templates`, and are validated by template-specific tests. The new requirement is narrower than a template-layout migration. You want a place to host additional small flakes that are useful to keep in this repo but are not templates and should not affect `nix flake new`.

That means the design problem is mainly about repository boundaries and documentation:

- where standalone helper flakes live
- how they are distinguished from templates
- how to avoid accidental coupling between helper flakes and template automation

This change also has two concrete targets:

- `oh-my-claudecode`, packaged directly from the upstream repo `Yeachan-Heo/oh-my-claudecode` as the hosted helper-flake identity in this repo
- `oh-my-codex`, a new helper flake for the upstream project `Yeachan-Heo/oh-my-codex`

The upstreams are similar in intent but not identical in packaging shape. `oh-my-claudecode` can be packaged as both a full CLI build and a files-only output. `oh-my-codex` is a mixed Node/Rust project with a distributable `omx` CLI and reusable on-disk assets, so the new flake should follow the same broad pattern where practical: a directly usable helper flake with clear package outputs and no dependence on the root template interface.

## Goals / Non-Goals

**Goals:**

- Introduce a dedicated location for non-template helper flakes.
- Preserve the current `templates/` layout and template interface unchanged.
- Document the distinction between templates and helper flakes at the repo level.
- Make it clear that helper flakes are hosted in the repo without being exposed as template outputs.
- Add `flakes/oh-my-claudecode/` by packaging the upstream `oh-my-claudecode` project directly.
- Add `flakes/oh-my-codex/` as a new independent helper flake for the upstream `oh-my-codex` project.

**Non-Goals:**

- Moving existing templates.
- Changing `outputs.templates` in the root flake.
- Bringing helper flakes into the template test matrix.
- Requiring every helper flake to be exported from the root flake.
- Perfectly normalizing package/output names between the two upstream projects where their ecosystems differ.

## Decisions

### 1. Reserve `flakes/` for non-template hosted flakes

**Decision:** Add a top-level `flakes/` directory as the home for standalone helper flakes hosted in this repository.

**Rationale:** This keeps helper flakes out of the repo root while avoiding any ambiguity about whether they are templates. It also leaves the existing `templates/` layout intact.

**Alternatives:** Put helper flakes directly at the repo root or under `templates/`. Rejected because both options blur the line between infrastructure, templates, and standalone flakes.

### 2. Keep the template contract unchanged

**Decision:** Leave all existing templates in `templates/` and do not change the root flake's `outputs.templates` behavior as part of this change.

**Rationale:** The user-facing template interface already works. The new repo scope does not require a template migration, only a separate home for a different class of flakes.

### 3. Define helper flakes by exclusion from template behavior

**Decision:** The helper-flake contract explicitly states that flakes under `flakes/` are not copied via `nix flake new`, are not exposed via `outputs.templates`, and are not automatically subject to template-specific tests.

**Rationale:** The most important boundary is what helper flakes are not. That prevents future contributors from accidentally wiring them into the template system.

### 4. Capture the broader repo mission in documentation

**Decision:** Update root-level documentation and conventions so the repo is described as both a template hub and a place for small standalone helper flakes.

**Rationale:** Without an explicit repo-level statement, future additions are likely to drift back into the root directory or into `templates/` even when they are not templates.

### 5. Allow optional root-flake re-exports as a convenience layer

**Decision:** Helper flakes remain independent under `flakes/`, but the root flake may optionally re-export selected outputs from those subflakes for convenience. Any such re-export is secondary to the direct subflake interface and does not change the helper flake's independent status.

**Rationale:** This preserves the clean structural boundary while allowing a simpler root UX where it is actually useful. It avoids forcing every helper flake into the root API surface.

**Alternatives:** Never re-export helper flakes from the root flake, or require all helper flakes to be re-exported. Rejected because the first forbids a useful convenience pattern and the second weakens the independence boundary.

For this change specifically, `oh-my-claudecode` and `oh-my-codex` are important enough to justify root re-exports for their installation-oriented package outputs.

### 6. Package upstream oh-my-claudecode directly as `oh-my-claudecode`

**Decision:** Add `flakes/oh-my-claudecode/` as a local helper flake that packages `https://github.com/Yeachan-Heo/oh-my-claudecode` directly, using `oh-my-claudecode` consistently in its hosted identifiers, descriptions, and documentation.

**Rationale:** The hosted flake needs to be independent in this repo, but it does not need to preserve the exact structure of the earlier Larusso packaging repository. Packaging upstream directly keeps the source of truth obvious while still presenting the helper flake under the preferred name.

**Alternatives:** Vendor the older `Larusso/oh-my-claudecode-flake` repository. Rejected because the implementation here packages upstream directly and keeps the hosted name aligned with the upstream project name.

### 7. Model `oh-my-codex` as a sibling helper flake with the same independence boundary

**Decision:** Add `flakes/oh-my-codex/` as a separate helper flake that packages the upstream `Yeachan-Heo/oh-my-codex` repository. The flake should stay independently usable and may expose more than one package output where useful, such as a full CLI-oriented package and a lighter files-oriented package.

**Rationale:** `oh-my-codex` serves the same class of need as `oh-my-claudecode`, but the upstream implementation differs. Treating it as a sibling helper flake, rather than forcing it into the template system or into the same exact package shape, keeps the design honest.

**Alternatives:** Defer `oh-my-codex` to a later change, or require it to match the `oh-my-claudecode` output surface exactly. Rejected because the user wants it in scope now and because the upstreams are similar, not identical.

### 8. Re-export the installation-oriented helper packages from the root flake

**Decision:** The root flake should re-export the installation-oriented package outputs for both helper flakes: the default package and the files-only package for `oh-my-claudecode`, and the default package plus a files-only package for `oh-my-codex`.

**Rationale:** These are the concrete helper flakes this repo intends to host and make easy to consume. Root re-exports provide a smoother installation path without undermining the helper flakes' independent structure.

**Alternatives:** Require users to target only `./flakes/<name>` paths. Rejected because the user explicitly wants easier installation from the root.

### 9. Mirror the claudecode README style for codex

**Decision:** `flakes/oh-my-codex/README.md` should follow the same broad structure as the current `oh-my-claudecode` packaging README: package list, usage via flake input, direct package consumption examples, and update/build guidance adapted to `oh-my-codex`.

**Rationale:** The two helper flakes are sibling offerings in the same repo. Similar README structure reduces friction and makes the differences easier to scan.

## Risks / Trade-offs

- **[Risk]** Contributors may assume every flake in the repo belongs in template automation. **Mitigation:** Document that only `templates/` participates in the template interface and tests.
- **[Risk]** `flakes/` could become a miscellaneous dumping ground. **Mitigation:** Define it narrowly for small standalone flakes that do not warrant separate repositories.
- **[Risk]** Optional root re-exports could blur whether helper flakes are independent or root-managed. **Mitigation:** State that direct use of the subflake remains the primary interface and root re-exports are convenience-only.
- **[Risk]** The hosted helper-flake name could drift from the upstream `oh-my-claudecode` name in package names, docs, or comments. **Mitigation:** Treat naming consistency as part of the implementation checklist and review public-facing strings.
- **[Risk]** `oh-my-codex` packaging may be more complex than `oh-my-claudecode` because the upstream includes both Node and Rust components. **Mitigation:** Define the helper flake contract around independently usable outputs and iterate on package breadth as needed during implementation.
- **[Risk]** Root re-export names could become awkward or inconsistent between the two helper flakes. **Mitigation:** Define explicit exported package names during implementation and document them in the root README.
- **[Trade-off]** Helper flakes do not get an immediate shared automation contract. **Mitigation:** Leave helper-flake validation for later, once real helper flakes exist and common needs are clearer.

## Migration Plan

1. Create the `flakes/` directory for standalone helper flakes.
2. Add `flakes/oh-my-claudecode/` for the upstream `oh-my-claudecode` helper flake.
3. Create `flakes/oh-my-codex/` for the `Yeachan-Heo/oh-my-codex` upstream.
4. Re-export the selected install-oriented helper packages from the root flake.
5. Update root documentation and conventions to describe the broader repo scope and list the hosted helper flakes.
6. Leave `templates/`, root template outputs, and template tests unchanged.

## Open Questions

- Which helper flakes, if any, deserve root-level re-exports remains intentionally selective and can be decided case by case as concrete helper flakes are added.
