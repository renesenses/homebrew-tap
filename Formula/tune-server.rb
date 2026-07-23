class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.367"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.367/tune-server-v0.8.367-macos-aarch64.tar.gz"
      sha256 "063047f21f889efb0309e54ce67bef066d3362dad152bfadb646afcc554e54cd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.367/tune-server-v0.8.367-macos-x86_64.tar.gz"
      sha256 "5c13ee4b7fb2b80a72c296ab3ec5b2379c22f8e9ebb32cdd5c76092ad5189e0f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.367/tune-server-v0.8.367-linux-aarch64.tar.gz"
      sha256 "24ebe67501319abbe67ebf1c45b914783e6ca4aee8dee44523b674d29ebfb447"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.367/tune-server-v0.8.367-linux-x86_64.tar.gz"
      sha256 "402cd9b07cbe5004775475a91887323b1174881a1529d862136b815a9558ab11"
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
      Tune Server v0.8.367 (Rust) installed!

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
