class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.267"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.267/tune-server-v0.8.267-macos-aarch64.tar.gz"
      sha256 "d9b4ef7140e8da774d7eb4e4e6ae17e45c569ce7fbab70b73f6e744923df310a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.267/tune-server-v0.8.267-macos-x86_64.tar.gz"
      sha256 "05179111ab3caa3708d444ec1053afe079c95a7cbdade799ee79af6335bb6cfd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.267/tune-server-v0.8.267-linux-aarch64.tar.gz"
      sha256 "6cb8ef69a8ff7ab63da6c4de0495d906a79a6a4870b9b1659a949eff32f1a9bb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.267/tune-server-v0.8.267-linux-x86_64.tar.gz"
      sha256 "2187d4aa20af6fe3664f0987f849d40312042d8178733e40ae836be594cec1e8"
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
      Tune Server v0.8.267 (Rust) installed!

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
