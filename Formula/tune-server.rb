class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.225"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.225/tune-server-v0.8.225-macos-aarch64.tar.gz"
      sha256 "27b5c87d3823578a99e78032d559c76d47d34ef9571ff327f5c59162f5231eec"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.225/tune-server-v0.8.225-macos-x86_64.tar.gz"
      sha256 "90eaeb84f3b6279e20abd0659c252e4aca37416e5cb35860e959b2ac68ae5f2a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.225/tune-server-v0.8.225-linux-aarch64.tar.gz"
      sha256 "827c89f55ce821bc01d723ef8b41af8affdeecaf7b7f2453c17af467bc4e421f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.225/tune-server-v0.8.225-linux-x86_64.tar.gz"
      sha256 "ef651bdc902cb9c5faab7820a1a406b44167277a403c6caecec0a622462fb657"
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
      Tune Server v0.8.225 (Rust) installed!

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
