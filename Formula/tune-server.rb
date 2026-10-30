class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "1.0.0-rc9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc9/tune-server-v1.0.0-rc9-macos-aarch64.tar.gz"
      sha256 "1f896ed7c62e39eeec5fbde3bb4104d8e7dd039a7293d1ac03ac849c3e8b4ac2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc9/tune-server-v1.0.0-rc9-macos-x86_64.tar.gz"
      sha256 "74f66ca7325db442c3789e0a7369307b4d43b15ca9a01cbcf48b8acce5708c57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc9/tune-server-v1.0.0-rc9-linux-aarch64.tar.gz"
      sha256 "acf84226a5b46ec1ae56cf933d6dfe868dedc7d1959a5dd27ceee4a66655c5e7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc9/tune-server-v1.0.0-rc9-linux-x86_64.tar.gz"
      sha256 "16e2e2c2286419c4247bf643862b9de61cf7f74ef7adfdd57ba49753bf1f6fac"
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
      Tune Server v1.0.0-rc9 (Rust) installed!

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
