class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.263"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.263/tune-server-v0.8.263-macos-aarch64.tar.gz"
      sha256 "7d01d224ce76d15fa7d5a9a1005e4e113667778a1f4c49d3bbb12151bd249f11"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.263/tune-server-v0.8.263-macos-x86_64.tar.gz"
      sha256 "70ded25865ce387bb6c42ab96a154e89cff5dd3239a97b08fa352c723c9893f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.263/tune-server-v0.8.263-linux-aarch64.tar.gz"
      sha256 "86454ea1999e5c0c83692ea398251651eec7cbca46716114723a644352eeca30"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.263/tune-server-v0.8.263-linux-x86_64.tar.gz"
      sha256 "cf22bdeccecb481758ac88b73c46561058b623e54c21f1a5924d1fb85b171eb9"
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
      Tune Server v0.8.263 (Rust) installed!

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
