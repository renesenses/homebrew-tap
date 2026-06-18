class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.138"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.138/tune-server-v0.8.138-macos-aarch64.tar.gz"
      sha256 "05e850669b1e3935653d6e6bc16e1d34c6669b700925c0ff854f72735bad9a6a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.138/tune-server-v0.8.138-macos-x86_64.tar.gz"
      sha256 "f261f8ff1f96512bbb5ba243e67c10d9b605e324d98bb20c1d171e5827b681a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.138/tune-server-v0.8.138-linux-aarch64.tar.gz"
      sha256 "b7e290795738b5645156e2b63245e9ed9f7434533256e0af5f4ec24887b897ca"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.138/tune-server-v0.8.138-linux-x86_64.tar.gz"
      sha256 "b380e72e6556d6dc7fb0925feaf8267191c8e77b7dbc1522a26a8344156067a5"
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
      Tune Server v0.8.138 (Rust) installed!

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
