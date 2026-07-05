class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.262"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.262/tune-server-v0.8.262-macos-aarch64.tar.gz"
      sha256 "0063bea4554d876b18926260b141537ecbb61f528b2a857b7db2252dc198cd94"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.262/tune-server-v0.8.262-macos-x86_64.tar.gz"
      sha256 "a2cf9176d6eade3c8f84c0db355cce3db09ae5e58dbfefec889edea318f29a39"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.262/tune-server-v0.8.262-linux-aarch64.tar.gz"
      sha256 "845248dcd146d6d9531d1365033bd012291a6cf51e4bc8bd9279fa1740fb8978"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.262/tune-server-v0.8.262-linux-x86_64.tar.gz"
      sha256 "a4f903bb9d4edfc75477f87e4e8faa0b36d6dcff0fad2248a098eea3af6ce261"
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
      Tune Server v0.8.262 (Rust) installed!

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
