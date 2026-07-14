class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.309"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.309/tune-server-v0.8.309-macos-aarch64.tar.gz"
      sha256 "082645f1e8a78e3c55b8b9556a1070b77421e3539104e27e551a20d000a42191"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.309/tune-server-v0.8.309-macos-x86_64.tar.gz"
      sha256 "20ce19c3f8aa9a6b6d90878adc21fb397f986d101d343cffe5a3ddf4740ad6d7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.309/tune-server-v0.8.309-linux-aarch64.tar.gz"
      sha256 "3eb4f8b591ab9939367868505208efd00a6107b4f9fbc032b0caa222cc34e8f9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.309/tune-server-v0.8.309-linux-x86_64.tar.gz"
      sha256 "72a777123c30d8f72d0dadef77465bc9c768533347d6653aba2009dda6fb27c0"
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
      Tune Server v0.8.309 (Rust) installed!

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
