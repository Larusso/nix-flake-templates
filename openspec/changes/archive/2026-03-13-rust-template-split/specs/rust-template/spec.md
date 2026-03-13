## REMOVED Requirements

### Requirement: Optional library and binary package outputs documented

**Reason**: Binary and library package outputs are now provided by dedicated templates (`rust-bin` and `rust-lib`) instead of commented blocks in the `rust` template.
**Migration**: Users who need a binary project use `nix flake new -t <ref>#rust-bin`; users who need a library project use `nix flake new -t <ref>#rust-lib`.

## ADDED Requirements

### Requirement: Template references rust-bin and rust-lib templates

The `templates/rust/` README SHALL reference the `rust-bin` and `rust-lib` templates for users who want a complete project scaffold with buildable package outputs, so that users landing in the devShell-only template know where to find the project-ready templates.

#### Scenario: README mentions rust-bin and rust-lib

- **WHEN** the file `templates/rust/README.md` is inspected
- **THEN** it contains references to both `rust-bin` and `rust-lib` templates with a brief explanation that those templates provide ready-to-build project scaffolds
