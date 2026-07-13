class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.0-rc2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0-rc2/tune-server-v0.9.0-rc2-macos-aarch64.tar.gz"
      sha256 "8df45a1bd60c0276e1a4009ebc716fcd4a7c834621852bbe61c481768c14da64"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0-rc2/tune-server-v0.9.0-rc2-macos-x86_64.tar.gz"
      sha256 "ff5c6955fb4057bbe4880d4673376b863f348cbe823b18adfdd8f85a50a7552c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0-rc2/tune-server-v0.9.0-rc2-linux-aarch64.tar.gz"
      sha256 "56745c1d340acfb887bb239bfe04afd6480ac6cec07f369edbf1316296da6585"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0-rc2/tune-server-v0.9.0-rc2-linux-x86_64.tar.gz"
      sha256 "e2cfc22bc8ea013d9d7482ad7333de0e83369aed1d964157a9927a842a881ce0"
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
      Tune Server v0.9.0-rc2 (Rust) installed!

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
