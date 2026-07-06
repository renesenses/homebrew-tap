class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.266"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.266/tune-server-v0.8.266-macos-aarch64.tar.gz"
      sha256 "19a470f5c969dfa3860cc4484e3287dc0e82f50c1f46867d2a84addb9d53248a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.266/tune-server-v0.8.266-macos-x86_64.tar.gz"
      sha256 "d811509dd2c3a711f7d59a3e62a3d43ed0f32907a78fe57c9aa8134c4363fea7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.266/tune-server-v0.8.266-linux-aarch64.tar.gz"
      sha256 "91b62ff2cb8e5d015b746869d522bb253223b93fc598e5834f13f89b02d6c1b8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.266/tune-server-v0.8.266-linux-x86_64.tar.gz"
      sha256 "74e77695a4fc27cf2e0478146c912221f89729357340cd4f753d9ee32fb32ae7"
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
      Tune Server v0.8.266 (Rust) installed!

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
