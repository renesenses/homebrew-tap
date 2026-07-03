class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.241"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.241/tune-server-v0.8.241-macos-aarch64.tar.gz"
      sha256 "fe25eb3e1ade4eab69ee1cec61c69c390e795c67f025c2a7774ba0381c8cf19e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.241/tune-server-v0.8.241-macos-x86_64.tar.gz"
      sha256 "74e812fb2ba600bab0ff6a70cbba437bb790be0b7e4d5f597f48c775bdf368f5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.241/tune-server-v0.8.241-linux-aarch64.tar.gz"
      sha256 "2fe3dc748fb65d8eced2eac6ecdbc3e747c024cac3d16a49d4e17893117dc7e5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.241/tune-server-v0.8.241-linux-x86_64.tar.gz"
      sha256 "d655fa4a8a754e89ba07338da5c564fae5516849d1c58ed874167b92e4561d6e"
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
      Tune Server v0.8.241 (Rust) installed!

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
