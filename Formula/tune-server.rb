class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.16"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.16/tune-server-v0.9.16-macos-aarch64.tar.gz"
      sha256 "988ec42b741b4e2cae498e0aceb28f978349e1e6dfc01124af1c16fd9f7640d9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.16/tune-server-v0.9.16-macos-x86_64.tar.gz"
      sha256 "c5666a696021028869bf993d619be542957628524dc3a961f608566ddeee2a0d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.16/tune-server-v0.9.16-linux-aarch64.tar.gz"
      sha256 "18472cefe36b3499fcc23bb8e8d3f3840570d8cb80719cb3539c7eaa3ff505a2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.16/tune-server-v0.9.16-linux-x86_64.tar.gz"
      sha256 "b2d22b39e390cb14dad461fcf2c80b4da6e39e0f9ed906e73c81488641fc1881"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
      export TUNE_WEB_DIR="#{pkgshare}/web"
      exec "#{bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.9.16 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Legacy Python version: brew install renesenses/tap/tune-server-python
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
