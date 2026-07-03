class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.239"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.239/tune-server-v0.8.239-macos-aarch64.tar.gz"
      sha256 "2d5d9ad93610b2fd1ecdc829cb085103062e6584f645ad6a540599393d6e35e4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.239/tune-server-v0.8.239-macos-x86_64.tar.gz"
      sha256 "82bdfa4d4677cb9b17b2d1926fd49389af9196e671bbe4371f06d17725dcb05b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.239/tune-server-v0.8.239-linux-aarch64.tar.gz"
      sha256 "aeb41c10f5c9342903f88c54fe2a12cb5bc17966ece03f3fbd0327bc88a55466"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.239/tune-server-v0.8.239-linux-x86_64.tar.gz"
      sha256 "a9dbee74040dc6bbfc6cc0ddca96fb7025c3358915f228980a71e870f33b28d7"
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
      Tune Server v0.8.239 (Rust) installed!

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
