{ pkgs, lib, src }:
let
  version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;
  nodejs = pkgs.nodejs_22;

  oh-my-claudecode = pkgs.buildNpmPackage {
    pname = "oh-my-claudecode";
    inherit version src nodejs;

    npmDepsHash = "sha256-fNL4UlmQPL52FgH5wFR8epG540I4p+99ggsTbit5b4Q=";

    dontNpmBuild = true; # dist/ is already built in the upstream repo

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.python3 pkgs.node-gyp ]
      ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.pkg-config ];

    installPhase = ''
      runHook preInstall

      local dest="$out/lib/oh-my-claudecode"
      mkdir -p "$dest"
      cp -r . "$dest/"

      mkdir -p "$out/bin"
      for bin in omc oh-my-claudecode omc-cli; do
        makeWrapper ${nodejs}/bin/node "$out/bin/$bin" \
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

  oh-my-claudecode-files = pkgs.stdenv.mkDerivation {
    pname = "oh-my-claudecode-files";
    inherit version src;

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      local dest="$out/lib/oh-my-claudecode"
      mkdir -p "$dest"
      cp -r agents skills hooks templates docs "$dest/"
      cp -r .claude-plugin "$dest/"
      cp .mcp.json "$dest/"
      cp README.md LICENSE "$dest/"

      runHook postInstall
    '';

    meta = with lib; {
      description = "oh-my-claudecode static plugin files (skills, agents, hooks)";
      homepage = "https://github.com/Yeachan-Heo/oh-my-claudecode";
      license = licenses.mit;
    };
  };
in
{
  packages = {
    default = oh-my-claudecode;
    inherit oh-my-claudecode oh-my-claudecode-files;
  };

  devShell = pkgs.mkShell {
    packages = [ oh-my-claudecode nodejs ];
  };

  helperLib = { inherit src; };
}
