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
                echo ""
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
        };
    };
}