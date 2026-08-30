class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.127"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.127/tune-server-v0.9.127-macos-aarch64.tar.gz"
      sha256 "e541fd99539671213dc8cbb768003adcb5783e274b7435409c3ebea14981d6c2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.127/tune-server-v0.9.127-macos-x86_64.tar.gz"
      sha256 "33a3a970b1347deaa383d6b1412981ce945ac1086defddc40444beb2a8cfa8e1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.127/tune-server-v0.9.127-linux-aarch64.tar.gz"
      sha256 "882856a0cd124b6c69ccc78ed7d400f2e9999877c247f919db2628e9ff181f5b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.127/tune-server-v0.9.127-linux-x86_64.tar.gz"
      sha256 "1048915b85cbe3599b7f2a8bb9bf28e77c37a65ad54ad9b055bb03fe5677c46b"
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
      Tune Server v0.9.127 (Rust) installed!

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
