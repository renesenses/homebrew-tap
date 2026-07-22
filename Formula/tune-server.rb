class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.365"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.365/tune-server-v0.8.365-macos-aarch64.tar.gz"
      sha256 "f44f45cde97877ad476f7dd736ecc14e9c145d3138eed14b45d51d4732bb6f8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.365/tune-server-v0.8.365-macos-x86_64.tar.gz"
      sha256 "1bee3bb19a4340230f425b6a5240a57ec7ed4cd7a8b194867fa2d37529aef7a1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.365/tune-server-v0.8.365-linux-aarch64.tar.gz"
      sha256 "6453f24d058aac10dd0256eadba9ae25b7346c499492b6c92da73ad5359029ee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.365/tune-server-v0.8.365-linux-x86_64.tar.gz"
      sha256 "988597de78e162265dab855e946b416516c818b05269ef3a8d49a5ccee2ad54f"
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
      Tune Server v0.8.365 (Rust) installed!

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
