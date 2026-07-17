class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.330"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.330/tune-server-v0.8.330-macos-aarch64.tar.gz"
      sha256 "cd3aaefb267b504dbaaa93a5fa3a28301e0a7e1e62890fd91e3ed0893e38a77c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.330/tune-server-v0.8.330-macos-x86_64.tar.gz"
      sha256 "7a99b6e817802eaff5452a01cbdd2ed09f6d62abc21cd914c9c38bcfd77eead9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.330/tune-server-v0.8.330-linux-aarch64.tar.gz"
      sha256 "6a1c0e540077d46fc03a8b515807e7852bc84e62b6e4cb03b7d18e4c90b41071"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.330/tune-server-v0.8.330-linux-x86_64.tar.gz"
      sha256 "929ccd143d8825e92c18294f609dd80465a41ef948d22bb5f0506ead440db16c"
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
      Tune Server v0.8.330 (Rust) installed!

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
