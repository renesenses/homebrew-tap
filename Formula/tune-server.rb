class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.364"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.364/tune-server-v0.8.364-macos-aarch64.tar.gz"
      sha256 "c6d339bf936e3efe6f64ef5457ad0c48e2527d3e478fa502d1b4f42bb7c44da9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.364/tune-server-v0.8.364-macos-x86_64.tar.gz"
      sha256 "e23dcaef640300ec3dae4ad944df8844be6fdefd0172fb57b306c9710bb2c5a6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.364/tune-server-v0.8.364-linux-aarch64.tar.gz"
      sha256 "b61a73574f554b70c2e456fb3da056003dee1382150d3e4eed83dee06268ee8d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.364/tune-server-v0.8.364-linux-x86_64.tar.gz"
      sha256 "5c19f86049df2592af709040210c03879f7ca69926a9bc8473bfcc5e98d0bdb6"
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
      Tune Server v0.8.364 (Rust) installed!

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
