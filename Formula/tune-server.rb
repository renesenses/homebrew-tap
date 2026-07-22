class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.359"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.359/tune-server-v0.8.359-macos-aarch64.tar.gz"
      sha256 "c84c75a5def43288818c51ce84bbaee4ba1933bf31f86119d88b824d5983e657"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.359/tune-server-v0.8.359-macos-x86_64.tar.gz"
      sha256 "8c52335477b27fdc6ea85aef8cfdf7d1552180c8f17010dee7fb1b67a368e1e0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.359/tune-server-v0.8.359-linux-aarch64.tar.gz"
      sha256 "3a9c8165ea9f3f7c2d84ab5820e3dccd274e28598ada5571eeb8f2eac85ae284"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.359/tune-server-v0.8.359-linux-x86_64.tar.gz"
      sha256 "5adc8f58c00cb1299686622badb5f4de204a873e6dd8e8b3817ee05efe28373c"
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
      Tune Server v0.8.359 (Rust) installed!

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
