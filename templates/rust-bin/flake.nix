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
      perSystem = { config, self', lib, system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };

          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);

          # Runtime dependencies: libraries the compiled binary or tools link against.
          # Examples: openssl, p7zip, zlib
          runtimeDeps = with pkgs; [
          ];

          # Build-time dependencies: tools needed only during compilation.
          # Examples: pkg-config, rustPlatform.bindgenHook
          buildDeps = with pkgs; [
            makeWrapper
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
          # Two shells are provided: stable (default) and nightly.
          mkDevShell = rustc:
            pkgs.mkShell {
              shellHook = ''
                export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
                export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              '';
              buildInputs = runtimeDeps;
              nativeBuildInputs = buildDeps ++ devDeps ++ [ rustc ];
            };

          stableToolchain = pkgs.rust-bin.stable.latest.default;
          nightlyToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);

          # --- MSRV (uncomment when Cargo.toml has package.rust-version) -----------
          #
          # msrv = cargoToml.package.rust-version;
          # msrvToolchain = pkgs.rust-bin.stable.${msrv}.default;

          # --- Binary package output -----------------------------------------------
          rustPackage = buildFeatures:
            (pkgs.makeRustPlatform {
              cargo = pkgs.rust-bin.stable.latest.minimal;
              rustc = pkgs.rust-bin.stable.latest.minimal;
            }).buildRustPackage {
              inherit (cargoToml.package) name version;
              src = ./.;
              cargoLock.lockFile = ./Cargo.lock;
              inherit buildFeatures;
              buildInputs = runtimeDeps;
              nativeBuildInputs = buildDeps;
              doCheck = false;
              postInstall = ''
                wrapProgram "$out/bin/${cargoToml.package.name}" \
                  --prefix LD_LIBRARY_PATH : "${libPath}"
              '';
            };

        in {
          _module.args.pkgs = pkgs;

          devShells.default = self'.devShells.stable;
          devShells.stable = mkDevShell stableToolchain;
          devShells.nightly = mkDevShell nightlyToolchain;

          # Uncomment when Cargo.toml has package.rust-version:
          # devShells.msrv = mkDevShell msrvToolchain;

          packages.default = rustPackage [];

          checks.devShell-builds = mkDevShell stableToolchain;
        };
    };
}
