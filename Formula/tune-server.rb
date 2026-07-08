class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.283"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.283/tune-server-v0.8.283-macos-aarch64.tar.gz"
      sha256 "e0c23923c8f225a87acbb33621178357a3a6333b16ba35bca2a196f465cc4968"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.283/tune-server-v0.8.283-macos-x86_64.tar.gz"
      sha256 "f255129c577ea4569e4526ef68e91f5012d85da08535433f8559628b4b16b3bd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.283/tune-server-v0.8.283-linux-aarch64.tar.gz"
      sha256 "703d229d5836884b4f8061571bb6ddaefcb00a490543ab06b4f862771a0a1b7a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.283/tune-server-v0.8.283-linux-x86_64.tar.gz"
      sha256 "5b7c66577ee0c2ab8848970fe40acc057de938dbd86cd6d58c8469d8d043e5dd"
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
      Tune Server v0.8.283 (Rust) installed!

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
