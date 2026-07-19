class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.341"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.341/tune-server-v0.8.341-macos-aarch64.tar.gz"
      sha256 "e48d41092b49f4b0f2dd3f17345784609b973c47c19ea348f7b782ed7f3f0f4b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.341/tune-server-v0.8.341-macos-x86_64.tar.gz"
      sha256 "69aab318c80b6a437452aadaa74846a23d38ea51bda302c601a711c228ab9992"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.341/tune-server-v0.8.341-linux-aarch64.tar.gz"
      sha256 "f3f266fc90c89e5d9b1c2a01d8f7b5a3b39cdb3866244c71ee0031982488c180"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.341/tune-server-v0.8.341-linux-x86_64.tar.gz"
      sha256 "bcf09742f0bc7a3aa42c544a345c117a455fcb25b45ab09cefd256741d3fde82"
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
      Tune Server v0.8.341 (Rust) installed!

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
