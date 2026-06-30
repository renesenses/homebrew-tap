class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.209"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.209/tune-server-v0.8.209-macos-aarch64.tar.gz"
      sha256 "b1afafc59ba5f8602f1e9b17d5a7feb571185387e10e9586d1c0c138e93e3d96"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.209/tune-server-v0.8.209-macos-x86_64.tar.gz"
      sha256 "57abdefb55f07c61180699bfc710f0e9f10d138c7af4f2c9391430ea58c1f3cd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.209/tune-server-v0.8.209-linux-aarch64.tar.gz"
      sha256 "6433bec942b9fe8b0f915da451096ccf399cd8e4d4b965e5e9397c426c003ffa"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.209/tune-server-v0.8.209-linux-x86_64.tar.gz"
      sha256 "34f24a53f04fbf3a95adfc6df387bf6ef1e30ddc0ebd84d1b088fb46b2618ab4"
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
      Tune Server v0.8.209 (Rust) installed!

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
