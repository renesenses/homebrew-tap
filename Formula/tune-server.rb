class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.229"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.229/tune-server-v0.8.229-macos-aarch64.tar.gz"
      sha256 "3a15ccd5214f06ad586975f1d729a7ede21df87a9760d63ab7e507ad965043fb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.229/tune-server-v0.8.229-macos-x86_64.tar.gz"
      sha256 "28215007ff71b75c1d2ee3f8089e1f1213285f3db286166db199aea55a4bbb2c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.229/tune-server-v0.8.229-linux-aarch64.tar.gz"
      sha256 "4161882f13773c9a350abd162bfbf445f5c985a4ae53292dcfc2a063331bb45d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.229/tune-server-v0.8.229-linux-x86_64.tar.gz"
      sha256 "175759c4e479acabb739dd8c1e0d13ab039f2522d6f91e79d2a38628ec60d57d"
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
      Tune Server v0.8.229 (Rust) installed!

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
