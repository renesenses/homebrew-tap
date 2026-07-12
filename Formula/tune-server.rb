class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.300"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.300/tune-server-v0.8.300-macos-aarch64.tar.gz"
      sha256 "de904326c1b9411284230d073ea0ca94426ce6de1ab4a3eadb8623b6c55d6049"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.300/tune-server-v0.8.300-macos-x86_64.tar.gz"
      sha256 "29fbf9372e94c28ae37ce0ca69943026c11d9e295bbdec126123c322ee336065"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.300/tune-server-v0.8.300-linux-aarch64.tar.gz"
      sha256 "9222a26ce7244473ef4b1bfc28e760e5c9072029c0ee88f672932c31f48399e0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.300/tune-server-v0.8.300-linux-x86_64.tar.gz"
      sha256 "adeb23c299fdea18f7353e1c25f49c49d690adc04d18753a7ef637b40db79cc6"
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
      Tune Server v0.8.300 (Rust) installed!

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
