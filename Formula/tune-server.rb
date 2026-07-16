class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.319"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-macos-aarch64.tar.gz"
      sha256 "dae9528e6320d95ff531c567927df36355f6ab0fc6c70bf3613560752eb21458"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-macos-x86_64.tar.gz"
      sha256 "725c3dec873857001bcae6b50b93b5adca0fca52d811ac40962854fa9b55a87c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-linux-aarch64.tar.gz"
      sha256 "4b1eacb3700e218cd25e3482dd7e94d2de4af069d7a6b908e1cb0cbfd920610b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-linux-x86_64.tar.gz"
      sha256 "1e42da0debd58accf66fe709e0570c0757d7fffeba4ada86ead10f1920b4bca7"
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
      Tune Server v0.8.319 (Rust) installed!

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
