class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.228"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.228/tune-server-v0.8.228-macos-aarch64.tar.gz"
      sha256 "617da73e63cd0af3a1548db72feb33474cf5607a9de8078d31687002755fc1eb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.228/tune-server-v0.8.228-macos-x86_64.tar.gz"
      sha256 "584332026b7054233080fcf3428e32f101f4443e25e90608ef500a97d1e19c1a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.228/tune-server-v0.8.228-linux-aarch64.tar.gz"
      sha256 "c0594c051ae3e5c81954eda8ca3be01bf1cb8015f3d9ff3cb19a46866ed5f582"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.228/tune-server-v0.8.228-linux-x86_64.tar.gz"
      sha256 "8d3a6c5bf3e788bb39595b45f6aac7983907dd33d1d1e21b900c3a01b5e20b99"
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
      Tune Server v0.8.228 (Rust) installed!

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
