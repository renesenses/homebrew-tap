class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.350"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.350/tune-server-v0.8.350-macos-aarch64.tar.gz"
      sha256 "53a63acada915510193bc62b339405b029580563ee63b57ddfab28742229e905"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.350/tune-server-v0.8.350-macos-x86_64.tar.gz"
      sha256 "2b2385e2e4913ccf531cfca8f0f6be64ca5842ce833e88d16fbb143fd0df4072"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.350/tune-server-v0.8.350-linux-aarch64.tar.gz"
      sha256 "7bbcdf971e1b24f5bc2edaa1cf516fdff65a8acb2c33449d18b44987402138e7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.350/tune-server-v0.8.350-linux-x86_64.tar.gz"
      sha256 "2f018c98c4eb9c25e7191a7a978cbd35f1cee509d60e1b868b95d23623ebab41"
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
      Tune Server v0.8.350 (Rust) installed!

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
