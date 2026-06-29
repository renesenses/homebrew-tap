class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.202"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.202/tune-server-v0.8.202-macos-aarch64.tar.gz"
      sha256 "30febc86e89b2499a5cac52b3e191e37274628687a929259657c46d1c22f90f8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.202/tune-server-v0.8.202-macos-x86_64.tar.gz"
      sha256 "01b0cc00f3c112d2090985e52a2c4535c0bed2994c4f3c372556861d056b7483"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.202/tune-server-v0.8.202-linux-aarch64.tar.gz"
      sha256 "420b8eb285318681858f5aae28c36ceb5523debef753786f67b02a4a7453caae"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.202/tune-server-v0.8.202-linux-x86_64.tar.gz"
      sha256 "ec6939b7f4fdc73fc5599ec5d9734a27a36f7626c53ca326cca837a40eb36510"
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
      Tune Server v0.8.202 (Rust) installed!

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
