class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.205"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.205/tune-server-v0.8.205-macos-aarch64.tar.gz"
      sha256 "48bfb4eda3315d0043f1b370481d1c2b074a87c6da2c35022865fc9b06985a5d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.205/tune-server-v0.8.205-macos-x86_64.tar.gz"
      sha256 "f2749d30f68cbac9966324fce205f5c81d1df83d10d6a12d80d810b97446bdf8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.205/tune-server-v0.8.205-linux-aarch64.tar.gz"
      sha256 "b25456b9cca3d787bc2b4df89c80d71572e20713993cd9f963eb84b644ee6a34"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.205/tune-server-v0.8.205-linux-x86_64.tar.gz"
      sha256 "f7baa7595dd4e7e761e4db86de26d62fc3714f140e32c240885dce37113f5559"
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
      Tune Server v0.8.205 (Rust) installed!

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
