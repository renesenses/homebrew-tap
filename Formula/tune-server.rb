class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.236"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.236/tune-server-v0.8.236-macos-aarch64.tar.gz"
      sha256 "fcdbe09cd6fac8b3119d5996afb14a8ab8bd08519e2f87f2474e2781cedbb57e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.236/tune-server-v0.8.236-macos-x86_64.tar.gz"
      sha256 "a6522d6330b0a57ba46f0afe858bcc32e069baeb82c1e76775dece3b2d49bbcf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.236/tune-server-v0.8.236-linux-aarch64.tar.gz"
      sha256 "6a1494035f0910d00827d72cf45713380b6f97fb9f470fb499b64b84cb1d136f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.236/tune-server-v0.8.236-linux-x86_64.tar.gz"
      sha256 "273eb53c1411120d69e6c9f5bfe5ad89ef30d6ffbd2b229ee5fe14420a988e04"
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
      Tune Server v0.8.236 (Rust) installed!

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
