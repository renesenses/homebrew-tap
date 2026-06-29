class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.203"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.203/tune-server-v0.8.203-macos-aarch64.tar.gz"
      sha256 "3aeae81c2ba1ffb4ceabcd29f0e8f68f3b886a3c33bb9759d75a20fd5273126f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.203/tune-server-v0.8.203-macos-x86_64.tar.gz"
      sha256 "85afbd59efcc8613edf5ca40637d6108d45e8b20a590cfdd9a9f28134c9e291c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.203/tune-server-v0.8.203-linux-aarch64.tar.gz"
      sha256 "440e96ce2289686ae758a954f6cfb00e0ae60f4fc09b91c8820afc8962910fab"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.203/tune-server-v0.8.203-linux-x86_64.tar.gz"
      sha256 "f34b2404748764bb28bc8fd187e75cd5e786c63a9c39d4c06421fb8ae07b529c"
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
      Tune Server v0.8.203 (Rust) installed!

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
