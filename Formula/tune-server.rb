class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.142"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-macos-aarch64.tar.gz"
      sha256 "8c2963ff68a75b1a7ef1c886830e79f0213753ffa11505f6c7d6c48c285ce53c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-macos-x86_64.tar.gz"
      sha256 "1e8a071a159b9105d59d0c551dc01ad09cd55de2c26dff0fac02898d2c2faaf1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-linux-aarch64.tar.gz"
      sha256 "5bfa76ee78073f30c6893fafd11082f4549d81aef04edb91e80f38b0eceddf67"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-linux-x86_64.tar.gz"
      sha256 "e9aa42527b0c9d582efc4c1c5df52da88b216abe9ab4eefc0bc024f16e614e92"
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
      Tune Server v0.8.142 (Rust) installed!

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
