class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.302"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.302/tune-server-v0.8.302-macos-aarch64.tar.gz"
      sha256 "8fef68d1fb21a7cb9761a2f1c4268ce10711ab93cd4bfdbd59996185821b7842"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.302/tune-server-v0.8.302-macos-x86_64.tar.gz"
      sha256 "a376ecc7da0387a95d727e7bb4d0bc16ba5ee32d08be21fc5069ab99765024cf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.302/tune-server-v0.8.302-linux-aarch64.tar.gz"
      sha256 "2fc85c3aea9c7861a4686ae06f5bba19c33f4bfd49c42a7de2a7cf3df495a88c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.302/tune-server-v0.8.302-linux-x86_64.tar.gz"
      sha256 "9178fae9f45c869906d4f144252ff41f1b2880e4a12337bf598a25a15ba1aa21"
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
      Tune Server v0.8.302 (Rust) installed!

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
