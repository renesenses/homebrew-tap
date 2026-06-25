class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.178"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.178/tune-server-v0.8.178-macos-aarch64.tar.gz"
      sha256 "e046e137e2bdbac9cc7f9dcb476dcfbe8059dcaba68fde1ebf62699b0b10a74c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.178/tune-server-v0.8.178-macos-x86_64.tar.gz"
      sha256 "610ffcebb45863e9add67cb7df6dcaff5483c3e9da68b52aa810d2f36fa8c3ca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.178/tune-server-v0.8.178-linux-aarch64.tar.gz"
      sha256 "272f1e1bb1c05c228d0de3c52009226697395f38fe6b520ec7af57785696a65e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.178/tune-server-v0.8.178-linux-x86_64.tar.gz"
      sha256 "bec191a1ade52c99bb506fa38f81a14d28036f09fb19cc9c5f25a62273eb0329"
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
      Tune Server v0.8.178 (Rust) installed!

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
