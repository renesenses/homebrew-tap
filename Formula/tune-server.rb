class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.179"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.179/tune-server-v0.8.179-macos-aarch64.tar.gz"
      sha256 "ad8edbebf19806985474ed02badcdac28eabc5be5603447d35257ea3282e276a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.179/tune-server-v0.8.179-macos-x86_64.tar.gz"
      sha256 "625a35cb5b7b8131754f20fdaf51394923d4113e5da17a817ec4e696e0127cf1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.179/tune-server-v0.8.179-linux-aarch64.tar.gz"
      sha256 "d66ba314218acea2cbbe4c94956242e53ac286ea08d331d25ef88054acd82163"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.179/tune-server-v0.8.179-linux-x86_64.tar.gz"
      sha256 "abd1c069d25a4a57b263ff2750d54e31e0b78d8262cee0cacfea78c8c2279ea8"
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
      Tune Server v0.8.179 (Rust) installed!

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
