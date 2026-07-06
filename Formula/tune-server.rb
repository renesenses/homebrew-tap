class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.268"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.268/tune-server-v0.8.268-macos-aarch64.tar.gz"
      sha256 "19224b27bc726a48a9b68b4c3f8395b0aabe80d94aa89f45272e94cb804b1d80"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.268/tune-server-v0.8.268-macos-x86_64.tar.gz"
      sha256 "2d565de9c3c2aae3f1bc31561a1c41fb31164a3735775ca581c23c6e24bd99b9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.268/tune-server-v0.8.268-linux-aarch64.tar.gz"
      sha256 "0f2322fc04c80a5c16f2a6fd9b4c827475ac4ea6d0724eb16052dd4a75fb2dfc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.268/tune-server-v0.8.268-linux-x86_64.tar.gz"
      sha256 "d20e8e6aebb7e27bcb3ea2209330ce2c79f0f87ed314ad1209cdf96f52955984"
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
      Tune Server v0.8.268 (Rust) installed!

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
