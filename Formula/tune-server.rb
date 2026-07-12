class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.299"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.299/tune-server-v0.8.299-macos-aarch64.tar.gz"
      sha256 "446f9d33c67901f2e926ccfae39c482ed065147449e3c2bc4acceb35706f875d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.299/tune-server-v0.8.299-macos-x86_64.tar.gz"
      sha256 "8121da208c48bf041a3d858bcfb7a12801691b896f8b4c2050b3a3af7b21a962"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.299/tune-server-v0.8.299-linux-aarch64.tar.gz"
      sha256 "9eb7ae4e84f3d5d5ffc72be3d732e57c353f8030a0dcd1242c39a10978788a5b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.299/tune-server-v0.8.299-linux-x86_64.tar.gz"
      sha256 "34018c16fa25377e63a9e93ead7c38466e5711eeee4ad3f8031faa000dfb61fa"
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
      Tune Server v0.8.299 (Rust) installed!

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
