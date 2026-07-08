class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.285"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.285/tune-server-v0.8.285-macos-aarch64.tar.gz"
      sha256 "7b32e7d906e1684b7f322e2d8b3a0c45982ca3b5dbdea898a234e5b9221f5dbf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.285/tune-server-v0.8.285-macos-x86_64.tar.gz"
      sha256 "f5eb8200cfc9afd021df7940bf7e680b7358e3561a24764b8c5cc8961caa168e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.285/tune-server-v0.8.285-linux-aarch64.tar.gz"
      sha256 "6a849a4630fd0948026e8e124790dedbc258a91da7aada74165acaa902013539"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.285/tune-server-v0.8.285-linux-x86_64.tar.gz"
      sha256 "d2aa3c9c720e385a5239098b15e701be83c6ee92a2a0d862102cc24390bc5c32"
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
      Tune Server v0.8.285 (Rust) installed!

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
