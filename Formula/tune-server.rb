class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.305"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.305/tune-server-v0.8.305-macos-aarch64.tar.gz"
      sha256 "95c74df0150a9000376243a10779fa1753f8fa580926f56047247800f016d9a7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.305/tune-server-v0.8.305-macos-x86_64.tar.gz"
      sha256 "33e89341f32a0cb66c9de3e8dcaffdad3b594edece637f51bb254b118fe16753"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.305/tune-server-v0.8.305-linux-aarch64.tar.gz"
      sha256 "e865cc86ac355ede851c445ffeb6e6198618843255ed8627dc868527a6f377cb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.305/tune-server-v0.8.305-linux-x86_64.tar.gz"
      sha256 "9a4141e364fd6b52edd7e483d6ed1d66bb10fb7faa6ab04d6d3817c01db70d2a"
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
      Tune Server v0.8.305 (Rust) installed!

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
