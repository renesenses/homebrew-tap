class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.338"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.338/tune-server-v0.8.338-macos-aarch64.tar.gz"
      sha256 "d3f8799fd2f2052249b520d96641056c7ff033fc2afb69fa59d26021a98bf159"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.338/tune-server-v0.8.338-macos-x86_64.tar.gz"
      sha256 "c2972702a5dd94ecf1dfb38fd150b6d5f7f465604fb26f0223917b3e23fc57a8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.338/tune-server-v0.8.338-linux-aarch64.tar.gz"
      sha256 "3b43ff79dc0d0a03b09294c0bffd0e6f19fa6032d2fc7407b236233307d9ca84"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.338/tune-server-v0.8.338-linux-x86_64.tar.gz"
      sha256 "682ac65ccb66099e95493117bc8350f10ff5a4d94878f19d4c842eabd8976cdb"
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
      Tune Server v0.8.338 (Rust) installed!

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
