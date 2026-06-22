class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.154"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.154/tune-server-v0.8.154-macos-aarch64.tar.gz"
      sha256 "219c99188efdfca733b55aafead4a5dc32d138c4b938cac5bb98e96db8275c13"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.154/tune-server-v0.8.154-macos-x86_64.tar.gz"
      sha256 "7f4907ed7f5c5ecca4ce26c2f3a2fe3525fe3e4aedcff01423b8b86243816bc2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.154/tune-server-v0.8.154-linux-aarch64.tar.gz"
      sha256 "1fb99be37f6c6a37d9b7cc7ab0bbd35d53e702a06a82155d98b5a9462af781cd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.154/tune-server-v0.8.154-linux-x86_64.tar.gz"
      sha256 "bb644a94d2e51ae9c5e24fccaacfeb119193c25ed1ff234dfe644b652c3c590e"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~'BASH'
      #!/bin/bash
      export TUNE_PORT="${TUNE_PORT:-8888}"
      SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
      PREFIX="$(dirname "$SELF_DIR")"
      export TUNE_WEB_DIR="${PREFIX}/share/tune-server/web"
      exec "${SELF_DIR}/tune-server" "$@"
    BASH
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.8.154 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server
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
