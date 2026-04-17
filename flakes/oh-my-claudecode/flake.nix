{
  description = "Nix flake packaging oh-my-claudecode from the oh-my-claudecode upstream";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Upstream source — no fork needed. Pinned in flake.lock.
    # Run `nix flake update oh-my-claudecode-src` to pull the latest commit.
    oh-my-claudecode-src = {
      url = "github:Yeachan-Heo/oh-my-claudecode";
      flake = false; # upstream has no flake.nix; treat as plain source tarball
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, lib, ... }:
        let
          src = inputs.oh-my-claudecode-src;
          helper = import ./packages.nix { inherit pkgs lib src; };
        in
        {
          packages = helper.packages;
          devShells.default = helper.devShell;
        };

      # Expose raw source so downstream flakes can reference files directly:
      #   inputs.oh-my-claudecode.lib.src
      flake.lib.src = inputs.oh-my-claudecode-src;
    };
}
