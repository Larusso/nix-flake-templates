{
  description = "Nix flake packaging oh-my-cloudecode from the oh-my-claudecode upstream";

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
          version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;

          # Full package: installs npm deps (including native modules like
          # better-sqlite3 and @ast-grep/napi) and exposes the omc CLI.
          # dist/ and bridge/*.cjs are pre-built upstream, so we skip npm build.
          #
          # To get the correct npmDepsHash, run:
          #   nix build .#oh-my-claudecode 2>&1 | grep "got:"
          # and paste the hash below.
          oh-my-cloudecode = pkgs.buildNpmPackage {
            pname = "oh-my-cloudecode";
            inherit version src;

            npmDepsHash = "sha256-zHpnO5zankzuYJQfpQADt1lAaMzItTQi7tJcAjpPSRE=";

            dontNpmBuild = true; # dist/ is already built in the upstream repo

            nativeBuildInputs = [ pkgs.makeWrapper pkgs.python3 pkgs.node-gyp ]
              ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.pkg-config ];

            # No extra buildInputs needed; buildNpmPackage pulls in platform SDK
            # automatically for native module compilation (better-sqlite3, @ast-grep/napi).

            installPhase = ''
              runHook preInstall

              local dest="$out/lib/oh-my-claudecode"
              mkdir -p "$dest"
              cp -r . "$dest/"

              mkdir -p "$out/bin"
              for bin in omc oh-my-claudecode omc-cli; do
                makeWrapper ${pkgs.nodejs_22}/bin/node "$out/bin/$bin" \
                  --add-flags "$dest/bridge/cli.cjs" \
                  --set NODE_PATH "$dest/node_modules"
              done

              runHook postInstall
            '';

            meta = with lib; {
              description = "Multi-agent orchestration system for Claude Code";
              homepage = "https://github.com/Yeachan-Heo/oh-my-claudecode";
              license = licenses.mit;
              mainProgram = "omc";
              platforms = platforms.unix;
            };
          };

          # Lightweight alternative: only the static plugin files.
          # No npm or native-module compilation needed.
          # Use this when you just need skills/agents/hooks available on disk
          # (e.g. to link into ~/.claude or a project's .claude directory).
          oh-my-cloudecode-files = pkgs.stdenv.mkDerivation {
            pname = "oh-my-cloudecode-files";
            inherit version src;

            dontBuild = true;

            installPhase = ''
              local dest="$out/lib/oh-my-claudecode"
              mkdir -p "$dest"
              # Copy directories and files that are present in the git checkout.
              # Note: 'commands' is listed in package.json#files but not committed.
              cp -r agents skills hooks templates docs "$dest/"
              # Dotfiles need explicit handling
              cp -r .claude-plugin "$dest/"
              cp .mcp.json "$dest/"
              cp README.md LICENSE "$dest/"
            '';

            meta = with lib; {
              description = "oh-my-cloudecode static plugin files (skills, agents, hooks)";
              homepage = "https://github.com/Yeachan-Heo/oh-my-claudecode";
              license = licenses.mit;
            };
          };
        in
        {
          packages = {
            default = oh-my-cloudecode;
            inherit oh-my-cloudecode oh-my-cloudecode-files;
          };

          devShells.default = pkgs.mkShell {
            packages = [ oh-my-cloudecode pkgs.nodejs_22 ];
          };
        };

      # Expose raw source so downstream flakes can reference files directly:
      #   inputs.oh-my-cloudecode.lib.src
      flake.lib.src = inputs.oh-my-claudecode-src;
    };
}
