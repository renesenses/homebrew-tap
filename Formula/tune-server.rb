class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.277"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.277/tune-server-v0.8.277-macos-aarch64.tar.gz"
      sha256 "de016eec5f2eaef57e33d34fd3afc15f07716b32682cd54114d1b41c56a01316"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.277/tune-server-v0.8.277-macos-x86_64.tar.gz"
      sha256 "a0f2b44e4b44fe4bcef3cf713cc71c73bc366daf67156b558c59ee0096662f20"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.277/tune-server-v0.8.277-linux-aarch64.tar.gz"
      sha256 "616f6f8f02071105bac65fdac56875be94664f5832d127e21c1b69c2e1d9dd1d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.277/tune-server-v0.8.277-linux-x86_64.tar.gz"
      sha256 "db452e83227c5981cffe92f90aff75a4b4b6364e604beb98b6d1921a8046ae64"
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
      Tune Server v0.8.277 (Rust) installed!

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
