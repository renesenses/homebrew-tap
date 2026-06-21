class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.149"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.149/tune-server-v0.8.149-macos-aarch64.tar.gz"
      sha256 "4bd53ddac67d0a90234266efd961732c1e4b2c089dab48e05aa876cb1803ec18"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.149/tune-server-v0.8.149-macos-x86_64.tar.gz"
      sha256 "68d2aa5f4030d51d8684d615fff0b5e442a1bb7fb66339b2eeb5f45897e705eb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.149/tune-server-v0.8.149-linux-aarch64.tar.gz"
      sha256 "c9a8699779053a636ef92e6eecc01e560247a97b490d6fd64294d0319520f780"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.149/tune-server-v0.8.149-linux-x86_64.tar.gz"
      sha256 "845ed808899d70b980a5819922a1940a0df9d7a7b1cb82169c13ebc675841fb6"
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
      Tune Server v0.8.149 (Rust) installed!

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
