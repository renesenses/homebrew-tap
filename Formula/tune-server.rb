class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.351"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.351/tune-server-v0.8.351-macos-aarch64.tar.gz"
      sha256 "ce5a40e6ec3e4dfcf73b2b79e26eb7a3da201751da9c3a56b6597586b1beda1b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.351/tune-server-v0.8.351-macos-x86_64.tar.gz"
      sha256 "89f8a51dc5db34b9ae9fc92351c10c589b1e52ec80719ab02b7444c876e959f2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.351/tune-server-v0.8.351-linux-aarch64.tar.gz"
      sha256 "01824923ebb6a6ba6503362997f90ccbce5343bb43c1195b24298a01f3a4d587"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.351/tune-server-v0.8.351-linux-x86_64.tar.gz"
      sha256 "4fef54d7fb4c21cf35abc63ee51131f43db39f7ff07e967d4c1c4e34aeedeb75"
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
      Tune Server v0.8.351 (Rust) installed!

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
