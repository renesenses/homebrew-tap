class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.343"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-macos-aarch64.tar.gz"
      sha256 "1b6bd68fd01dcdfe455221c6abca0838f332736866e9dae56cb74c3e99e9c8f1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-macos-x86_64.tar.gz"
      sha256 "fdd3310911a11fd29b680075c1d71334b00696a5174b0bcbeeb807e0b56aeebc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-linux-aarch64.tar.gz"
      sha256 "67ff3ac71e89fd4af72dcbfdc7805f2f379e7c5e8157b0fb1c7cdae2737b98d5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-linux-x86_64.tar.gz"
      sha256 "5b19a783b09def61b4d6ab1a931efbccd95cae7555e63fd076d34dd05ce820c5"
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
      Tune Server v0.8.343 (Rust) installed!

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
