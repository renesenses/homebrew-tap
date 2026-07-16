class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.318"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.318/tune-server-v0.8.318-macos-aarch64.tar.gz"
      sha256 "0193933764733f6e2cddc309ee50400208a5da03508c62e873ada3e5f8631ece"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.318/tune-server-v0.8.318-macos-x86_64.tar.gz"
      sha256 "63a646a9392653d7ba98b278eb9b9fa38a593eb30c52154cd635222f3d858d56"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.318/tune-server-v0.8.318-linux-aarch64.tar.gz"
      sha256 "5ee0449a52218c914546dc5e594cecd1788f81d0f0fe21509f1396625b864569"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.318/tune-server-v0.8.318-linux-x86_64.tar.gz"
      sha256 "b7a64c87bd56c9bfde7cb73b0a36c770bfdc9baea3090582ccfa6733ad44a018"
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
      Tune Server v0.8.318 (Rust) installed!

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
