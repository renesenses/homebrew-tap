class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.147"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-macos-aarch64.tar.gz"
      sha256 "2f94d2d0007f985bddeb9e20e75112999bc4ae0d4d5ef9453fa48e093b1f286a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-macos-x86_64.tar.gz"
      sha256 "205de7678d0394c34051e1947c98ffa2f4fc95b88da8252738b7f8037ed8e39f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-linux-aarch64.tar.gz"
      sha256 "f1b690ee2f741e00d45fdff1d64963c3b4f4ded745734abee1aae2751df7b5a1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-linux-x86_64.tar.gz"
      sha256 "63840042de8332b6337241e6101efd154879576942a2a8958fba56f084e63b5b"
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
      Tune Server v0.8.147 (Rust) installed!

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
