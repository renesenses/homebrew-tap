class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.245"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.245/tune-server-v0.8.245-macos-aarch64.tar.gz"
      sha256 "bf8bab53c9495e826044ef31385b7829b57c1ace2eb9b3b8510cc1472688d2f2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.245/tune-server-v0.8.245-macos-x86_64.tar.gz"
      sha256 "53bd2a45aa97bf530c2a9e6adde44a0e8e9f9b44c22fed67859e730b49e98ddd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.245/tune-server-v0.8.245-linux-aarch64.tar.gz"
      sha256 "3c30abde9be52344d69d9d071700c120afbe99b305da445ee20b1c8a372baab7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.245/tune-server-v0.8.245-linux-x86_64.tar.gz"
      sha256 "7bd97db373c00a8e672a4a2491383fb5565c0b5b639586e1efa277090ea7e8b7"
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
      Tune Server v0.8.245 (Rust) installed!

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
