class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.139"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-macos-aarch64.tar.gz"
      sha256 "933a0fc0db01d3d6bc3795401c9327ce851f4cf921d24c5b5bae4389f1d74eee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-macos-x86_64.tar.gz"
      sha256 "22e192cffcb01ec9aeeab4ef63ca35db40a4d9677784422432264c9793aebaf2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-linux-aarch64.tar.gz"
      sha256 "f355d88d0f578d3b0f70dfa72a8c018939d783dbbd1de76df787db2d90205f69"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.139/tune-server-v0.8.139-linux-x86_64.tar.gz"
      sha256 "f25f92c6d40238d0825a54b6356daa207c2c337c0dd34b2217063e6d6aa5e516"
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
      Tune Server v0.8.139 (Rust) installed!

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
