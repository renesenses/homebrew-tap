class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.148"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.148/tune-server-v0.8.148-macos-aarch64.tar.gz"
      sha256 "cee54040777dfdddf80ce78509cb672edad9d4d42f10ac95a58dbf2853df87aa"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.148/tune-server-v0.8.148-macos-x86_64.tar.gz"
      sha256 "83e1eb2ecae017ef868361ffc1b5a9de918fda6e8c2dcb36607fbe92555691c2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.148/tune-server-v0.8.148-linux-aarch64.tar.gz"
      sha256 "bc23356c5db9c0734bdb5b7dad3578744118c42f6aa9b8a3ef429f654301c1ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.148/tune-server-v0.8.148-linux-x86_64.tar.gz"
      sha256 "0b2f2c06431b49930a0db76687a72e33fb8f7f7b980245eaa33a645a4343916b"
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
      Tune Server v0.8.148 (Rust) installed!

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
