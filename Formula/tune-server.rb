class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.160"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.160/tune-server-v0.8.160-macos-aarch64.tar.gz"
      sha256 "0084ec6473235bec5d0da4e2daa0614c40eb446337b4772ca208974fe767d3f1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.160/tune-server-v0.8.160-macos-x86_64.tar.gz"
      sha256 "9b3fddd5a96946b1ecda0ae99a55cc963f272b10f09760627bd12f012702a850"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.160/tune-server-v0.8.160-linux-aarch64.tar.gz"
      sha256 "1e32a14d10400119b8e68bf5e05ecca50efb04c21e74131eaa2227481da21169"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.160/tune-server-v0.8.160-linux-x86_64.tar.gz"
      sha256 "40bc399fab5f4973ee317f14d0bedf483254f9e4a05a10c0be46441cde1773e7"
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
      Tune Server v0.8.160 (Rust) installed!

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
