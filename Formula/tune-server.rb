class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.218"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.218/tune-server-v0.8.218-macos-aarch64.tar.gz"
      sha256 "fe4e7c7f30b2b56520edb9693481d85750502730340591063a71abee0d7ec24f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.218/tune-server-v0.8.218-macos-x86_64.tar.gz"
      sha256 "57f622a338217d619f40553935269353841e79bf62e0753070af509cde4a4fad"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.218/tune-server-v0.8.218-linux-aarch64.tar.gz"
      sha256 "bf1a8faf731c83a7adf58fa9038321a8637104846be33b06c878813b64aaae6c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.218/tune-server-v0.8.218-linux-x86_64.tar.gz"
      sha256 "680ac04d45ec63bf31f275ee9e943075f7693b34795e78941fa34f1579601288"
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
      Tune Server v0.8.218 (Rust) installed!

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
