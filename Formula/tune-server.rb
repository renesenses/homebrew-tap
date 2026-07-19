class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.343"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-macos-aarch64.tar.gz"
      sha256 "c3c47f5e2f2f2b907e4fe20c02534ac0bd19a3d594a7558c42b53b591655c515"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-macos-x86_64.tar.gz"
      sha256 "fd7e9924e118de46f4746d4a9e01201a67fc4ffc87c52fd25836567eb18bdf62"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-linux-aarch64.tar.gz"
      sha256 "013980e8c2c1f88fce68321111bb5ebe69e99774e3e8ed329415fcb210f12040"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.343/tune-server-v0.8.343-linux-x86_64.tar.gz"
      sha256 "f55578a68a9bcedf43bcb8196a531a64557b5d593d612b133a1dec3a944dc35d"
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
      Tune Server v0.8.343 (Rust) installed!

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
