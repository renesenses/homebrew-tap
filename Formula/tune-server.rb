class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.137"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.137/tune-server-v0.8.137-macos-aarch64.tar.gz"
      sha256 "357a49456ce5f4dacfecee2b301f097163cd7327950f6ec17fedb39d99ad4ad1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.137/tune-server-v0.8.137-macos-x86_64.tar.gz"
      sha256 "99a9b78860fd12721abda526afee1a5bbbb24c5431b5001de23229e2761a44f7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.137/tune-server-v0.8.137-linux-aarch64.tar.gz"
      sha256 "cd427f2b59af446ba5b35919e73339228567c2c59254e139f8eb3c633204664d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.137/tune-server-v0.8.137-linux-x86_64.tar.gz"
      sha256 "c063c8a60d3db5d446e51eb42853a27a7f021b8589bc0e3c51b40f16f193b7d0"
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
      Tune Server v0.8.137 (Rust) installed!

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
