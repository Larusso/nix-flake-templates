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

            mkDevShell = pkgs.mkShell {
              shellHook = ''
                echo "┌────────────────────────────────────────────────────────────┐"
                echo "│  Template hub - Development Environment                    │"
                echo "└────────────────────────────────────────────────────────────┘"
                echo ""
                echo "Development commands:"
                echo "  ./tests/check-openspec-template.sh   # run OpenSpec template tests"
                echo "  ./tests/check-all-templates.sh       # run all template tests"
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
        default = {
          path = ./templates/openspec;
          description = "OpenSpec project with Nix devShell";
        };
      };
    };
}
