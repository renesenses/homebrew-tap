class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.233"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.233/tune-server-v0.8.233-macos-aarch64.tar.gz"
      sha256 "4472f46a2268b1b532916922d592c8fab62b1a24b288f8a9115ba59bb66ca736"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.233/tune-server-v0.8.233-macos-x86_64.tar.gz"
      sha256 "697537ceeb7bef2803f91b184758d125ce5c76452cdb3b8c8fc0cf6abaebe0e2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.233/tune-server-v0.8.233-linux-aarch64.tar.gz"
      sha256 "12c55a8e354717357918ff7e7996fb9cca50ad326a43810a9dc0b8608504b15e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.233/tune-server-v0.8.233-linux-x86_64.tar.gz"
      sha256 "e237753bb89b0e1a60b86c30b1a31ba48ddada49e7358348796bf38bae07041a"
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
      Tune Server v0.8.233 (Rust) installed!

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
