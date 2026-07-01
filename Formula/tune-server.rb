class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.223"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.223/tune-server-v0.8.223-macos-aarch64.tar.gz"
      sha256 "bbc195703066d7d91bac967472b485572d7f2559f7311f455e3a0c9b489ca1ad"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.223/tune-server-v0.8.223-macos-x86_64.tar.gz"
      sha256 "1081c89beb78eefd2d07ec1bfd2dea040439b0081d23992ef903a75d8932e497"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.223/tune-server-v0.8.223-linux-aarch64.tar.gz"
      sha256 "21a837933f1ed18963d1e3deffd6c5aca0d41838add42c6b1d2b3954912b94ea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.223/tune-server-v0.8.223-linux-x86_64.tar.gz"
      sha256 "c048b4f634a34e3302cc184c76b272db713de2df165b2b0c9838ab8acf2206cc"
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
      Tune Server v0.8.223 (Rust) installed!

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
