{
  description = "Nix flake packaging oh-my-codex (multi-agent orchestration for OpenAI Codex CLI)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    oh-my-codex-src = {
      url = "github:Yeachan-Heo/oh-my-codex";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, lib, ... }:
        let
          src = inputs.oh-my-codex-src;
          helper = import ./packages.nix { inherit pkgs lib src; };
        in
        {
          packages = helper.packages;
          devShells.default = helper.devShell;
        };

      flake.lib.src = inputs.oh-my-codex-src;
    };
}
