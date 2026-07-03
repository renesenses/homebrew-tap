class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.246"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.246/tune-server-v0.8.246-macos-aarch64.tar.gz"
      sha256 "71e6bced18b492aba38d9cb121562286b16c0aa534b9538e62f9d17add6188c7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.246/tune-server-v0.8.246-macos-x86_64.tar.gz"
      sha256 "7c5200f200fdd2f795bff6df788bbfd3d0c4387e18a63f079a91d9e2c77a73f3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.246/tune-server-v0.8.246-linux-aarch64.tar.gz"
      sha256 "0fe07bbafae8b404bc3e1e7d8f07a715d0f1fe51d3efbe641c23af29d2fb1ff3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.246/tune-server-v0.8.246-linux-x86_64.tar.gz"
      sha256 "177fbafcc380e7ce562c5c15c00f71155e3e46c16525c84f0ef4b9c42c68a6f5"
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
      Tune Server v0.8.246 (Rust) installed!

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
