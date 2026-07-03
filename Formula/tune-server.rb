class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.242"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.242/tune-server-v0.8.242-macos-aarch64.tar.gz"
      sha256 "0dafc395a3d894d9d63b1ebc719f07c9ff2b00601293858e885c203ab078a417"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.242/tune-server-v0.8.242-macos-x86_64.tar.gz"
      sha256 "e103551b4d22684596ca122d75aad7b002bb8cac99f3483bf28d05faa38a7ac9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.242/tune-server-v0.8.242-linux-aarch64.tar.gz"
      sha256 "28eff289f82dbf39c217f5eea28c175fc8cca3cfd1d6ce5d4865f9e9146045de"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.242/tune-server-v0.8.242-linux-x86_64.tar.gz"
      sha256 "7c2264fe5f3deb2e45397c26b88b18e49821f3474fdd12471641c192b2801f61"
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
      Tune Server v0.8.242 (Rust) installed!

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
