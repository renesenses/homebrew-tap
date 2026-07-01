class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.224"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.224/tune-server-v0.8.224-macos-aarch64.tar.gz"
      sha256 "e3de697056afb0b6107d8dd250aec590a4c844299ceeb6badd57e7f292497002"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.224/tune-server-v0.8.224-macos-x86_64.tar.gz"
      sha256 "2a7b5ecd0fa1075b3d698bf357e86a700b368d048aeaf5eea51ed7d8d3b31478"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.224/tune-server-v0.8.224-linux-aarch64.tar.gz"
      sha256 "15dee0b8dd3b1b50dcdb565fc41eb2668d8f5b714ae6861cfa123a6e35cddbc2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.224/tune-server-v0.8.224-linux-x86_64.tar.gz"
      sha256 "1285e984c116c973bee172a8ba19dde769b7a80919ca71ccbf29012dcb50c365"
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
      Tune Server v0.8.224 (Rust) installed!

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
