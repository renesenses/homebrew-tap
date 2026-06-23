class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.156"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.156/tune-server-v0.8.156-macos-aarch64.tar.gz"
      sha256 "db7fa95e455bf5d7b9a7e358f888b81ca3983ef0064d553c357a581f1ffd7bf6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.156/tune-server-v0.8.156-macos-x86_64.tar.gz"
      sha256 "90661d600b411b6d92fd33ef4c0bde68973bad13efce4cbdbed75ca8d96e45bc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.156/tune-server-v0.8.156-linux-aarch64.tar.gz"
      sha256 "887c7d2730b7b09aa98cb0a4ab4e8b7824627e5fba226709280c973fead23dcf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.156/tune-server-v0.8.156-linux-x86_64.tar.gz"
      sha256 "38ea559c5b381465a13dc5c9de1c10661d2cad967be8d7ef3581f88ce5f2583f"
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
      Tune Server v0.8.156 (Rust) installed!

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
