class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.334"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.334/tune-server-v0.8.334-macos-aarch64.tar.gz"
      sha256 "dc8ea11c53a92d842d409e1d9867d6a9d31db10aa9d4d72cd1c6f61a16023081"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.334/tune-server-v0.8.334-macos-x86_64.tar.gz"
      sha256 "18e86b9f440da2d71c8b732e79a044989a763b3e05ec4b5463104884a90fff79"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.334/tune-server-v0.8.334-linux-aarch64.tar.gz"
      sha256 "0c54d55d768f9318663b934b666ef073018fa7f6535f00f8969370fce6d9adb9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.334/tune-server-v0.8.334-linux-x86_64.tar.gz"
      sha256 "092140b10a3771bf4d3bff3c23762e706da51a0f4647df158ccd15cfde74aaa2"
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
      Tune Server v0.8.334 (Rust) installed!

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
