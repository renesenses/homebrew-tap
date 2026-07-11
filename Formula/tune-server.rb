class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.296"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.296/tune-server-v0.8.296-macos-aarch64.tar.gz"
      sha256 "616284fe9898c1959dbada01c6df118d2ffaded60a0c8b5d3c7a23d95fc87fac"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.296/tune-server-v0.8.296-macos-x86_64.tar.gz"
      sha256 "905f9c1956fe26a37937150d05c2ee9c48feff048ea6619ffb8566a93a852739"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.296/tune-server-v0.8.296-linux-aarch64.tar.gz"
      sha256 "159a4d45d3fb4c212ebc74904196e68fe23116e38bf870301b3b013f6e7a9468"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.296/tune-server-v0.8.296-linux-x86_64.tar.gz"
      sha256 "65e6b917b2968dee85437bff24a27ab566fcd12d698a3dfb1df84487302df1b8"
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
      Tune Server v0.8.296 (Rust) installed!

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
