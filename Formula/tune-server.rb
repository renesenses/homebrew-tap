class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.139"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-macos-aarch64.tar.gz"
      sha256 "74ff119b875958c6eabebaf9056add30e88d0dcd5d29b9a1bef0ea02202165d9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-macos-x86_64.tar.gz"
      sha256 "2bb6a96cc28bc817b7837e478856bae6ae230b0950b7eb0e91a71536b45ea284"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-linux-aarch64.tar.gz"
      sha256 "519ee0a5e2b02e6490849048c00c9e4617966c3045b0e6a56a57a24eaa1f6b7d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-linux-x86_64.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
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
      Tune Server v0.8.139 (Rust) installed!

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
