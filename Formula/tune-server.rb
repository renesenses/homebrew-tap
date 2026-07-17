class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.328"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.328/tune-server-v0.8.328-macos-aarch64.tar.gz"
      sha256 "ee3d858dff2f7869252ee6afdbc118ef3d669548c70906bde9a44497b13a79ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.328/tune-server-v0.8.328-macos-x86_64.tar.gz"
      sha256 "8bcd15d77e485887693acd87d09dc9b56ca4eb3cf3b6f07e6c492fc0902743fa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.328/tune-server-v0.8.328-linux-aarch64.tar.gz"
      sha256 "a7a8ed929ad2b9ee3db14c9c32b362dfe79e0e771f9cd998ee53e684ec765e8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.328/tune-server-v0.8.328-linux-x86_64.tar.gz"
      sha256 "5228f4dc0be89bad5ced4682a60925468660e1c5ab131879d309aa9a81a737c7"
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
      Tune Server v0.8.328 (Rust) installed!

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
