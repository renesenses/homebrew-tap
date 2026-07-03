class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.248"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.248/tune-server-v0.8.248-macos-aarch64.tar.gz"
      sha256 "62277d1aa33fe51d21bcf352bf69d36dde6348ae1df2a9862c473092e153480c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.248/tune-server-v0.8.248-macos-x86_64.tar.gz"
      sha256 "aa1782acccd3355ad451dc3bfb1784646d6c1676da8126a157341b03479be046"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.248/tune-server-v0.8.248-linux-aarch64.tar.gz"
      sha256 "f68e84b67bbf58687ae36fa382d9010b27f5a9b93b707892f802f5628e30899b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.248/tune-server-v0.8.248-linux-x86_64.tar.gz"
      sha256 "5ee758cf64bc170fcfbec748b38abcb1069c7d9b91161a1e26aa73ce493c4f98"
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
      Tune Server v0.8.248 (Rust) installed!

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
