class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.151"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.151/tune-server-v0.8.151-macos-aarch64.tar.gz"
      sha256 "8452fac300fbbb4689255a7390718829566f835b0b56be3a70ca61db594bf09d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.151/tune-server-v0.8.151-macos-x86_64.tar.gz"
      sha256 "667977fe85e0aff376dfc0cf6fca771ec41c6368c3606b9ebb6d87ea74c9d32d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.151/tune-server-v0.8.151-linux-aarch64.tar.gz"
      sha256 "a95c2dbb046dc242ef7047feead973c59a833384b72dfd0288f55937f2d34050"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.151/tune-server-v0.8.151-linux-x86_64.tar.gz"
      sha256 "44ad104070b5d395d5c35324030d5fe4f148c94bac93645c232310aa5aee0b43"
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
      Tune Server v0.8.151 (Rust) installed!

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
