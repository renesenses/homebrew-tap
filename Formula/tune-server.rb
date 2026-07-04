class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.258"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.258/tune-server-v0.8.258-macos-aarch64.tar.gz"
      sha256 "33c1a8ddc9d58a905b39e595e394626cc5274c0af3c3078b39f864b686718819"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.258/tune-server-v0.8.258-macos-x86_64.tar.gz"
      sha256 "e91e38484713d812d7eab91f27447b86cd89901c2f33403c9d131399af45cc08"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.258/tune-server-v0.8.258-linux-aarch64.tar.gz"
      sha256 "005cf6bab3b54bdd77aa3d0e680aa5e7c80aaf23af24c843f85ccb7fe95a9197"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.258/tune-server-v0.8.258-linux-x86_64.tar.gz"
      sha256 "722d2848f270512ac9970ffdc9e31297b42130ec548383dcb86ddc048f39dd28"
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
      Tune Server v0.8.258 (Rust) installed!

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
