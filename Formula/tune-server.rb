class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.200"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-macos-aarch64.tar.gz"
      sha256 "6a101f1299d25ec13d67a95d1503fdbd0011c96b579523463cef060d9a55ec40"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-macos-x86_64.tar.gz"
      sha256 "d89af8c0694a535816ef02e5a420aa6672a622fc22b74ddce52580dfb95b89d3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-linux-aarch64.tar.gz"
      sha256 "NO_ARM_LINUX_BUILD"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-linux-x86_64.tar.gz"
      sha256 "93a483a266f49df5d734084c8dd59ca71b7193029700f0cd14b2ab99350e5341"
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
      Tune Server v0.8.200 (Rust) installed!

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
