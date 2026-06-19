class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.140"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.140/tune-server-v0.8.140-macos-aarch64.tar.gz"
      sha256 "842916be2730107bdfecf65b9113ff5cc2d9920c449b657b203bbe1b5a09f679"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.140/tune-server-v0.8.140-macos-x86_64.tar.gz"
      sha256 "a9e0a21e8914a4ef16773e8a8da8101805f992c9b80584d6c1d529c44c5887b8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.140/tune-server-v0.8.140-linux-aarch64.tar.gz"
      sha256 "04d08a9c3cad508d1232aed1d89668bc6a52af8e14dfb10358f746854714e4b0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.140/tune-server-v0.8.140-linux-x86_64.tar.gz"
      sha256 "8dcb0020c7c89b4aaa675b498489e9da3c0ee6e3da7720826abb9d0cd7c0d357"
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
      Tune Server v0.8.140 (Rust) installed!

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
