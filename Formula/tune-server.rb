class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.211"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.211/tune-server-v0.8.211-macos-aarch64.tar.gz"
      sha256 "f60e21fda8344e8be900f46a24365c07ed234283b44006fe5270e65c1130d2a8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.211/tune-server-v0.8.211-macos-x86_64.tar.gz"
      sha256 "231d963db2348ddb857d6fa57ea7ac61022ec2111759edd4b00cbb0ccad307e1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.211/tune-server-v0.8.211-linux-aarch64.tar.gz"
      sha256 "96680ece020aeb5664d4c2fc30e1cc7ab84c0c1621d7423c5ecf7998c61e6525"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.211/tune-server-v0.8.211-linux-x86_64.tar.gz"
      sha256 "9251ca8fbe0980b4f3b8f44acc179e275c409c3bdc5da94466b64253ffe18ecb"
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
      Tune Server v0.8.211 (Rust) installed!

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
