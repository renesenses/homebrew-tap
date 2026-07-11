class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.298"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.298/tune-server-v0.8.298-macos-aarch64.tar.gz"
      sha256 "0a2895371769c2f49c2131639d6995c41e7d387c291cf455e31a4144652bf761"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.298/tune-server-v0.8.298-macos-x86_64.tar.gz"
      sha256 "5fba0c9db9559ee6f0e0a87a33c035cd791840646f02c88f5e45dda5de917700"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.298/tune-server-v0.8.298-linux-aarch64.tar.gz"
      sha256 "2ee44d3c1b7af385e7f68e522557d021c08190db2063f826b7a489decc528484"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.298/tune-server-v0.8.298-linux-x86_64.tar.gz"
      sha256 "241ce0e733f8aaa2fea5789439cf5bb20cc547b891e7fe984a8837311491d218"
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
      Tune Server v0.8.298 (Rust) installed!

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
