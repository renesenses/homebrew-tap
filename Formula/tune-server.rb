class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.274"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.274/tune-server-v0.8.274-macos-aarch64.tar.gz"
      sha256 "1ead9a5154aa99b33a4f16ef062c2b048a9d913b83fc82e239a271543224a85c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.274/tune-server-v0.8.274-macos-x86_64.tar.gz"
      sha256 "723e716023511d5e7ab8f4ef1a076846cd4bc27ef81b6b5853f49e7fa7a3c715"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.274/tune-server-v0.8.274-linux-aarch64.tar.gz"
      sha256 "7940e6f3514a77d0ec330a7903f405df9dbb11077f87c644853c87b66d628175"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.274/tune-server-v0.8.274-linux-x86_64.tar.gz"
      sha256 "25bdfcb44dd360e983562c992903d183f1fc901e4427ff27fde985f92a88fd86"
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
      Tune Server v0.8.274 (Rust) installed!

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
