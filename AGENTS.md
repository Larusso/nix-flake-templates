# Personal Nix project template hub

This repo is a **personal Nix project template hub**: a collection of Nix flake templates for bootstrapping new projects (OpenSpec, and later Rust, rust-openspec, etc.).

## Mission

Provide reusable Nix flake templates so new projects can be created with `nix flake new -t <this-repo>#<template-name> <target-dir>` and get a consistent devShell and structure.

## Current state

- The root flake is currently a single **OpenSpec** devShell (no template outputs yet).
- A multi-template layout (thin root flake + `templates/<name>/` directories) is planned; see [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) for the strategy and combination approach (e.g. rust-openspec).

## Conventions

- Use **flake-parts** for the flake structure.
- In each template’s flake, keep the **runtimeDeps** / **buildDeps** / **devDeps** / **libPath** pattern for clarity.
- Templates produce normal project flakes: the generated project must **not** expose a `templates` output (so it stays a consumer, not a template hub).

## Reference

Multi-template layout, combination templates, and implementation steps: [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md).
