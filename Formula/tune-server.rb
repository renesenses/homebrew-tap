class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.326"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.326/tune-server-v0.8.326-macos-aarch64.tar.gz"
      sha256 "4e55702b6f09fc555d89c4232e9a2ba8f62383132edb34bc299334bfdbf8bc3f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.326/tune-server-v0.8.326-macos-x86_64.tar.gz"
      sha256 "0a776b79aebc25d7a46cf4871fdfa4180459dac41a70b23befe423c31519f86d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.326/tune-server-v0.8.326-linux-aarch64.tar.gz"
      sha256 "6f448cebbd818cef9458c36861a3d012b58391c42e8e8d6c9bc88d0297518630"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.326/tune-server-v0.8.326-linux-x86_64.tar.gz"
      sha256 "2c36e8f0b6720bdce293b4310d919306f9babbeaa1e86ecd6263cd5291db8a9a"
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
      Tune Server v0.8.326 (Rust) installed!

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
