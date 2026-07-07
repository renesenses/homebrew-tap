class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.278"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.278/tune-server-v0.8.278-macos-aarch64.tar.gz"
      sha256 "858f17399a9ec48554c446fb80785051938a1ebdbcae299181ff482b1b607871"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.278/tune-server-v0.8.278-macos-x86_64.tar.gz"
      sha256 "51dca023b74aab023ff414fe3c8c1a2750aa8358e21be2d34f32627150eb5974"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.278/tune-server-v0.8.278-linux-aarch64.tar.gz"
      sha256 "7895acd962847e4299c58202771a0a3ddcbb7e41545c901ed40eb19c78a03554"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.278/tune-server-v0.8.278-linux-x86_64.tar.gz"
      sha256 "dd59fbe1bafc79a8d651abdf54c7a1291f531de679e7e8fd63a36e79bc902bab"
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
      Tune Server v0.8.278 (Rust) installed!

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
