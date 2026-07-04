class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.252"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.252/tune-server-v0.8.252-macos-aarch64.tar.gz"
      sha256 "4c948b572d339239393c167bbf84d91bf4d21a5cbdec77eede11731d15d05932"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.252/tune-server-v0.8.252-macos-x86_64.tar.gz"
      sha256 "46efcb8095b6aa62752a1527e449422d3ae03a30b8653af19df69b0970ccf6ee"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.252/tune-server-v0.8.252-linux-aarch64.tar.gz"
      sha256 "a19066dd86401a9fc9288ba5d0abfb4e4eefe3892c7173c1d59d103c9abbc41f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.252/tune-server-v0.8.252-linux-x86_64.tar.gz"
      sha256 "e1b00572005e62bedd1cb2cbfcb58e94a067fa634c4698b05414d6ba1f8272ac"
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
      Tune Server v0.8.252 (Rust) installed!

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
