class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.301"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.301/tune-server-v0.8.301-macos-aarch64.tar.gz"
      sha256 "c4e6b0812ab4da815f11cb8cba3cfb5738f5a3f3b01c0a68dd255c2f2209dc81"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.301/tune-server-v0.8.301-macos-x86_64.tar.gz"
      sha256 "4135d0d30ce663051b0e42ebe2026ba088a9f5e5b0a69fdde656ca42534b3b38"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.301/tune-server-v0.8.301-linux-aarch64.tar.gz"
      sha256 "3ab773bdec036b2356d93dba0ee49dbaca7c20c8fa29f76b43dba5e89d7a9909"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.301/tune-server-v0.8.301-linux-x86_64.tar.gz"
      sha256 "9b6689dc5a806e3b721622916039ff02c659773c6447d3e2fa50fe25221a754b"
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
      Tune Server v0.8.301 (Rust) installed!

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
