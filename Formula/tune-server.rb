class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.146"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.146/tune-server-v0.8.146-macos-aarch64.tar.gz"
      sha256 "563910130c881fd9b305ef2f8f8bed2e007bc1b98d0c1dbf93a92557e55bded6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.146/tune-server-v0.8.146-macos-x86_64.tar.gz"
      sha256 "fc121022d2e1986dbf8483a2c119427d120afcee5affc567166833283a1ad53f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.146/tune-server-v0.8.146-linux-aarch64.tar.gz"
      sha256 "1df16923ba93c5be2273b4e50d10a42b896acb912a48ee55f8160e0e878cac2e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.146/tune-server-v0.8.146-linux-x86_64.tar.gz"
      sha256 "fd25baf60c4a281a084476ded0fc99eef8e994e49dde31dc3eeef8d5e2029bd4"
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
      Tune Server v0.8.146 (Rust) installed!

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
