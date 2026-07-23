class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.366"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.366/tune-server-v0.8.366-macos-aarch64.tar.gz"
      sha256 "2ef1aa50b02b4c54d5998b9187566a83a1f806a0ae6f2e5ba3cc4676d3b2760d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.366/tune-server-v0.8.366-macos-x86_64.tar.gz"
      sha256 "a8128ee048d432972a609fe615939694f88c57a5a830368902ddfff3c2f8159f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.366/tune-server-v0.8.366-linux-aarch64.tar.gz"
      sha256 "b9a7a768a389e31ac60da918fa55a43c17e8cb0d91f3b1627aa73121ed4bd81d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.366/tune-server-v0.8.366-linux-x86_64.tar.gz"
      sha256 "568565f82317d089f19096ae12cd282173aed0d31af7fc47fb2b7051458611db"
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
      Tune Server v0.8.366 (Rust) installed!

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
