class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.349"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.349/tune-server-v0.8.349-macos-aarch64.tar.gz"
      sha256 "ef49ed141bc0ea32b8c96315ded173cdf18d32b8cb44c78c429e4dd66aa070ef"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.349/tune-server-v0.8.349-macos-x86_64.tar.gz"
      sha256 "73e14fe3e40a5d50946701164d75a531ea9c23e02ba04b7f72e10cd12cfd6d0d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.349/tune-server-v0.8.349-linux-aarch64.tar.gz"
      sha256 "2a448f708e57f4252714b9a51692f8144075554ea0c73cb4bd728595d98c1920"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.349/tune-server-v0.8.349-linux-x86_64.tar.gz"
      sha256 "218775d25110cc1b18300f80e6fe6ed0973dc5cad7c5746f1eb4e636fbee85ce"
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
      Tune Server v0.8.349 (Rust) installed!

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
