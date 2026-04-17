# oh-my-codex

A Nix flake that packages [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) for use from this repository or as a standalone helper flake.

## Packages

| Attribute | Description |
|---|---|
| `default` / `oh-my-codex` | Main packaged `omx` CLI build for OpenAI Codex CLI workflows. |
| `oh-my-codex-files` | Reusable files only: skills, prompts, templates, and related docs. |

## Usage

### Add to another flake

```nix
inputs = {
  oh-my-codex.url = "path:./flakes/oh-my-codex";
  oh-my-codex.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Dev shell with the `omx` CLI

```nix
perSystem = { pkgs, system, ... }: {
  devShells.default = pkgs.mkShell {
    packages = [
      inputs.oh-my-codex.packages.${system}.oh-my-codex
    ];
  };
};
```

### Home-manager or dotfile linking with files-only assets

```nix
{ inputs, pkgs, ... }:
let
  omxFiles = inputs.oh-my-codex.packages.${pkgs.system}.oh-my-codex-files;
in {
  home.file.".codex/skills".source = "${omxFiles}/lib/oh-my-codex/skills";
  home.file.".codex/templates".source = "${omxFiles}/lib/oh-my-codex/templates";
}
```

### Reference the raw upstream source

```nix
let omxSrc = inputs.oh-my-codex.lib.src;
```

## Updating

The upstream commit is pinned in `flake.lock`. To update to the latest upstream revision:

```sh
nix flake update oh-my-codex-src
```

After updating, re-run `nix build .#oh-my-codex` and update `npmDepsHash` in `packages.nix` if the build reports a hash mismatch.

## Building locally

```sh
# Files only
nix build .#oh-my-codex-files

# Main CLI package
nix build .#oh-my-codex

# Dev shell
nix develop
```

## Upstream

- **Project:** [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) by Yeachan Heo
- **License:** MIT

This flake is an independent packaging effort and is not affiliated with the upstream project.
