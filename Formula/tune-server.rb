class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.232"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.232/tune-server-v0.8.232-macos-aarch64.tar.gz"
      sha256 "27decdf78113cfdb54a94fba19e453836cf8a1525c6ac0ca86bcc3ee391275c2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.232/tune-server-v0.8.232-macos-x86_64.tar.gz"
      sha256 "622bb060a6db433aaf24cd9634823c4af2701afbfd8c51664052c5cbc20d97c7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.232/tune-server-v0.8.232-linux-aarch64.tar.gz"
      sha256 "91e0969d801a5c1d4d82bc1b5c5cb6bae1e22769ba6813d6f288eb994fba7acb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.232/tune-server-v0.8.232-linux-x86_64.tar.gz"
      sha256 "33c3b8314f58876250bb0e05aa184fae530009a55fb1d673eaac4e1ad22e8023"
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
      Tune Server v0.8.232 (Rust) installed!

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
