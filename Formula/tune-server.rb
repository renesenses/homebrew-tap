class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.284"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.284/tune-server-v0.8.284-macos-aarch64.tar.gz"
      sha256 "e10bb24e88194dc33551aff048dbc59ac074a09a0d550ae2a67970c0af62d00e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.284/tune-server-v0.8.284-macos-x86_64.tar.gz"
      sha256 "e26b3ec0ea960ccd32fe018c0e9d0b8974906900de7cedd2ab0d85766d3fa0da"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.284/tune-server-v0.8.284-linux-aarch64.tar.gz"
      sha256 "2a959955f08462fd39c7e2193f06798bf8157ad2d836bbcd717551bb07f5bf85"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.284/tune-server-v0.8.284-linux-x86_64.tar.gz"
      sha256 "5ece5671e0e56fd0673ae4fbc97595ac630639204cc8683bf503e8b63dfa99b7"
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
      Tune Server v0.8.284 (Rust) installed!

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
