class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.173"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.173/tune-server-v0.8.173-macos-aarch64.tar.gz"
      sha256 "810012403f5693225c4f1b63296abfcb516a73e15bc141ac0b079b8c1dc10532"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.173/tune-server-v0.8.173-macos-x86_64.tar.gz"
      sha256 "28cc0a6fd11da4762e4ecfccb92d6be94bbc97a214af0e0f3aad705343bac34c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.173/tune-server-v0.8.173-linux-aarch64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000003"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.173/tune-server-v0.8.173-linux-x86_64.tar.gz"
      sha256 "88fa186d0061ecd2e96e3a30f8664175960b108e0814c9fba0e733f86a6983f1"
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
      Tune Server v0.8.173 (Rust) installed!

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
