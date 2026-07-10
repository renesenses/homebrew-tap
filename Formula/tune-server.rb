class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.292"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.292/tune-server-v0.8.292-macos-aarch64.tar.gz"
      sha256 "2bee2af909ad85deac360eb770cbc630d8e63368ec39c0cb435fed4320231352"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.292/tune-server-v0.8.292-macos-x86_64.tar.gz"
      sha256 "929d6af7ed93b7d26b4d5b1adb643012501cbbe50e4f2f373843e8c30fd59780"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.292/tune-server-v0.8.292-linux-aarch64.tar.gz"
      sha256 "76d5d46598af7e47516af606ca520bf5ad069cd14672509c6e52ae93838981fd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.292/tune-server-v0.8.292-linux-x86_64.tar.gz"
      sha256 "1ad690cf6ac22c03f6764b8d0ac53533329d7309295e942a6eef598868cab696"
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
      Tune Server v0.8.292 (Rust) installed!

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
