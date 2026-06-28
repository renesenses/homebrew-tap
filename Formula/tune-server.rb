class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.199"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.199/tune-server-v0.8.199-macos-aarch64.tar.gz"
      sha256 "4002567a524a5d1b472d1fa8ea86045adf32ae9c5ce68e9013ce006efc735b6f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.199/tune-server-v0.8.199-macos-x86_64.tar.gz"
      sha256 "88abc9e8229d6aef9b5f65e8890ee9638e4f57bbe8416a1d3e374d7d15fd7d55"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.199/tune-server-v0.8.199-linux-aarch64.tar.gz"
      sha256 "NO_ARM_LINUX_BUILD"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.199/tune-server-v0.8.199-linux-x86_64.tar.gz"
      sha256 "842ad84474234e3093dee357a2db817dba6261bfd82e6432fa87bd843db846bc"
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
      Tune Server v0.8.199 (Rust) installed!

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
