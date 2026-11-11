class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "1.0.0-rc11"
  license "MIT"

  # fpcalc (Chromaprint) : empreinte sonore de l'identification AcoustID
  # (Bibliotheque > Enrichissement). Sans lui : « the fpcalc tool (Chromaprint)
  # is not installed on the server » (tune-server-rust#8466, fil 2764). Le
  # service le trouve dans HOMEBREW_PREFIX/bin (std_service_path_env).
  depends_on "chromaprint"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc11/tune-server-v1.0.0-rc11-macos-aarch64.tar.gz"
      sha256 "44bf5cdd2d60471abf2adfa7b7877b027de724e98e7790eb4627a1aa3525b920"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc11/tune-server-v1.0.0-rc11-macos-x86_64.tar.gz"
      sha256 "3948939868aae9966055604a1031305d8e4693b8dfb1ae18be67268f49f128e9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc11/tune-server-v1.0.0-rc11-linux-aarch64.tar.gz"
      sha256 "98ee99580c1d1f2997ebd5892a84f727bf58c0fb97da42982255aeffaaf4f30e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc11/tune-server-v1.0.0-rc11-linux-x86_64.tar.gz"
      sha256 "903675fe4701badd7b5e9ec8a203e3b917e6779390e5e3704f67f529c9f86eb6"
    end
  end

  def install
    bin.install "tune-server"
    # Aide AirPlay 2 : le serveur la cherche d'abord a cote de son executable
    # (resolve_daemon_path). Sans elle, la zone AirPlay 2 est sautee
    # (forum, fil 1612). Absente de l'archive linux-aarch64.
    bin.install "airplay-daemon" if File.exist?("airplay-daemon")
    pkgshare.install "web"
    # Greffons livres (party, playlists-converter). Copies vers var au
    # post_install : le dossier des greffons doit survivre aux mises a jour,
    # car les greffons installes depuis le catalogue y sont ecrits aussi.
    (pkgshare/"plugins").install Dir["plugins/*"] if File.directory?("plugins")

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
      # opt_* et non pkgshare/bin : ces chemins sont ecrits EN DUR dans le
      # lanceur au moment de l'installation. `pkgshare` designe le Cellar
      # VERSIONNE (…/tune-server/0.9.71/share/…), donc un lanceur survivant a
      # une mise a jour continue de pointer sur l'ancienne version. Vecu : un
      # serveur 0.9.110 servant l'interface web de 0.9.71 — 39 versions
      # d'ecart sur le contrat client/serveur. `opt_pkgshare` et `opt_bin`
      # passent par le lien stable /opt/homebrew/opt/tune-server, qui suit
      # toujours la version courante.
      export TUNE_WEB_DIR="#{opt_pkgshare}/web"
      export TUNE_PLUGINS_DIR="${TUNE_PLUGINS_DIR:-#{var}/tune-server/plugins}"
      exec "#{opt_bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
    # Les greffons livres sont remis a jour a chaque installation ; les
    # greffons ajoutes depuis le catalogue (autres dossiers) restent en place.
    plugins = var/"tune-server/plugins"
    plugins.mkpath
    if (opt_pkgshare/"plugins").directory?
      (opt_pkgshare/"plugins").children.each do |src|
        rm_r plugins/src.basename if (plugins/src.basename).exist?
        cp_r src, plugins
      end
    end
  end

  def caveats
    <<~EOS
      Tune Server v1.0.0-rc11 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

      Legacy Python version: brew install renesenses/tap/tune-server-python
    EOS
  end

  service do
    run [opt_bin/"tune-server-launcher"]
    working_dir var/"tune-server"
    keep_alive true
    log_path var/"log/tune-server.log"
    error_log_path var/"log/tune-server.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tune-server --version 2>&1", 0)
  end
end
