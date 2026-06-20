class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.144"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.144/tune-server-v0.8.144-macos-aarch64.tar.gz"
      sha256 "5e98f197e0db84a8733b5f6238b41b765a0853f018a1e97a6f3add26914cd845"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.144/tune-server-v0.8.144-macos-x86_64.tar.gz"
      sha256 "b868576b9b262d6c55a65537aa0fe4c8aa8b4d390e402da48f34e3b027796992"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.144/tune-server-v0.8.144-linux-aarch64.tar.gz"
      sha256 "2a92cd356cd84d838526e010c545ccd5fbfd09aba9f1c25cbb52c023ddd4409a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.144/tune-server-v0.8.144-linux-x86_64.tar.gz"
      sha256 "d08046eb39ede25d2868f89123b1a50bc1be2cd123a546ccfc2e4d7d40546acd"
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
      Tune Server v0.8.144 (Rust) installed!

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
