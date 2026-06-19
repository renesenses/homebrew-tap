class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.142"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-macos-aarch64.tar.gz"
      sha256 "5df6992ff1922aca442d76be07e4b6b14a5e2b28267523de2b28724c2314be0a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-macos-x86_64.tar.gz"
      sha256 "f6288fcfc6a99fb4950f09ed0fa0554f083b78f68d9b6925f9254d2ab0d10084"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-linux-aarch64.tar.gz"
      sha256 "7a37fa12cfea8a4c480ecd97e46229d0f85633938d91be336ddd3e9af9f147a7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.142/tune-server-v0.8.142-linux-x86_64.tar.gz"
      sha256 "a936a834a57e4b484585c45c9e155424d193b1f6ea93c5aea8918cb3ae08c397"
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
      Tune Server v0.8.142 (Rust) installed!

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
