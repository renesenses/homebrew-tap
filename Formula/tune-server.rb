class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.220"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.220/tune-server-v0.8.220-macos-aarch64.tar.gz"
      sha256 "968db776431a31de07ad92b578391e6287d69be2c382ab34fadfa26e32aa8006"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.220/tune-server-v0.8.220-macos-x86_64.tar.gz"
      sha256 "5b1fe63fadf6d4e4d2bcf56483fec9de24d0fc636da0d3e899678d0d7eab6db1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.220/tune-server-v0.8.220-linux-aarch64.tar.gz"
      sha256 "135e6728aa3a636760ce98958654f508a2740e0a1575083a42b9c45de89205d8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.220/tune-server-v0.8.220-linux-x86_64.tar.gz"
      sha256 "cfb354e994ceed5af6111ec0ea91cfcd072eeb8e10dd2380e562804620576604"
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
      Tune Server v0.8.220 (Rust) installed!

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
