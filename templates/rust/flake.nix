{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { config, self', pkgs, lib, system, ... }:
        let
          # Runtime dependencies: libraries the compiled binary or tools link against.
          # Examples: openssl, p7zip, zlib
          runtimeDeps = with pkgs; [
          ];

          # Build-time dependencies: tools needed only during compilation.
          # Examples: pkg-config, rustPlatform.bindgenHook, makeWrapper
          buildDeps = with pkgs; [
          ];

          # Dev-only dependencies: tools for development that aren't needed for builds.
          # Examples: rust-analyzer, cargo-watch, cargo-edit
          devDeps = with pkgs; [
          ];

          # Library path for runtime linking. Add the same libs as runtimeDeps here
          # so that binaries (and the devShell) can find them via LD_LIBRARY_PATH.
          # Examples: openssl, zlib
          libPath = with pkgs; lib.makeLibraryPath [
          ];

          # --- DevShells ----------------------------------------------------------
          #
          # mkDevShell takes a Rust toolchain and returns a shell with all deps.
          # Three shells are provided: stable (default), nightly, and msrv.
          mkDevShell = rustc:
            pkgs.mkShell {
              shellHook = ''
                export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
              '';
              buildInputs = runtimeDeps;
              nativeBuildInputs = buildDeps ++ devDeps ++ [ rustc ];
            };

          stableToolchain = pkgs.rust-bin.stable.latest.default;
          nightlyToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);

          # --- MSRV (uncomment when you have a Cargo.toml) ------------------------
          #
          # cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          # msrv = cargoToml.package.rust-version;
          # msrvToolchain = pkgs.rust-bin.stable.${msrv}.default;

          # --- Optional: binary package output ------------------------------------
          #
          # Uncomment to build an executable from your crate. Adjust name and path.
          #
          # rustPackage = features:
          #   (pkgs.makeRustPlatform {
          #     cargo = pkgs.rust-bin.stable.latest.minimal;
          #     rustc = pkgs.rust-bin.stable.latest.minimal;
          #   }).buildRustPackage {
          #     inherit (cargoToml.package) name version;
          #     src = ./.;
          #     cargoLock.lockFile = ./Cargo.lock;
          #     buildFeatures = features;
          #     buildInputs = runtimeDeps;
          #     nativeBuildInputs = buildDeps;
          #     doCheck = false;
          #     postInstall = ''
          #       wrapProgram "$out/bin/${cargoToml.package.name}" \
          #         --prefix LD_LIBRARY_PATH : "${libPath}"
          #     '';
          #   };

          # --- Optional: library package output -----------------------------------
          #
          # Uncomment to build a shared library (.so / .dylib) from your crate.
          # Requires a [lib] section with crate-type = ["cdylib"] in Cargo.toml.
          #
          # rustLibPackage =
          #   (pkgs.makeRustPlatform {
          #     cargo = pkgs.rust-bin.stable.latest.minimal;
          #     rustc = pkgs.rust-bin.stable.latest.minimal;
          #   }).buildRustPackage {
          #     inherit (cargoToml.package) name version;
          #     src = ./.;
          #     cargoLock.lockFile = ./Cargo.lock;
          #     buildInputs = runtimeDeps;
          #     nativeBuildInputs = buildDeps;
          #     doCheck = false;
          #   };

        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };

          devShells.default = self'.devShells.stable;
          devShells.stable = mkDevShell stableToolchain;
          devShells.nightly = mkDevShell nightlyToolchain;

          # Uncomment when you have a Cargo.toml with package.rust-version:
          # devShells.msrv = mkDevShell msrvToolchain;

          # Uncomment to expose a binary package:
          # packages.default = rustPackage "";

          # Uncomment to expose a library package:
          # packages.lib = rustLibPackage;

          checks.devShell-builds = mkDevShell stableToolchain;
        };
    };
}
