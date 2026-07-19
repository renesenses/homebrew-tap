class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.345"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.345/tune-server-v0.8.345-macos-aarch64.tar.gz"
      sha256 "8349132575208f717d370c3f9f38b2f6af1886a98d9313ca200eb4180dac9cdf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.345/tune-server-v0.8.345-macos-x86_64.tar.gz"
      sha256 "05ccade3bc0a47712ca3a80f732c56c525dfbd9fb1901f7c7eb06368e10d13f5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.345/tune-server-v0.8.345-linux-aarch64.tar.gz"
      sha256 "c8788f43cb003127b099adf2d74062dd6bc09ff807347e5e58a639d9d069f4f1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.345/tune-server-v0.8.345-linux-x86_64.tar.gz"
      sha256 "33f17d75c214d66b510b7c63c23cec1f92372543c6541851859e0059f0b87f9d"
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
      Tune Server v0.8.345 (Rust) installed!

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
