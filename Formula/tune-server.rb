class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.101"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.101/tune-server-v0.9.101-macos-aarch64.tar.gz"
      sha256 "01f802dd77b6eca77f854ca951291e3511368cb6069e3911a7ff1bd2e2aa12f5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.101/tune-server-v0.9.101-macos-x86_64.tar.gz"
      sha256 "ee60a9ad272663ca7706a80420c06adadbcfe917eea45a2b3a956758066a4a2d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.101/tune-server-v0.9.101-linux-aarch64.tar.gz"
      sha256 "02c780806bad27db565ab67decb988fd3fd8718291cd41ccbc1d6601e2a00879"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.101/tune-server-v0.9.101-linux-x86_64.tar.gz"
      sha256 "8ec7aacc449e7ff6219217c5bec307f29802f66451afcf0a80c29cffcacd4efb"
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
      Tune Server v0.9.101 (Rust) installed!

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
