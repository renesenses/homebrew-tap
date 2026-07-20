class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.346"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.346/tune-server-v0.8.346-macos-aarch64.tar.gz"
      sha256 "71acaebfb1117f048e8100ee3c395a76fa7e471c08c8e4b558a02ffcb7ba535e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.346/tune-server-v0.8.346-macos-x86_64.tar.gz"
      sha256 "4172817c28808fec1d1534670395ccb326782331f0ce014cb021a68102ec5195"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.346/tune-server-v0.8.346-linux-aarch64.tar.gz"
      sha256 "3978afea39491ec6eb52e02e2474be9c49676f4a5119fda3d1992c8a84813c38"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.346/tune-server-v0.8.346-linux-x86_64.tar.gz"
      sha256 "67e65fc09cf44d8bc550d47037acefa6f7258ea99a39767362348ae50bafc1f8"
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
      Tune Server v0.8.346 (Rust) installed!

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
