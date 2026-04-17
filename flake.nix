{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    openspec = {
      url = "github:Fission-AI/OpenSpec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        perSystem = { config, self', pkgs, lib, system, ... }:
          let
            runtimeDeps = with pkgs; [ ];
            buildDeps = with pkgs; [ ];
            devDeps = [ inputs.openspec.packages.${system}.default ];
            libPath = with pkgs; lib.makeLibraryPath [ ];
            ohMyClaudecode = import ./flakes/oh-my-claudecode/packages.nix {
              inherit pkgs lib;
              src = import ./flakes/locked-src.nix {
                lockFile = ./flakes/oh-my-claudecode/flake.lock;
                inputName = "oh-my-claudecode-src";
              };
            };
            ohMyCodex = import ./flakes/oh-my-codex/packages.nix {
              inherit pkgs lib;
              src = import ./flakes/locked-src.nix {
                lockFile = ./flakes/oh-my-codex/flake.lock;
                inputName = "oh-my-codex-src";
              };
            };

            mkDevShell = pkgs.mkShell {
              shellHook = ''
                echo "┌────────────────────────────────────────────────────────────┐"
                echo "│  Template hub - Development Environment                    │"
                echo "└────────────────────────────────────────────────────────────┘"
                echo ""
                echo "Development commands:"
                echo "  ./tests/openspec/test.sh             # run OpenSpec template tests"
                echo "  ./tests/run-all.sh                   # run all template tests"
                echo "  nix flake new -t path:.#openspec <dir>   # create a new OpenSpec project"
                echo ""
                echo "OpenSpec (this repo):"
                echo "  openspec list                        # list changes"
                echo "  openspec status --change \"<name>\"   # change status"
                echo ""
              '';
              buildInputs = runtimeDeps;
              nativeBuildInputs = buildDeps ++ devDeps;
            };
          in {
            devShells.default = mkDevShell;
            packages = {
              inherit (ohMyClaudecode.packages) oh-my-claudecode oh-my-claudecode-files;
              inherit (ohMyCodex.packages) oh-my-codex oh-my-codex-files;
            };
          };
      };
    in
    flake // {
      templates = {
        openspec = {
          path = ./templates/openspec;
          description = "OpenSpec project with Nix devShell";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust devShell with rust-overlay (no project scaffold)";
        };
        rust-bin = {
          path = ./templates/rust-bin;
          description = "Rust binary project with Nix devShell and buildRustPackage";
        };
        rust-lib = {
          path = ./templates/rust-lib;
          description = "Rust library project with Nix devShell and shared library output";
        };
        rust-openspec = {
          path = ./templates/rust-openspec;
          description = "Rust devShell with OpenSpec in the same Nix development environment";
        };
        rust-bin-openspec = {
          path = ./templates/rust-bin-openspec;
          description = "Rust binary project with OpenSpec in the same Nix development environment";
        };
        rust-lib-openspec = {
          path = ./templates/rust-lib-openspec;
          description = "Rust library project with OpenSpec in the same Nix development environment";
        };
        default = {
          path = ./templates/openspec;
          description = "OpenSpec project with Nix devShell";
        };
      };
    };
}
