class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.59"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.59/tune-server-v0.8.59-macos-aarch64.tar.gz"
      sha256 "484e68e8d7fccb987d71e8e92cc287782f587d54470dc01524cdc956a16bcf8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.59/tune-server-v0.8.59-macos-x86_64.tar.gz"
      sha256 "9ffe376d987188599d9dcb86a337c4fa0ceb81d1601a8fab22ba80896e42609d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.59/tune-server-v0.8.59-linux-aarch64.tar.gz"
      sha256 "6703f8908b4bd0ecac24ca9b7197222b8a52eedef9a395c31f563c26675e92c6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.59/tune-server-v0.8.59-linux-x86_64.tar.gz"
      sha256 "625c68b3b7c1ac1640751736cb2e18b0da12f9e268dc3d1c91b5eacac22b2de3"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.59 (Rust) installed!

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
