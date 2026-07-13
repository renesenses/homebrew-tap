class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.306"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.306/tune-server-v0.8.306-macos-aarch64.tar.gz"
      sha256 "d0606c995fdbcc3439a302d83a3f6793158b9f5a3e145a3646123c61f1aa4794"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.306/tune-server-v0.8.306-macos-x86_64.tar.gz"
      sha256 "b9cc6f0d9b1c3e7c81ea5aa7ddde9cd658b74fa030acfbddc63dc2a2f4cd0ce7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.306/tune-server-v0.8.306-linux-aarch64.tar.gz"
      sha256 "b2e345a9cd0d7aba8d6892f180817a1486a185e705d68c02aa3882d33fa38fab"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.306/tune-server-v0.8.306-linux-x86_64.tar.gz"
      sha256 "53e5168ff838511af1310d714fa2ce6ae86388c9d84ee8398dcdd1f89c56f13c"
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
      Tune Server v0.8.306 (Rust) installed!

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
