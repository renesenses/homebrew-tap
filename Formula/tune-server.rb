class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.273"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.273/tune-server-v0.8.273-macos-aarch64.tar.gz"
      sha256 "01ca284bae47daede80d75a88da0defe9d80731d0daa321a109becef4b69e9dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.273/tune-server-v0.8.273-macos-x86_64.tar.gz"
      sha256 "e7240079d9588f08b5d68d8f63a7da6836a96c9c95400f206cd1b768980de59b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.273/tune-server-v0.8.273-linux-aarch64.tar.gz"
      sha256 "b43e2efe1835230c1faead5630768132fe9112191eb2482033113aa4191d03cd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.273/tune-server-v0.8.273-linux-x86_64.tar.gz"
      sha256 "3a44bd18850a6a04ed804c13a2eaa46723f38792ea625ad27bf7e16ae05e0a5e"
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
      Tune Server v0.8.273 (Rust) installed!

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
