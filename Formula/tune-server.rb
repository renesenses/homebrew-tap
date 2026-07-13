class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.304"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.304/tune-server-v0.8.304-macos-aarch64.tar.gz"
      sha256 "e6e278f37435e5678a7042e98b24fe014977e80ac0389dc50e2a79011d7c1cf4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.304/tune-server-v0.8.304-macos-x86_64.tar.gz"
      sha256 "c19afa856ef7a55d054f46b92e2bafd8a3c7a3f3a0aef1b532085be9ab27d5b1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.304/tune-server-v0.8.304-linux-aarch64.tar.gz"
      sha256 "41e03306b44ba044f08e9e06f9b659090fca9f21f2f6daf5739383fbcc161115"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.304/tune-server-v0.8.304-linux-x86_64.tar.gz"
      sha256 "fc4f6dce1d43a0900f4d71ea22874c250775dc896438fdca342810f6073ec63c"
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
      Tune Server v0.8.304 (Rust) installed!

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
