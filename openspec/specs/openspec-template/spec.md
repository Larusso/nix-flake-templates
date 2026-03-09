## Requirements

### Requirement: OpenSpec template directory structure

The template SHALL live under `templates/openspec/` and MUST contain a Nix flake, an optional `.envrc`, and a `.gitignore` that ignores `.direnv`, so that `nix flake new -t <ref>#openspec <dir>` copies a single directory that is a valid Nix + OpenSpec project root.

#### Scenario: Template directory exists and is copyable

- **WHEN** the hub flake exposes `templates.openspec.path` pointing at `templates/openspec`
- **THEN** `nix flake new -t <ref>#openspec <target-dir>` copies that directory as the root of the new project

#### Scenario: Copied project has a valid flake

- **WHEN** a user runs `nix flake new -t <ref>#openspec ./out` and then `cd out && nix develop`
- **THEN** a devShell is available and includes the OpenSpec tool (e.g. `openspec --version` works)

### Requirement: OpenSpec template flake shape

The template flake SHALL use flake-parts and SHALL provide exactly one default devShell. The devShell MUST include the OpenSpec package from the flake input and MAY define runtimeDeps, buildDeps, devDeps, and libPath for consistency with project conventions.

#### Scenario: Template flake uses flake-parts

- **WHEN** the template at `templates/openspec/flake.nix` is evaluated
- **THEN** it uses `flake-parts.lib.mkFlake` and declares `perSystem` with a devShell

#### Scenario: OpenSpec available in devShell

- **WHEN** the user enters the devShell of a project created from the template
- **THEN** the `openspec` CLI is on PATH and invocable

### Requirement: Generated project is not a template hub

The template flake SHALL NOT expose an `outputs.templates` attribute. The generated project MUST be a consumer project only (no nested template output).

#### Scenario: No templates output in copied flake

- **WHEN** the file at `templates/openspec/flake.nix` is inspected
- **THEN** its `outputs` do not include a `templates` attribute

### Requirement: Template includes basic .gitignore

The template SHALL include a `.gitignore` file that ignores the `.direnv` directory so that direnv/nix users do not commit cached data.

#### Scenario: .gitignore ignores .direnv

- **WHEN** the template at `templates/openspec/` is inspected
- **THEN** it contains a `.gitignore` file that includes `.direnv` (or an equivalent pattern)

### Requirement: Shell hook shows OpenSpec init commands when project is not initialized

The template flake's devShell shellHook SHALL list OpenSpec commands that initialize the project (e.g. `openspec init`, `openspec new change`, `openspec status`, `openspec instructions`) only when OpenSpec does not consider the project initialized. The condition SHALL be determined by OpenSpec itself (e.g. running `openspec list` and treating non-zero exit as "not initialized") rather than by checking a specific file path, so that the behavior stays correct if OpenSpec's notion of "initialized" changes (e.g. config location, presence of changes or skills).

#### Scenario: Uninitialized project shows init commands

- **WHEN** the user enters the devShell of a project created from the template and OpenSpec reports the project is not initialized (e.g. `openspec list` exits non-zero)
- **THEN** the shell prints a message listing OpenSpec commands to get started (e.g. init, new change, status, instructions)

#### Scenario: Initialized project does not show init commands

- **WHEN** the user enters the devShell and OpenSpec reports the project is initialized (e.g. `openspec list` exits zero)
- **THEN** the shell does not print the OpenSpec init/get-started message

### Requirement: Template has runnable build check

The template flake SHALL expose a `checks` output so that `nix flake check ./templates/openspec` verifies the template builds (e.g. the default devShell can be built). This makes the "template builds" guarantee repeatable and documentable; checks MAY be extended later (e.g. multi-system) without changing the requirement.

#### Scenario: Flake check passes

- **WHEN** a user runs `nix flake check ./templates/openspec` from the repo root (or runs `./tests/check-openspec-template.sh`)
- **THEN** the check succeeds (template flake evaluates and the declared check derivation builds)

### Requirement: Template tests verify flake content

The OpenSpec template tests SHALL verify flake content, not only that the flake builds. The test script (e.g. `tests/check-openspec-template.sh`) SHALL run content tests by creating a project with `nix flake new -t <hub>#openspec <dir>` (the real user workflow), then (1) entering the devShell and asserting `openspec` is on PATH and invocable (e.g. `nix develop -c openspec --version` succeeds), and (2) asserting the generated project's `flake.nix` does not expose a `templates` output so that projects remain consumers. Content tests MAY be skipped (e.g. via `SKIP_CONTENT_TESTS=1`) for a faster build-only run.

#### Scenario: Content test — nix flake new then openspec in PATH

- **WHEN** the test script runs `nix flake new -t path:repo#openspec <temp-dir>` then `nix develop <dir> -c openspec --version`
- **THEN** the command succeeds (hub exposes the template and openspec is on PATH in the generated project's devShell)

#### Scenario: Content test — no templates output

- **WHEN** the test script runs content tests
- **THEN** it asserts the generated project's `flake.nix` does not contain a `templates` output (e.g. grep or equivalent)
