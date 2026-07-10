class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.288"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.288/tune-server-v0.8.288-macos-aarch64.tar.gz"
      sha256 "dde89b40f382cb7e8faf696e5cbff2d1620e9ee8a2854787d91331ec44bb8af2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.288/tune-server-v0.8.288-macos-x86_64.tar.gz"
      sha256 "e7f68e5f6439a937ff98336ce607904ba3835f472548a619f7d315d0ebdefb7b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.288/tune-server-v0.8.288-linux-aarch64.tar.gz"
      sha256 "eb6ead102e676c924098a35ce15eead0473d25b946c127feb5a50b8c90fba8f1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.288/tune-server-v0.8.288-linux-x86_64.tar.gz"
      sha256 "a2635cfc27dc80a32759ae9e7e2b635b2ffb7e4b1dae894157def0a7132bd1f4"
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
      Tune Server v0.8.288 (Rust) installed!

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
