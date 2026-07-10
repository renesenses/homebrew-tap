class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.291"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.291/tune-server-v0.8.291-macos-aarch64.tar.gz"
      sha256 "ed953b34692c00f14d41402a8eb01f709f12b4739e4c73a437379afdb135faef"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.291/tune-server-v0.8.291-macos-x86_64.tar.gz"
      sha256 "667f06a9998326fb730be7ccad2e40c1e612f5687dd3a3ac3b4c9b77ef76a669"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.291/tune-server-v0.8.291-linux-aarch64.tar.gz"
      sha256 "e5c9e688767fe98fcb6f13c1814c64a6b54dce7130541f73033d6b4e92e4acf5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.291/tune-server-v0.8.291-linux-x86_64.tar.gz"
      sha256 "71a825e04095b1445e4a7cd1c5978592b79bcbbd8a4087a3d970108765c11c1e"
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
      Tune Server v0.8.291 (Rust) installed!

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
