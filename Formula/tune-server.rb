class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.215"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.215/tune-server-v0.8.215-macos-aarch64.tar.gz"
      sha256 "fc5c3dcbfe8863ec898350af405d6b0150c22cc7d2a664ab24726347c1a5f6ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.215/tune-server-v0.8.215-macos-x86_64.tar.gz"
      sha256 "9a5742645ae452642c548e5a445bdc77cc0d319aced9d88d533112889fb8d35d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.215/tune-server-v0.8.215-linux-aarch64.tar.gz"
      sha256 "cc295accc188fba632825b544759601ec4c3056e9fed15b4e075804d712d2da8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.215/tune-server-v0.8.215-linux-x86_64.tar.gz"
      sha256 "16a52b02b620b010768fdf7c72206534f1c5cb11da8d422f69c260f6cfcf3bc3"
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
      Tune Server v0.8.215 (Rust) installed!

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
