class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.250"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.250/tune-server-v0.8.250-macos-aarch64.tar.gz"
      sha256 "e9d0d81ef504d97a25d952c25253ce8e1bd0443434c64d3b796e162a21a6d737"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.250/tune-server-v0.8.250-macos-x86_64.tar.gz"
      sha256 "7c10f86605c1bbffed764ebf990735992bfee6c065d60bdac66b1c7b928dcab8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.250/tune-server-v0.8.250-linux-aarch64.tar.gz"
      sha256 "baf3e17d80b9242c6ff96b39389981da2615ce2bfbf821920b6d42b3c42f6f44"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.250/tune-server-v0.8.250-linux-x86_64.tar.gz"
      sha256 "2865fe58ca64da5f3bf3773b6a3b2639df2a5714ad528071702ca3fc0a69d4f0"
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
      Tune Server v0.8.250 (Rust) installed!

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
