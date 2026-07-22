class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.360"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.360/tune-server-v0.8.360-macos-aarch64.tar.gz"
      sha256 "253ad6042342c05ad7434493456851579f9c9757d0f2f2406b7a71b83095f649"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.360/tune-server-v0.8.360-macos-x86_64.tar.gz"
      sha256 "f6bda7f9234fd09c166c36a325d6c291609c6bb7f2c01fee89c8c3795fd3e64a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.360/tune-server-v0.8.360-linux-aarch64.tar.gz"
      sha256 "403dfe29e7063641bf11c6a6bcf0885e23a36556a96c675c3c6d69ed8d1857fb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.360/tune-server-v0.8.360-linux-x86_64.tar.gz"
      sha256 "a75868b4f807c434daa293d53f4e8afea867e9b187a4c3c0a4ef1a25524ff593"
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
      Tune Server v0.8.360 (Rust) installed!

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
