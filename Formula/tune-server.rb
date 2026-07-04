class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.254"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.254/tune-server-v0.8.254-macos-aarch64.tar.gz"
      sha256 "a8b19a9cb34d364114f78616985c49f94251e624614d27f716b788513a66811a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.254/tune-server-v0.8.254-macos-x86_64.tar.gz"
      sha256 "1940644d7cd136a95749146694a05c8c4d16be59de88bdd34848289d0d633526"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.254/tune-server-v0.8.254-linux-aarch64.tar.gz"
      sha256 "30ddfbac948406eb15e5c6b5bf99a73c4abe3351f27e2a3bc7369f1fc9014955"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.254/tune-server-v0.8.254-linux-x86_64.tar.gz"
      sha256 "b3bfe745bd52dca89525fd04bd2d43b1d95aa29e1d6d5f98ed1daea28dfd5551"
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
      Tune Server v0.8.254 (Rust) installed!

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
