class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.294"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.294/tune-server-v0.8.294-macos-aarch64.tar.gz"
      sha256 "b353d9fcdf59957097c9511712d275a7e5d42ec86d02a51e0a2f5a995a31cff2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.294/tune-server-v0.8.294-macos-x86_64.tar.gz"
      sha256 "5468ea22753b8c6d1a2a70b79be7f636d0b8ee29ea119c02db314e9fd24bd81b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.294/tune-server-v0.8.294-linux-aarch64.tar.gz"
      sha256 "c81f99088b5980dbc5cdbc9e09c0a4bb31fcceb1ec6ac8fa9a5da60ec103cc3e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.294/tune-server-v0.8.294-linux-x86_64.tar.gz"
      sha256 "94bab4d34d6d9e31f378136f1e161059019740241afce3e5d69808e9a6a5efee"
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
      Tune Server v0.8.294 (Rust) installed!

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
