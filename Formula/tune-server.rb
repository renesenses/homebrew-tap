class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.213"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.213/tune-server-v0.8.213-macos-aarch64.tar.gz"
      sha256 "fd8db61bbd103cc0509d519ce528139342618d3a444def2d37b3155fc4bdc7af"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.213/tune-server-v0.8.213-macos-x86_64.tar.gz"
      sha256 "95be1fdd8f6a3f7020d19f1a91b613902dcc7c521db59d3635e6de4f919f6000"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.213/tune-server-v0.8.213-linux-aarch64.tar.gz"
      sha256 "49e9ae3fb5525a32d25a0d56bdf72d8c6f2c26c1d0980069adbaf1336e0d33bd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.213/tune-server-v0.8.213-linux-x86_64.tar.gz"
      sha256 "7203b92ff8df4e53576011b3ae307ad13d2ef668d9e3c3881fcf13c02e78d074"
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
      Tune Server v0.8.213 (Rust) installed!

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
