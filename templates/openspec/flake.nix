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
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { config, self', pkgs, lib, system, ... }:
        let
          runtimeDeps = with pkgs; [
          ];
          buildDeps = with pkgs; [
          ];
          devDeps = [
            inputs.openspec.packages.${system}.default
          ];
          libPath = with pkgs; lib.makeLibraryPath [
          ];

          mkDevShell = pkgs.mkShell {
              shellHook = ''
                echo "┌────────────────────────────────────────────────────────────┐"
                echo "│  Project - Development Environment                         │"
                echo "└────────────────────────────────────────────────────────────┘"
                echo ""
                # Show OpenSpec get-started hint only when project is not initialized (let OpenSpec decide)
                if ! openspec list 2>/dev/null; then
                  echo "OpenSpec not initialized. To get started:"
                  echo "  openspec init                    # initialize OpenSpec in this project"
                  echo "  openspec new change \"<name>\"   # create a new change"
                  echo "  openspec status --change \"<name>\"   # see artifact status"
                  echo "  openspec instructions <artifact> --change \"<name>\"   # get next steps"
                  echo ""
                fi
                echo "Build Commands:"
                echo ""
                echo "Test & Lint:"
                echo ""
              '';
              buildInputs = runtimeDeps;
              nativeBuildInputs = buildDeps ++ devDeps;
            };
        in {
          devShells.default = mkDevShell;
          # Basic test: template builds (devShell can be built). Run: nix flake check
          checks.devShell-builds = mkDevShell;
        };
    };
}
