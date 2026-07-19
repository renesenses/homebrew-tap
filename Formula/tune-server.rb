class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.344"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.344/tune-server-v0.8.344-macos-aarch64.tar.gz"
      sha256 "1c681b01f750f68d061f2732e69232671662b1d4587d4240f732a93cc57c4c99"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.344/tune-server-v0.8.344-macos-x86_64.tar.gz"
      sha256 "d3f0ff948edd2bf895e066222126a429e0ce762013a6d3092eff2dac0f310b94"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.344/tune-server-v0.8.344-linux-aarch64.tar.gz"
      sha256 "b658d21e6b6fd736fb034872f65d90f1cc570068142cbd1743b224f0d985d932"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.344/tune-server-v0.8.344-linux-x86_64.tar.gz"
      sha256 "93520509726f84b2100d5889402e3883593d063b5cb998b2e7d298ad149f2f39"
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
      Tune Server v0.8.344 (Rust) installed!

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
