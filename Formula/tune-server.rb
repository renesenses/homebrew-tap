class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "1.0.0-rc13.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc13.1/tune-server-v1.0.0-rc13.1-macos-aarch64.tar.gz"
      sha256 "18e1b7f3f8601e9a5a6e6d49f1262fb358274ecd34ec881fe41098d8b811bba8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc13.1/tune-server-v1.0.0-rc13.1-macos-x86_64.tar.gz"
      sha256 "7ff879e9200d08bacd85a5a0963ff89c5cf1bf5722c840f85a5edc62e4fada39"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc13.1/tune-server-v1.0.0-rc13.1-linux-aarch64.tar.gz"
      sha256 "a6e5c777f382bc6b70d39c33a67b796d5fca32c1ee7e7c5dff3c156b98fb659a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc13.1/tune-server-v1.0.0-rc13.1-linux-x86_64.tar.gz"
      sha256 "3eacd9385e795eb3bed49758ecc0ba82ec5ffb0ec5309fcf74a7628888892844"
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
      Tune Server v1.0.0-rc13.1 (Rust) installed!

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
