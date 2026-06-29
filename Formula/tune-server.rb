class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.206"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.206/tune-server-v0.8.206-macos-aarch64.tar.gz"
      sha256 "05f5a5ef6575c78ebb75afec41a15847eaeeffb02c7486960cdd8dc686e5c628"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.206/tune-server-v0.8.206-macos-x86_64.tar.gz"
      sha256 "051dec204d8838290ebed822995514e16e014e52d709077206b6e96e1c37282d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.206/tune-server-v0.8.206-linux-aarch64.tar.gz"
      sha256 "7d695601945751726d4ae97912047bbe7a417f6393d6c3d924c52817ebff2d93"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.206/tune-server-v0.8.206-linux-x86_64.tar.gz"
      sha256 "4d98bc43e36c9e1023cbb2a265ce338a28beff237d0d20cd8a94617110eddd8e"
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
      Tune Server v0.8.206 (Rust) installed!

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
