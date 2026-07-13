class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.307"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.307/tune-server-v0.8.307-macos-aarch64.tar.gz"
      sha256 "4ba7baf0be71e3961075993499832df706f36f55802e4683f663fba72b2dbe84"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.307/tune-server-v0.8.307-macos-x86_64.tar.gz"
      sha256 "3cdb23d187a71a0e43ccff9442ff3490fca2465bf27831b1ffbc9e49945910b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.307/tune-server-v0.8.307-linux-aarch64.tar.gz"
      sha256 "72a276ea07533aa78bedbf95536b4ecfb2a1fcf41c8d00db3706c17c11c41681"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.307/tune-server-v0.8.307-linux-x86_64.tar.gz"
      sha256 "189169c29f0d51815471aaa25d20d11ad93bb29ffb96724017a1f067356a842f"
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
      Tune Server v0.8.307 (Rust) installed!

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
