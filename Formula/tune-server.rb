class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.231"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.231/tune-server-v0.8.231-macos-aarch64.tar.gz"
      sha256 "86eb56a00c4c25d6b7391e77f142e551d1f2d9852424c4824c55006e1d21d128"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.231/tune-server-v0.8.231-macos-x86_64.tar.gz"
      sha256 "1d279f9143ff00d3ef8766fc2d84c820156b41e7dd128d3bfc1720d4a3d8459a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.231/tune-server-v0.8.231-linux-aarch64.tar.gz"
      sha256 "936ffd2133acf3d381be39251d11c258dc35f4dd44c623e23a18f4a92f55ba3d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.231/tune-server-v0.8.231-linux-x86_64.tar.gz"
      sha256 "23549b198027cbc488ccffaddf887a35e3d87ae08c723c3c40a43a3f0845abe8"
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
      Tune Server v0.8.231 (Rust) installed!

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
