class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.183"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.183/tune-server-v0.8.183-macos-aarch64.tar.gz"
      sha256 "9a6a949458f333e7316492f6043f8e483b69e13fb35902c5a49761d5b31d95a3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.183/tune-server-v0.8.183-macos-x86_64.tar.gz"
      sha256 "82f54dc18260e6cfe4fa1aeddd5806789ccc960b62d860415fb5cbab9e0f290b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.183/tune-server-v0.8.183-linux-aarch64.tar.gz"
      sha256 "NO_ARM_LINUX_BUILD"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.183/tune-server-v0.8.183-linux-x86_64.tar.gz"
      sha256 "b1c1d4132c5c95bfd705cbe5c6562476a2b3d2a2c5a0bc6a06b68dc11d757043"
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
      Tune Server v0.8.183 (Rust) installed!

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
