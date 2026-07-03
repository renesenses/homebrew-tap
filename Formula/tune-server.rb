class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.244"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.244/tune-server-v0.8.244-macos-aarch64.tar.gz"
      sha256 "5e04417e45be6f166e6260cfc7e5ead24f386a1ba130baefcaddf01654c89f6b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.244/tune-server-v0.8.244-macos-x86_64.tar.gz"
      sha256 "73c4dc4042a73367861cb04ea482912cef4831e3626d1ba7abe796dcca9ca8df"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.244/tune-server-v0.8.244-linux-aarch64.tar.gz"
      sha256 "7b0693b58021e8da55bddb789e3941b24708807c805945b086fe083ee4ec67d6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.244/tune-server-v0.8.244-linux-x86_64.tar.gz"
      sha256 "305a3a5a64a954306eb3c34a7baff0c6c910027ecd8e36f825177bb1f7d4fa49"
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
      Tune Server v0.8.244 (Rust) installed!

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
