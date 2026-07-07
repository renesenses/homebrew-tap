class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.282"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.282/tune-server-v0.8.282-macos-aarch64.tar.gz"
      sha256 "65175114646e0ddd08f124fa80060e1638bd907844cb4029fd6af295e1d4664f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.282/tune-server-v0.8.282-macos-x86_64.tar.gz"
      sha256 "3a2a896cbf202b1552caac2fdb294a8ae2c6ba1868cbc598248f4c205557f506"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.282/tune-server-v0.8.282-linux-aarch64.tar.gz"
      sha256 "264a65ffdda8ed31c842c4d163123aac31dc45c68b6cf0dfbcc6aadd04773007"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.282/tune-server-v0.8.282-linux-x86_64.tar.gz"
      sha256 "6b65c96b683f3b92dfdb0997b44554a058f2c5501e5c93be97405d533d79e2c3"
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
      Tune Server v0.8.282 (Rust) installed!

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
