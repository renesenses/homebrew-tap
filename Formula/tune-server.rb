class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.251"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.251/tune-server-v0.8.251-macos-aarch64.tar.gz"
      sha256 "26cbdd987e20101e7865a09faa336069372116911baab77298e00d6b4eb32094"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.251/tune-server-v0.8.251-macos-x86_64.tar.gz"
      sha256 "4158644ea892e5720b8237fb8c208fd1654ace6128edb7f197dcbf9c66514b38"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.251/tune-server-v0.8.251-linux-aarch64.tar.gz"
      sha256 "dd05964a0053b6502c3d0e3a45a6943fb567464492b98a2604eafba9f1382fc7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.251/tune-server-v0.8.251-linux-x86_64.tar.gz"
      sha256 "73da120dbc568ff36b6240bd9ba22d5863596752a3264067ea5b8c9024a03892"
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
      Tune Server v0.8.251 (Rust) installed!

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
