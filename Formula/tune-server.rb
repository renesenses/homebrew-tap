class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.177"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.177/tune-server-v0.8.177-macos-aarch64.tar.gz"
      sha256 "910b1304e4003b5fe13e5b95e5ae6414bea049ee93e544df6d7094044203c5d3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.177/tune-server-v0.8.177-macos-x86_64.tar.gz"
      sha256 "c4984f62877b3fb83552bf6ad29bd13b446ed5c95fe8ca4dba982ceb654b7a7c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.177/tune-server-v0.8.177-linux-aarch64.tar.gz"
      sha256 "9170ddb6068203280e4d35c4e0c1ece71172cf57eacf842183732451d36885b4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.177/tune-server-v0.8.177-linux-x86_64.tar.gz"
      sha256 "99c0d8c1c0a805aea95d398e979e4023c251b3bb9eef1157863742d2e6654e0f"
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
      Tune Server v0.8.177 (Rust) installed!

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
