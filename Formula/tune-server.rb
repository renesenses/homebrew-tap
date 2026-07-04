class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.256"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.256/tune-server-v0.8.256-macos-aarch64.tar.gz"
      sha256 "102f2be164088999e30dba69c5b21e07f995df337a513368793e97d2dcfbb418"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.256/tune-server-v0.8.256-macos-x86_64.tar.gz"
      sha256 "0c47363429f2f00f3d7d66bd1fedba44c704d6be3abcf875f1aa3fe538c0c3c9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.256/tune-server-v0.8.256-linux-aarch64.tar.gz"
      sha256 "107a32ed55c82336fdf3487d120eb0099d5efd4c74b7839352f5130f38d547d0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.256/tune-server-v0.8.256-linux-x86_64.tar.gz"
      sha256 "2ae8a8e05a59fb6abba7cde14be41206a2fe4b75d2989b2b7afe0e2ef69be269"
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
      Tune Server v0.8.256 (Rust) installed!

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
