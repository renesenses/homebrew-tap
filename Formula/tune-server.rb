class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.323"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.323/tune-server-v0.8.323-macos-aarch64.tar.gz"
      sha256 "05c63ee44859e93539f4f3e1e84d8d40dd5ce0be4016bdbede85970c5e35dd9d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.323/tune-server-v0.8.323-macos-x86_64.tar.gz"
      sha256 "ffd79106a4af86e575b8918f3f8f45999d8ccb4f6626bf023d92288a73a4c445"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.323/tune-server-v0.8.323-linux-aarch64.tar.gz"
      sha256 "b5b90d7b0c428a57f785a0c7f6f22093b40cf2898be02905dd0450e4443a782a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.323/tune-server-v0.8.323-linux-x86_64.tar.gz"
      sha256 "b1476864a0db4485b8399270f00594b3135d5455aecc94d1dbdf3967153dc832"
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
      Tune Server v0.8.323 (Rust) installed!

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
