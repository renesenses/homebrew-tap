class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.201"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.201/tune-server-v0.8.201-macos-aarch64.tar.gz"
      sha256 "35b8d751922ea77464a4af50a21f950507e2b4007ff6490c505cad857b3f99ff"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.201/tune-server-v0.8.201-macos-x86_64.tar.gz"
      sha256 "ca40db09192d44fed1c4c36b7be74d6a257f1a76176ef8a669a7a74c96c8346c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.201/tune-server-v0.8.201-linux-aarch64.tar.gz"
      sha256 "ec2dcbe521be18059eb2f60b8fd928ac7f475e817886bebaf764354ef97ce0bf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.201/tune-server-v0.8.201-linux-x86_64.tar.gz"
      sha256 "3a6ae2785887c5e7a4377eaaefe6f373544399c135f41b1fbcd484e4810c71b5"
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
      Tune Server v0.8.201 (Rust) installed!

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
