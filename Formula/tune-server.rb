class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.315"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.315/tune-server-v0.8.315-macos-aarch64.tar.gz"
      sha256 "5877db54626da03aec8c2fa79d6fa9ebaad546b779239e84c57cf88e582d1e6a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.315/tune-server-v0.8.315-macos-x86_64.tar.gz"
      sha256 "cdb49934ff6865f8b144c287fa3b019e7cebfab6272b33d8c74e4e7692f43e0a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.315/tune-server-v0.8.315-linux-aarch64.tar.gz"
      sha256 "b3236ba2cc9da33a7e52c71163fa8e1b5637de5653c47f896da9f08c45f266ce"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.315/tune-server-v0.8.315-linux-x86_64.tar.gz"
      sha256 "5bc6f72c333101286957cdba73b352f5e68287abee739a0d09d4e730b7d87bb1"
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
      Tune Server v0.8.315 (Rust) installed!

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
