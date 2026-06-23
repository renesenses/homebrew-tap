class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.158"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.158/tune-server-v0.8.158-macos-aarch64.tar.gz"
      sha256 "378d4514e230f1be52f1bad46fc639e0de72ba20be6703a76048d03486415e34"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.158/tune-server-v0.8.158-macos-x86_64.tar.gz"
      sha256 "b95e0b234c2bbac15480051746d0e24dce466999578b1612f43e7925c0ad3d5d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.158/tune-server-v0.8.158-linux-aarch64.tar.gz"
      sha256 "1e32a14d10400119b8e68bf5e05ecca50efb04c21e74131eaa2227481da21169"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.158/tune-server-v0.8.158-linux-x86_64.tar.gz"
      sha256 "772912cee2848f78de3465837e7acd39eca0af862c50fd22d8ae429f586dda1e"
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
      Tune Server v0.8.158 (Rust) installed!

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
