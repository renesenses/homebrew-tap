class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.165"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.165/tune-server-v0.8.165-macos-aarch64.tar.gz"
      sha256 "0a28d9207deea570684cdf1108989eaa173cbb652a75cef2e9823d593c31ea62"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.165/tune-server-v0.8.165-macos-x86_64.tar.gz"
      sha256 "4419c70e376de3afd074684604e9fd588eca3ffdc2a54b91a788c78b5877ada6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.165/tune-server-v0.8.165-linux-aarch64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000002"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.165/tune-server-v0.8.165-linux-x86_64.tar.gz"
      sha256 "ab777d7bbb770f6665b64a4378438a3b024db7d3f54ff420f13dc40fbea2f8f3"
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
      Tune Server v0.8.165 (Rust) installed!

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
