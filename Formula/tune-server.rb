class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.313"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.313/tune-server-v0.8.313-macos-aarch64.tar.gz"
      sha256 "a4763eb5c7e878ec7e0d3193490eb98e7b4fdc74e65567d748eb99fb3e87188d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.313/tune-server-v0.8.313-macos-x86_64.tar.gz"
      sha256 "e7a0aab94c59ad6eff73f63b62ee62ffb8aa6a65f2cc34dd235bbc9019c42895"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.313/tune-server-v0.8.313-linux-aarch64.tar.gz"
      sha256 "ba52fd860ece7de06d0c1280adda84bde4942f22c4b9f213aed8cbc68bc11fd8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.313/tune-server-v0.8.313-linux-x86_64.tar.gz"
      sha256 "de30be47f13df7b1f4f22b47c77caed97e38de337191edb5052a1b3e3981fcfd"
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
      Tune Server v0.8.313 (Rust) installed!

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
