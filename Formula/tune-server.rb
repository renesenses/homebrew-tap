class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.358"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.358/tune-server-v0.8.358-macos-aarch64.tar.gz"
      sha256 "618c52051e77057fd73d4ba998e22314728e698ed8a182f00059870ec84321d9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.358/tune-server-v0.8.358-macos-x86_64.tar.gz"
      sha256 "a3b0745494266d39d7b99b2bb172cabd5e7bb02e5c9cf918ef990a3ddb94c793"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.358/tune-server-v0.8.358-linux-aarch64.tar.gz"
      sha256 "4f5bce0c1e955aebe128a8b92af796085bfa2d7b58e008a553620baa0f004948"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.358/tune-server-v0.8.358-linux-x86_64.tar.gz"
      sha256 "ba6799f73f4c0f2565d85f00749511995d4934f4cfe36941dfd44ca6ff0a9c37"
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
      Tune Server v0.8.358 (Rust) installed!

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
