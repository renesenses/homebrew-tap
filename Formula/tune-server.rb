class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.340"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.340/tune-server-v0.8.340-macos-aarch64.tar.gz"
      sha256 "033393d7aedcab79955426f144dbd6b0f2bdde847aa3e670b3b6c7cc675242cc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.340/tune-server-v0.8.340-macos-x86_64.tar.gz"
      sha256 "3d45d93ad803d3a6fadf339e79b5d6f894962fd05752abd38b4135485a7cd8a8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.340/tune-server-v0.8.340-linux-aarch64.tar.gz"
      sha256 "0463e627d88372eb18e6f7e05ca0d70c49c0992ebb20105469cd2f02cc3d623a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.340/tune-server-v0.8.340-linux-x86_64.tar.gz"
      sha256 "9fea81ce1610fc4ae0113620267e30fa351060b411238cbf27ceda6bcda7703b"
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
      Tune Server v0.8.340 (Rust) installed!

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
