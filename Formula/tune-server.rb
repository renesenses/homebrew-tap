class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.265"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.265/tune-server-v0.8.265-macos-aarch64.tar.gz"
      sha256 "8a73ad14030141de3e3f4adb536ff74103141e4ab9fd450e8fe38fd95e9d158c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.265/tune-server-v0.8.265-macos-x86_64.tar.gz"
      sha256 "3e598103bf33d375493541ae63852665824aa05924e9333518012c5bfd4c9f0c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.265/tune-server-v0.8.265-linux-aarch64.tar.gz"
      sha256 "596b9310cfd92d929f6b36c43700c38cd05779c0b18d3209e93b90a808267c8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.265/tune-server-v0.8.265-linux-x86_64.tar.gz"
      sha256 "0bda1ba61425045e4b203816d25e23005e0bdecaf0b4b5562ecac5eb34c6443e"
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
      Tune Server v0.8.265 (Rust) installed!

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
