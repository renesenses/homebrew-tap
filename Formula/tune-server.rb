class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.312"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.312/tune-server-v0.8.312-macos-aarch64.tar.gz"
      sha256 "0d0ac5c1cdba7674e076cb2a112f5be00f4e8d8e7c46c30d8d727f8a887bb3bc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.312/tune-server-v0.8.312-macos-x86_64.tar.gz"
      sha256 "c836c7a03707332e952e4171806a22f61c2a7aa3a4128f41c7a779a65f15180e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.312/tune-server-v0.8.312-linux-aarch64.tar.gz"
      sha256 "528e7d093a711b186e0d06ca5707d7e3948f933500b56f481eb5a86564f43645"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.312/tune-server-v0.8.312-linux-x86_64.tar.gz"
      sha256 "0334ec5a4cfdb13548241419d9c25e1befb64a3ee0a8dde50b1adfb4d12f3b1d"
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
      Tune Server v0.8.312 (Rust) installed!

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
