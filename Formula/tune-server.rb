class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.155"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.155/tune-server-v0.8.155-macos-aarch64.tar.gz"
      sha256 "5d97ce4b82643e7fa0fc81fc34039610e56fa8569888b3e4a0c0c20c07ac2b58"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.155/tune-server-v0.8.155-macos-x86_64.tar.gz"
      sha256 "47acaabd29c3e2d25a1b721536b4693a3fb084c2426790326c7c783cd2e1dc33"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.155/tune-server-v0.8.155-linux-aarch64.tar.gz"
      sha256 "221959008b1189db83517083c843cf3c37a8c5482c96410df38ed17e3fc4d5a4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.155/tune-server-v0.8.155-linux-x86_64.tar.gz"
      sha256 "2e83a80f81efd5624c52dd5ebf16de041fdc911e86ee8e22f900dd82ade7a3e9"
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
      Tune Server v0.8.155 (Rust) installed!

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
