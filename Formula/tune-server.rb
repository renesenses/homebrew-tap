class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.310"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.310/tune-server-v0.8.310-macos-aarch64.tar.gz"
      sha256 "fbf4a403105e68d3eb426c0b0cae678678ad2a107a45e2014ce1b8922dd34089"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.310/tune-server-v0.8.310-macos-x86_64.tar.gz"
      sha256 "2e5eeff097a0f5e9b32a8ada746016a447822d1f87eb8bf69b138e5931f64139"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.310/tune-server-v0.8.310-linux-aarch64.tar.gz"
      sha256 "3f545b75f5cd3b99a1c5c72d7b1499f77a1b5717ffa22c40cb9635f526a9b314"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.310/tune-server-v0.8.310-linux-x86_64.tar.gz"
      sha256 "26cd0bf75e98304cba0ef0de7727dd2fa5fc93a9108fb211a7ef5db5e010ed13"
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
      Tune Server v0.8.310 (Rust) installed!

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
