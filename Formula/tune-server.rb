class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.166"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.166/tune-server-v0.8.166-macos-aarch64.tar.gz"
      sha256 "d0030ac1338a9128dc0a25e753e5161444f6eef7dbac2df601dc8503bb5e34b4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.166/tune-server-v0.8.166-macos-x86_64.tar.gz"
      sha256 "6b30c6238e8922cd696f197613e17f112412bf28c0ca4c785d3055fc4bf6edc2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.166/tune-server-v0.8.166-linux-aarch64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000003"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.166/tune-server-v0.8.166-linux-x86_64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000004"
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
      Tune Server v0.8.166 (Rust) installed!

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
