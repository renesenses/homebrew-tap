class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.208"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.208/tune-server-v0.8.208-macos-aarch64.tar.gz"
      sha256 "9c413301349f6b5d24f7291a4c2701e6bafcad838e252af9db7073418e5d98b6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.208/tune-server-v0.8.208-macos-x86_64.tar.gz"
      sha256 "9e1be6680942232cdb8ae538f0103129df89608bf91f2d46b0a09d50e284eb39"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.208/tune-server-v0.8.208-linux-aarch64.tar.gz"
      sha256 "4b19ea936da2c78c7b5950e2b2e0890b498fd559dc61aa44f4d8b3a6cc7c639f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.208/tune-server-v0.8.208-linux-x86_64.tar.gz"
      sha256 "41b926bf23d486beba0bc3d45a8cbb9eb3e3ebf337d2ffbf80b4e09885976494"
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
      Tune Server v0.8.208 (Rust) installed!

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
