class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.249"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.249/tune-server-v0.8.249-macos-aarch64.tar.gz"
      sha256 "3f3ba5e6b827525e8ef0ea38a81bc4a45c652aa196b1b4b385e9e6e9f63de5d4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.249/tune-server-v0.8.249-macos-x86_64.tar.gz"
      sha256 "e58adaa3f15f5d6d3c15cf5f248d9d72e75a8c1e71f9800951f2784cbe1dc37a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.249/tune-server-v0.8.249-linux-aarch64.tar.gz"
      sha256 "ba29e6cfaae4f319db902377447637ed0efafcccd23b7e7845aaad2c03775074"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.249/tune-server-v0.8.249-linux-x86_64.tar.gz"
      sha256 "4ddbdebb938487e8bc7b50811c868bc3b2b74c847c30eee00cdb9d7efb711009"
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
      Tune Server v0.8.249 (Rust) installed!

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
