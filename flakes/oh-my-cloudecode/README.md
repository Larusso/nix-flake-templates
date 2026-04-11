# oh-my-cloudecode

A Nix flake that packages [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) under the hosted helper-flake name `oh-my-cloudecode`, without requiring a fork of the upstream project.

## Packages

| Attribute | Description |
|---|---|
| `default` / `oh-my-cloudecode` | Full package including the `omc` CLI binary. Compiles native modules. |
| `oh-my-cloudecode-files` | Static plugin files: skills, agents, hooks, templates. No npm build. |

## Usage

### Add to another flake

```nix
inputs = {
  oh-my-cloudecode.url = "path:./flakes/oh-my-cloudecode";
  oh-my-cloudecode.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Dev shell with the `omc` CLI

```nix
perSystem = { pkgs, system, ... }: {
  devShells.default = pkgs.mkShell {
    packages = [
      inputs.oh-my-cloudecode.packages.${system}.oh-my-cloudecode
    ];
  };
};
```

### Home-manager: link plugin files into `~/.claude`

```nix
{ inputs, pkgs, ... }:
let
  omcFiles = inputs.oh-my-cloudecode.packages.${pkgs.system}.oh-my-cloudecode-files;
in {
  home.file.".claude/skills".source = "${omcFiles}/lib/oh-my-claudecode/skills";
  home.file.".claude/agents".source = "${omcFiles}/lib/oh-my-claudecode/agents";
}
```

### Reference the raw upstream source

The original source is also exposed for cases where you need direct file access:

```nix
let omcSrc = inputs.oh-my-cloudecode.lib.src;
```

## Updating

The upstream commit is pinned in `flake.lock`. To update to the latest upstream release:

```sh
nix flake update oh-my-claudecode-src
```

After updating, re-run `nix build .#oh-my-cloudecode` and update `npmDepsHash` in `flake.nix` if the build reports a hash mismatch.

## Building locally

```sh
# Static files only
nix build .#oh-my-cloudecode-files

# Full CLI package
nix build .#oh-my-cloudecode

# Dev shell
nix develop
```

## Upstream

- **Project:** [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) by Yeachan Heo
- **License:** MIT

This flake is an independent packaging effort and is not affiliated with the upstream project.
