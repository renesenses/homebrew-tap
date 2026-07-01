class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.230"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.230/tune-server-v0.8.230-macos-aarch64.tar.gz"
      sha256 "e770049199abf0957762f7812f8b725d98d17c1945b003ae43ff5654d7f442b7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.230/tune-server-v0.8.230-macos-x86_64.tar.gz"
      sha256 "32c869fbfd8ae6b491f49ffb28480816bb91ea5f06895e0484e3f24883f067e7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.230/tune-server-v0.8.230-linux-aarch64.tar.gz"
      sha256 "0bf03d207e8f56644b852b5b4021acab91c077c7f86be82c57d43adbd58b62ff"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.230/tune-server-v0.8.230-linux-x86_64.tar.gz"
      sha256 "75df0bc13fe8b408de4d292125782b6fe052498a6b1fb43360154bd3429f2b8f"
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
      Tune Server v0.8.230 (Rust) installed!

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
