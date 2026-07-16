class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.320"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.320/tune-server-v0.8.320-macos-aarch64.tar.gz"
      sha256 "8a9de00095c9be6e8102b0490038a83e31f61530adc23ffa861939798734e93d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.320/tune-server-v0.8.320-macos-x86_64.tar.gz"
      sha256 "126154b0f1bfaff35218d3d725f7c5b62616206e3b81f2b3eeca60bc259f6fc7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.320/tune-server-v0.8.320-linux-aarch64.tar.gz"
      sha256 "e3b40ee0a976b98568742d9422d8154fd686d14692e63142a7cc72207be328d1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.320/tune-server-v0.8.320-linux-x86_64.tar.gz"
      sha256 "7ea0c224cb24dd5e92d9480cb51047ec7fb1704b5add40e1d5ff3a0dc64335dc"
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
      Tune Server v0.8.320 (Rust) installed!

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
