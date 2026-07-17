class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.327"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.327/tune-server-v0.8.327-macos-aarch64.tar.gz"
      sha256 "481017215c7b420f341b66ad3e22e6eef2072f4d011e52e3979352024e2ef9f5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.327/tune-server-v0.8.327-macos-x86_64.tar.gz"
      sha256 "385d10ad868b940b993b343356a5425f3f0f56a9dde29d7752d388221df4bfd9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.327/tune-server-v0.8.327-linux-aarch64.tar.gz"
      sha256 "8aff574a70aabf757b12657cbc1f459c35b842f4c620413d35d220bc47279994"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.327/tune-server-v0.8.327-linux-x86_64.tar.gz"
      sha256 "69a58bb880c9d2e0935d78d199dcf8892591b611d123ea284e437a6278206825"
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
      Tune Server v0.8.327 (Rust) installed!

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
