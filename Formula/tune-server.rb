class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.275"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.275/tune-server-v0.8.275-macos-aarch64.tar.gz"
      sha256 "1b493b23d0d89674cb37597487cf8c18914dc4308d9a03e8badd733c69bdf6be"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.275/tune-server-v0.8.275-macos-x86_64.tar.gz"
      sha256 "9f8ad47bda81b4e3dce711fa5a4d6961a817369f29b2ec834e792d57e467c1d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.275/tune-server-v0.8.275-linux-aarch64.tar.gz"
      sha256 "71297be9afc470d667d299258fda7a9cf7e5602017a0371b1f2da50edfb5c2e1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.275/tune-server-v0.8.275-linux-x86_64.tar.gz"
      sha256 "682668ce55958840f556e8dd6520d3a87367132e642fcd0263a6e16329e51e48"
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
      Tune Server v0.8.275 (Rust) installed!

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
