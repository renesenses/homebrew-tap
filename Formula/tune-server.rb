class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.293"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.293/tune-server-v0.8.293-macos-aarch64.tar.gz"
      sha256 "f7a819f5915a5a76968203222bb66f30fdcfb7276ad12f37d982250ff85a237f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.293/tune-server-v0.8.293-macos-x86_64.tar.gz"
      sha256 "1a27de77f3b78a1017cbddc3b3fb003095b5910876e17c2ac8b6e1f04bb51101"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.293/tune-server-v0.8.293-linux-aarch64.tar.gz"
      sha256 "26cafaa49a5e5e3962b4debb338b4fcba37e8c776effbfefc2a9fbdb95dcbdc1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.293/tune-server-v0.8.293-linux-x86_64.tar.gz"
      sha256 "81164f327dd02bd319af6bb34d9110142ba7e31fdefd9c8818d4e6ccc8b3ed63"
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
      Tune Server v0.8.293 (Rust) installed!

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
