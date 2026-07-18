class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.337"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.337/tune-server-v0.8.337-macos-aarch64.tar.gz"
      sha256 "d314123f43d149e7b89d17b7ba00c20d855e4ef348c5be2fde40ff4cd6123d5c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.337/tune-server-v0.8.337-macos-x86_64.tar.gz"
      sha256 "20ccda669472f53f9c925ba7907c4033f5b13c5755ea894aaf7f7c34be29bb15"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.337/tune-server-v0.8.337-linux-aarch64.tar.gz"
      sha256 "3b4eaa4805a678cfe67e28a7eeca94a1c5c04051edaa0d628734d5046e54ac03"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.337/tune-server-v0.8.337-linux-x86_64.tar.gz"
      sha256 "166febb05b9e9328975f4815e2027fe79a0323974b87043074911d8f493fe8c7"
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
      Tune Server v0.8.337 (Rust) installed!

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
