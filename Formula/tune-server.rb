class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.219"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.219/tune-server-v0.8.219-macos-aarch64.tar.gz"
      sha256 "74fc97443fe248c4a0f63eed9de27712fde43c9be6746071d303dcd3f8359014"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.219/tune-server-v0.8.219-macos-x86_64.tar.gz"
      sha256 "f2d4b804b2b9071fb7f9ae52eb0d27a0c908e373484a01708b3750957e396034"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.219/tune-server-v0.8.219-linux-aarch64.tar.gz"
      sha256 "a723533def873994add0d9070f5c45106a21f7bf51b5f50a7d320abb92911d0c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.219/tune-server-v0.8.219-linux-x86_64.tar.gz"
      sha256 "23820107122086d82dc1bb6527f9b6005c921f8c82b38ec05ea6a3e619f1b959"
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
      Tune Server v0.8.219 (Rust) installed!

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
