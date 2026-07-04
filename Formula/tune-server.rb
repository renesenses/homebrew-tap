class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.253"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.253/tune-server-v0.8.253-macos-aarch64.tar.gz"
      sha256 "0a0982ea8baa5769f47f450989f46d41935e23630167358bde1c22ce63bd396d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.253/tune-server-v0.8.253-macos-x86_64.tar.gz"
      sha256 "29813a6fea95951b8b66a24108baa6a5ae4982c56d18a70ed8c386ae9c12aa74"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.253/tune-server-v0.8.253-linux-aarch64.tar.gz"
      sha256 "e3785306a88c69b17a0fd8c4649e1804e0fe80c5ca5726dd15aeb972dd930e1c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.253/tune-server-v0.8.253-linux-x86_64.tar.gz"
      sha256 "32c06f55fa348b8879d9075a48eb5fad508fc3b7da545498c00e88fa584ad279"
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
      Tune Server v0.8.253 (Rust) installed!

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
