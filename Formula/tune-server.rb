class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.324"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.324/tune-server-v0.8.324-macos-aarch64.tar.gz"
      sha256 "6aad0b422cb4152c26454fa514cb2fe765da03786ad8a69c3b65f1e9f110dff4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.324/tune-server-v0.8.324-macos-x86_64.tar.gz"
      sha256 "f600e1b4020a297c19a5e5a412b3a0c478e4cd1fa86d5015e573a3b435fed180"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.324/tune-server-v0.8.324-linux-aarch64.tar.gz"
      sha256 "5b3b2efdf01bf744429acbe56afe5459449907052a3c10d79cff5ae438912f1c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.324/tune-server-v0.8.324-linux-x86_64.tar.gz"
      sha256 "5ef1b8d14fcf29151f1d4477cd415370be3deb3ba4dd46df853eb8a119958049"
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
      Tune Server v0.8.324 (Rust) installed!

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
