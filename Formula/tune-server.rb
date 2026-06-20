class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.147"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-macos-aarch64.tar.gz"
      sha256 "851780e4d3ed588d7a9884a45d9c8537b4febf3e0f2ef1bcb2b432f5c1ea3278"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-macos-x86_64.tar.gz"
      sha256 "b31e3fd56f19ff285bdae5b339c521bed3a9a69288a9aa2c5ed3a468a72af65d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-linux-aarch64.tar.gz"
      sha256 "2cfa38ff134d7802f4009fbe14ab65f6c0472951d022933da222db23709454b0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.147/tune-server-v0.8.147-linux-x86_64.tar.gz"
      sha256 "f9747423889a8a43349f1c96b2334bb4d7c00f0823c34903091d395ca6efcfd3"
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
      Tune Server v0.8.147 (Rust) installed!

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
