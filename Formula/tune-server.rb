class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.335"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.335/tune-server-v0.8.335-macos-aarch64.tar.gz"
      sha256 "73635314e89d42164f647cb0bffcd98228e2ddd562a77afaf4f31ee95c85bb37"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.335/tune-server-v0.8.335-macos-x86_64.tar.gz"
      sha256 "8247d8f7d14008a408da67d8af51e4a7f7684cd63db390d021aaef02e92f76b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.335/tune-server-v0.8.335-linux-aarch64.tar.gz"
      sha256 "1ba0f8a9d329cf637d758e18d7bd9893db9326b7915a197c0987dab58ee3d4fb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.335/tune-server-v0.8.335-linux-x86_64.tar.gz"
      sha256 "e94b26cedd62b76ebeed553dc9da6c1f6d7585c48f3b9bb75a8504f1473ad83d"
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
      Tune Server v0.8.335 (Rust) installed!

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
