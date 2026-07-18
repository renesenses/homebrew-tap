class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.333"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.333/tune-server-v0.8.333-macos-aarch64.tar.gz"
      sha256 "8386b349524b0476e742cff0afe786e7b826b9a8a1b0b9bb1c9f76bcaad3dcb5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.333/tune-server-v0.8.333-macos-x86_64.tar.gz"
      sha256 "92609bee9da95c0bd5f9f07115a3d45a3d122ac42d0440259702d4113c67ebba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.333/tune-server-v0.8.333-linux-aarch64.tar.gz"
      sha256 "96b1b687a00f0a31658e6c739fddab1f60c9ebe5d55ba092177fb9c11719c5db"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.333/tune-server-v0.8.333-linux-x86_64.tar.gz"
      sha256 "f56f71a3d200b81f1c51352d27b5c4e822a5a61750bc10fafbf1b3148510235c"
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
      Tune Server v0.8.333 (Rust) installed!

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
