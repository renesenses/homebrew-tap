class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.217"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.217/tune-server-v0.8.217-macos-aarch64.tar.gz"
      sha256 "cc53a3739cf887b44ede4e6e8c1235364cca08937650825d9dbf62e5700adad7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.217/tune-server-v0.8.217-macos-x86_64.tar.gz"
      sha256 "c42311cfaf366aa2d96bb7f488d26db572e06cec2b704e3f5df4d8f944e067d9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.217/tune-server-v0.8.217-linux-aarch64.tar.gz"
      sha256 "457db633d63abb5b70ee3abb24b5f8e1ccf41710db0f05e3603ff4fc2e0b258c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.217/tune-server-v0.8.217-linux-x86_64.tar.gz"
      sha256 "e0738f5cd0e8e19cf386adde06efd33722e0f2b60331a844f3054a5210ed5c32"
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
      Tune Server v0.8.217 (Rust) installed!

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
