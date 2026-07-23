class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0/tune-server-v0.9.0-macos-aarch64.tar.gz"
      sha256 "c41ebc883252097da944941345065f094c9869be1af3c3a49a76d48e1cbaf3f7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0/tune-server-v0.9.0-macos-x86_64.tar.gz"
      sha256 "dbb09b4136d07c639de6e63b1f6d5af4f690dcfa0248e9bc02cd89da0d9da73a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0/tune-server-v0.9.0-linux-aarch64.tar.gz"
      sha256 "b8fb17c3a2172bddc92ad25530a9ee3b495331a34de81dc11dfaaefd0bc5f313"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.0/tune-server-v0.9.0-linux-x86_64.tar.gz"
      sha256 "03e70ddb312990d57bea8345c261f1a68b966e3a31fd54822ba44a2f859c867e"
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
      Tune Server v0.9.0 (Rust) installed!

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
