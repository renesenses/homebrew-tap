class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.347"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.347/tune-server-v0.8.347-macos-aarch64.tar.gz"
      sha256 "bb62901c0fd3ad80f10169d59e5819cffce9540eb0d0b981f357942e88bd1860"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.347/tune-server-v0.8.347-macos-x86_64.tar.gz"
      sha256 "029ac1c6f1c2ed888f8ccec14ec5edf5ea48c12d3e24ec70c3158e54cff18f22"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.347/tune-server-v0.8.347-linux-aarch64.tar.gz"
      sha256 "a74e918ceb6bf20cfb65a9e440a93b75fc6df1a6dedb2a2707dd1621fb2ced73"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.347/tune-server-v0.8.347-linux-x86_64.tar.gz"
      sha256 "8d65189997b0f7e9db075debf6cb728e2a205158ad5e57eea68f39d6c1e875f7"
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
      Tune Server v0.8.347 (Rust) installed!

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
