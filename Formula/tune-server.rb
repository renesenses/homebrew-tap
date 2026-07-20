class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.348"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.348/tune-server-v0.8.348-macos-aarch64.tar.gz"
      sha256 "96b6a789f0ed0717aec31246ec06ec93ca87107f3bbb7a998a0e08f554d60a35"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.348/tune-server-v0.8.348-macos-x86_64.tar.gz"
      sha256 "758469931af8fa45371bfed2de025cc30cab8d61efec2a6d75d6e8315f60123b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.348/tune-server-v0.8.348-linux-aarch64.tar.gz"
      sha256 "6296bdffcf171811f24724d6c948406cad9f4cbce3ac29c242870c528749e3af"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.348/tune-server-v0.8.348-linux-x86_64.tar.gz"
      sha256 "b82f47748227e67ede02d760ffd72ee1de72c02da2a6a3c8eda2ea0c6a8fe2f8"
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
      Tune Server v0.8.348 (Rust) installed!

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
