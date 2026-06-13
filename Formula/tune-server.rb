class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.93"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.93/tune-server-v0.8.93-macos-aarch64.tar.gz"
      sha256 "0b1dc91f80a928d170cb32138902f8e6d0db6f280828052e23868513e4fa16a0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.93/tune-server-v0.8.93-macos-x86_64.tar.gz"
      sha256 "dd3dd24161290b0610b572ca01bb2b2c987e054c14a6eb5c865a06c91c0a3511"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.93/tune-server-v0.8.93-linux-aarch64.tar.gz"
      sha256 "2dc69adb3de53c053bb1990c90ba55cc0857d2774a745f09b4d8e396fadeb361"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.93/tune-server-v0.8.93-linux-x86_64.tar.gz"
      sha256 "e43667e43f6ae2ccc00891b05e6679ba36f1f910fcce8e93318968960b0cadf9"
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
      Tune Server v0.8.93 (Rust) installed!

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
