# oh-my-claudecode

A Nix flake that packages [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) under the hosted helper-flake name `oh-my-claudecode`, without requiring a fork of the upstream project.

## Packages

| Attribute | Description |
|---|---|
| `default` / `oh-my-claudecode` | Full package including the `omc` CLI binary. Compiles native modules. |
| `oh-my-claudecode-files` | Static plugin files: skills, agents, hooks, templates. No npm build. |

## Usage

### Add to another flake

```nix
inputs = {
  oh-my-claudecode.url = "path:./flakes/oh-my-claudecode";
  oh-my-claudecode.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Dev shell with the `omc` CLI

```nix
perSystem = { pkgs, system, ... }: {
  devShells.default = pkgs.mkShell {
    packages = [
      inputs.oh-my-claudecode.packages.${system}.oh-my-claudecode
    ];
  };
};
```

### Home-manager: link plugin files into `~/.claude`

```nix
{ inputs, pkgs, ... }:
let
  omcFiles = inputs.oh-my-claudecode.packages.${pkgs.system}.oh-my-claudecode-files;
in {
  home.file.".claude/skills".source = "${omcFiles}/lib/oh-my-claudecode/skills";
  home.file.".claude/agents".source = "${omcFiles}/lib/oh-my-claudecode/agents";
}
```

### Reference the raw upstream source

The original source is also exposed for cases where you need direct file access:

```nix
let omcSrc = inputs.oh-my-claudecode.lib.src;
```

## Updating

The upstream commit is pinned in `flake.lock`. To update to the latest upstream release:

```sh
nix flake update oh-my-claudecode-src
```

After updating, re-run `nix build .#oh-my-claudecode` and update `npmDepsHash` in `flake.nix` if the build reports a hash mismatch.

## Building locally

```sh
# Static files only
nix build .#oh-my-claudecode-files

# Full CLI package
nix build .#oh-my-claudecode

# Dev shell
nix develop
```

## Upstream

- **Project:** [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) by Yeachan Heo
- **License:** MIT

This flake is an independent packaging effort and is not affiliated with the upstream project.
