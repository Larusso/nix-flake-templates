{ pkgs, lib, src }:
let
  version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;
  nodejs = pkgs.nodejs_22;

  oh-my-codex = pkgs.buildNpmPackage {
    pname = "oh-my-codex";
    inherit version src nodejs;

    npmDepsHash = "sha256-Zh2EuEFwnICJDe+xu4QzDrHoKbq4QY4ixMer26orIYs=";

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      local dest="$out/lib/oh-my-codex"
      mkdir -p "$dest"
      cp -r . "$dest/"

      mkdir -p "$out/bin"
      makeWrapper ${nodejs}/bin/node "$out/bin/omx" \
        --add-flags "$dest/dist/cli/omx.js" \
        --set NODE_PATH "$dest/node_modules"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Multi-agent orchestration layer for OpenAI Codex CLI";
      homepage = "https://github.com/Yeachan-Heo/oh-my-codex";
      license = licenses.mit;
      mainProgram = "omx";
      platforms = platforms.unix;
    };
  };

  oh-my-codex-files = pkgs.stdenv.mkDerivation {
    pname = "oh-my-codex-files";
    inherit version src;

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      local dest="$out/lib/oh-my-codex"
      mkdir -p "$dest"
      cp -r skills prompts templates "$dest/"
      cp -r docs "$dest/" 2>/dev/null || true
      cp README.md AGENTS.md "$dest/"

      runHook postInstall
    '';

    meta = with lib; {
      description = "oh-my-codex reusable files (skills, prompts, templates, docs)";
      homepage = "https://github.com/Yeachan-Heo/oh-my-codex";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };
in
{
  packages = {
    default = oh-my-codex;
    inherit oh-my-codex oh-my-codex-files;
  };

  devShell = pkgs.mkShell {
    packages = [ oh-my-codex nodejs ];
  };

  helperLib = { inherit src; };
}
