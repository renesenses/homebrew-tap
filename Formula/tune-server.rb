class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.295"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.295/tune-server-v0.8.295-macos-aarch64.tar.gz"
      sha256 "e3ecb88ae218d1f6a1bd6060f0754621c76e4edeb15d30e3796d84e077ecd302"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.295/tune-server-v0.8.295-macos-x86_64.tar.gz"
      sha256 "fcdf50f3f920cfd79dd7a7171aaf78f1f3a565da450a9ab0055fa4d92b8ee1a7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.295/tune-server-v0.8.295-linux-aarch64.tar.gz"
      sha256 "2c88d3b308cd502bb51129f8efddb99cf1ca052a89baddd24f5f7b087f9b8207"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.295/tune-server-v0.8.295-linux-x86_64.tar.gz"
      sha256 "7e81b2e5bdc4a714b450222c67e124e9900a6383986e2fa700ea692de7628363"
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
      Tune Server v0.8.295 (Rust) installed!

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
