class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.279"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.279/tune-server-v0.8.279-macos-aarch64.tar.gz"
      sha256 "0f5729063d89f7797fcf872727ad088607a00689896ed339080e435f75a440c1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.279/tune-server-v0.8.279-macos-x86_64.tar.gz"
      sha256 "79af2302df6aca94871cd6d580ad3a4c1b309b40c392fc207910ba858e4f8a50"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.279/tune-server-v0.8.279-linux-aarch64.tar.gz"
      sha256 "51290d04f92453e8ce640618d3564add7bedde3d6569e42b219495a8a35bc9ae"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.279/tune-server-v0.8.279-linux-x86_64.tar.gz"
      sha256 "d8c1d78d449f9579d5503140bf2fa0e9165ca9441ee3a530b5de8f3928c3a74e"
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
      Tune Server v0.8.279 (Rust) installed!

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
