class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.103"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.103/tune-server-v0.9.103-macos-aarch64.tar.gz"
      sha256 "f4843262a02645e96dd9b179cec85c4b8b7876ab9431d6844214afc980e677a7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.103/tune-server-v0.9.103-macos-x86_64.tar.gz"
      sha256 "118d859322df07b9acf76e03d1144eec70a335673f6ef918aea4fc16573f41ef"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.103/tune-server-v0.9.103-linux-aarch64.tar.gz"
      sha256 "0ff043a31209a12053f3ffd5b96b5b9460186988ba598a3694e6e43936cb9aec"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.103/tune-server-v0.9.103-linux-x86_64.tar.gz"
      sha256 "95fc4f326eac8dc1faf8e8f9a8a4e500999a0ad0e5683717c73af8556612d657"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
      export TUNE_WEB_DIR="#{pkgshare}/web"
      exec "#{bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.9.103 (Rust) installed!

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
