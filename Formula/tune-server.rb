class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.352"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.352/tune-server-v0.8.352-macos-aarch64.tar.gz"
      sha256 "e3643479310d9051a92904d10109a790cea034c5e5483b3ddb88f90ab96ecac4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.352/tune-server-v0.8.352-macos-x86_64.tar.gz"
      sha256 "fcb659473671470cea2ce8f059a566764d284ae53e7b1b2d0a74d30476c590e9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.352/tune-server-v0.8.352-linux-aarch64.tar.gz"
      sha256 "c9f45b185f7f19fba33331563e2d47a25d48520e771498418201f3f236f4604c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.352/tune-server-v0.8.352-linux-x86_64.tar.gz"
      sha256 "127b5ed6cbeb1d33f9e0d231e93e1dba7f0c9d6295a8b08f1f44e720a417f558"
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
      Tune Server v0.8.352 (Rust) installed!

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
