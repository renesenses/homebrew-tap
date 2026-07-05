class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.260"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.260/tune-server-v0.8.260-macos-aarch64.tar.gz"
      sha256 "6bd6f6a5e08637dde7a229199ccae51cd435963a59f8be95ca3e09accb911a12"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.260/tune-server-v0.8.260-macos-x86_64.tar.gz"
      sha256 "6afd7adc4ded867c5ad02f0cdc95525a7654af405b4710067b4d2d7988a251ad"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.260/tune-server-v0.8.260-linux-aarch64.tar.gz"
      sha256 "9c6c219f8b2f9ac533309dff5ffeafc475c31b3d1262caf08a80d5307465c048"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.260/tune-server-v0.8.260-linux-x86_64.tar.gz"
      sha256 "0589d7728aca7ed928482fa8755f4491e8da0521a298c168d41b6a1d8bac7dee"
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
      Tune Server v0.8.260 (Rust) installed!

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
