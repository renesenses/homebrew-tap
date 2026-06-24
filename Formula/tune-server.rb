class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.162"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.162/tune-server-v0.8.162-macos-aarch64.tar.gz"
      sha256 "f9694dd4a7b37766160b9823142242ddf03b1d940a8cbcf68114ca47f8722cac"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.162/tune-server-v0.8.162-macos-x86_64.tar.gz"
      sha256 "5000c8494bba8a39df3c04ac1642795d052b0539abdbb6fa858d18753f4f6642"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.162/tune-server-v0.8.162-linux-aarch64.tar.gz"
      sha256 "1e32a14d10400119b8e68bf5e05ecca50efb04c21e74131eaa2227481da21169"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.162/tune-server-v0.8.162-linux-x86_64.tar.gz"
      sha256 "f9d2db157eb6a01a620fa333209c08c07d39dd5d82ccc67f2e14aebc4f80b95a"
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
      Tune Server v0.8.162 (Rust) installed!

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
