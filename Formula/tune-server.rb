class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.175"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.175/tune-server-v0.8.175-macos-aarch64.tar.gz"
      sha256 "2f4a821e6957773231f2ae7ab5aa9eda9cb3228566b362c330aed1c89880c5dc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.175/tune-server-v0.8.175-macos-x86_64.tar.gz"
      sha256 "cc547479f29f3ebb1ee77913fbe9b0ab251aad4c302c955d743ecd40dd3b3e81"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.175/tune-server-v0.8.175-linux-aarch64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000003"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.175/tune-server-v0.8.175-linux-x86_64.tar.gz"
      sha256 "8e240f724084c63df9590d1d6916c99d88924f652fa58acb23a481acdcccc804"
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
      Tune Server v0.8.175 (Rust) installed!

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
