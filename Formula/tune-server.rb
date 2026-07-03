class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.238"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.238/tune-server-v0.8.238-macos-aarch64.tar.gz"
      sha256 "dc0612d5f83a20a6e818d2c16b8c24ea3373266c75c8875932ccbe39c0dcf79b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.238/tune-server-v0.8.238-macos-x86_64.tar.gz"
      sha256 "188fad8f5579b3989e27a7810c90e11caa96214d879b1f4c7b3028f5c715bbdf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.238/tune-server-v0.8.238-linux-aarch64.tar.gz"
      sha256 "869d97e6bd1e319c7b901c936639d4a058ba920475e6564c5ed6a12471667ef7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.238/tune-server-v0.8.238-linux-x86_64.tar.gz"
      sha256 "9bc3b9a1bc30d17f6c8b2b60481d5fde1a0ee329c01eb39a402916608088f5ef"
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
      Tune Server v0.8.238 (Rust) installed!

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
