class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.331"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.331/tune-server-v0.8.331-macos-aarch64.tar.gz"
      sha256 "4370454071701bea955c192e9acb6de42f3c626d34c915f72827c53ed7fe4293"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.331/tune-server-v0.8.331-macos-x86_64.tar.gz"
      sha256 "d503648fd1b436a768a3b54c8ba58ed8ad761e19f4f174e78fba184b70caf489"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.331/tune-server-v0.8.331-linux-aarch64.tar.gz"
      sha256 "5fdc279cbf6464050c872128b7c53a15a7489c16a33a802edf6e4d47292cf68e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.331/tune-server-v0.8.331-linux-x86_64.tar.gz"
      sha256 "8fc25230311c0343f7e331fc2c90ae9fadc24e3b79b7acfb8da66fbe420889c9"
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
      Tune Server v0.8.331 (Rust) installed!

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
