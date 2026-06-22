class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.152"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.152/tune-server-v0.8.152-macos-aarch64.tar.gz"
      sha256 "074839f4c415b7f1756771de5489c5b99cda0ec41510ae1aa318b6f045a9dcc4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.152/tune-server-v0.8.152-macos-x86_64.tar.gz"
      sha256 "653acfbd24af8090d63fadbb95d835c4c2b9d227782720e6dd83fa6d266b337f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.152/tune-server-v0.8.152-linux-aarch64.tar.gz"
      sha256 "79eeafc9a4f84c380fd809a70d6ae872717496a25eb68eef1b4c578ff37ebd5b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.152/tune-server-v0.8.152-linux-x86_64.tar.gz"
      sha256 "393f030c6322e4a9f0c3f0a10eb14f1299bb885169d92dc77282c43599151e82"
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
      Tune Server v0.8.152 (Rust) installed!

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
