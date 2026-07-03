class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.247"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.247/tune-server-v0.8.247-macos-aarch64.tar.gz"
      sha256 "7832ca98dc3484370133dc551859e0d9e9a5d0f9f938821fb247e23711d59185"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.247/tune-server-v0.8.247-macos-x86_64.tar.gz"
      sha256 "234bdb8c8e5fc9ae7eb81d3f356ed9c272a2bd145594b57440e74a200ae6beb4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.247/tune-server-v0.8.247-linux-aarch64.tar.gz"
      sha256 "ee9716aa50783717fa571967105718793cecdaa2aecf0a8ab33719071b47f29e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.247/tune-server-v0.8.247-linux-x86_64.tar.gz"
      sha256 "7a9b15ae0834b8c3c8fb1ac15d3e2d6496b92d7d979b70d1391a3f27edbdaec1"
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
      Tune Server v0.8.247 (Rust) installed!

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
