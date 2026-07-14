class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.311"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.311/tune-server-v0.8.311-macos-aarch64.tar.gz"
      sha256 "0928cb719070336280d3050d1108e51fbcc6a7053f9488d4b0bd9c8b7a5f7d43"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.311/tune-server-v0.8.311-macos-x86_64.tar.gz"
      sha256 "9d3c8e5bcd7022ae8efc4daad53d5c755d6c5856d52e607644a7330a87a885d4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.311/tune-server-v0.8.311-linux-aarch64.tar.gz"
      sha256 "4b558e7121902fc1f849e58e9e1e8c29a9f116302111cc090c87c0bf057e5767"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.311/tune-server-v0.8.311-linux-x86_64.tar.gz"
      sha256 "85bdcccf69ee3febac3b9488c9a1a151f5d0ceb4d0bd2f805b6b7bdc05bbd971"
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
      Tune Server v0.8.311 (Rust) installed!

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
