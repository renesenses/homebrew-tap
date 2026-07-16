class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.322"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.322/tune-server-v0.8.322-macos-aarch64.tar.gz"
      sha256 "059cfe9b3b78f3f1237a2b2b38fd3c2c342e3ceb0c7e679f8be24d32ec73e14c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.322/tune-server-v0.8.322-macos-x86_64.tar.gz"
      sha256 "876e7b689fa4b41030e30d0815a5af71701b085c66548f7425e4b716f69b1d23"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.322/tune-server-v0.8.322-linux-aarch64.tar.gz"
      sha256 "fe1f95e7a715b815b98ae600e4a799ea02ff01f27bbb53d97a97ba0de749895c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.322/tune-server-v0.8.322-linux-x86_64.tar.gz"
      sha256 "bebe6cffc764005244f99741d6edc603faf28fe3cbf8c774d98924cd0e209c57"
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
      Tune Server v0.8.322 (Rust) installed!

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
