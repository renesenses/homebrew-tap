class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.226"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.226/tune-server-v0.8.226-macos-aarch64.tar.gz"
      sha256 "025c297afe002e1f13b5734df1ce01a999ca7e7c78f7e05e24d2d73dbb6678d3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.226/tune-server-v0.8.226-macos-x86_64.tar.gz"
      sha256 "67490ce450031e9342db39c91865a2ce129e53b1fa6b5063e8217113a59ea4a3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.226/tune-server-v0.8.226-linux-aarch64.tar.gz"
      sha256 "babd811e86b1e3858ea5f07077cbf52ca4d3c475ebb9d0cb2d086b05e4ea8bde"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.226/tune-server-v0.8.226-linux-x86_64.tar.gz"
      sha256 "eb52c03b0f1659fa550400f686057a332651cf33681c4793ba0c046850237d8a"
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
      Tune Server v0.8.226 (Rust) installed!

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
