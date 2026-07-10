class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.286"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.286/tune-server-v0.8.286-macos-aarch64.tar.gz"
      sha256 "b20b5a1fde5efdc6d6f1218be3bde1c2a411dd0f70255452ea439250d533a1e6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.286/tune-server-v0.8.286-macos-x86_64.tar.gz"
      sha256 "175cdde365b340cdc3f93c7ddd9a391afffd4d0488da97a088316705c7b90c15"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.286/tune-server-v0.8.286-linux-aarch64.tar.gz"
      sha256 "dda6c4279d834ac89122af3436c87ef511f453bc2c2bf06d3c4bbab1d67d8f37"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.286/tune-server-v0.8.286-linux-x86_64.tar.gz"
      sha256 "e44c8fa6893c2bf796fcb65421274b896e0aa6d10b68c7b5955a8a194fdbced1"
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
      Tune Server v0.8.286 (Rust) installed!

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
