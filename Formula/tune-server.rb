class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.361"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.361/tune-server-v0.8.361-macos-aarch64.tar.gz"
      sha256 "97771795bf389bd5d115b1cbfe203623879ce5cd12087ebef664ad4da0eb1db1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.361/tune-server-v0.8.361-macos-x86_64.tar.gz"
      sha256 "8df6062994e49362826a33de0c2b9701a647687a6b044987cba8c65003bed575"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.361/tune-server-v0.8.361-linux-aarch64.tar.gz"
      sha256 "7bec183e0c362b234900d622ecc8cc1d8e9ad0f6e0456c46a7838da2333157c2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.361/tune-server-v0.8.361-linux-x86_64.tar.gz"
      sha256 "3e930f7ba82da48b8baa053e4b9afa6b8cf4965a4c31ff7a691e6217242550b5"
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
      Tune Server v0.8.361 (Rust) installed!

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
