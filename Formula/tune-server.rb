class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.143"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-macos-aarch64.tar.gz"
      sha256 "461be9a85b14f26a93b693cf955be002de3fdf21fddcbe5110394d1a0dc0cf12"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-macos-x86_64.tar.gz"
      sha256 "cd8f04de015c63b8c91232971c2d563a1788a5f9aaf29e712f61138205cd93c3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-linux-aarch64.tar.gz"
      sha256 "ac0f92fb3e5ac6d296157d799d5d990da806e3f6fb0764f2eabc860b7809fe6e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-linux-x86_64.tar.gz"
      sha256 "0f9158a71ee87c2edac7bef1692fb45a64060c09fd034f28e1d0e6ea2d832cbc"
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
      Tune Server v0.8.143 (Rust) installed!

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
