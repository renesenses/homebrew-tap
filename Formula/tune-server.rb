class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.61"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.61/tune-server-v0.8.61-macos-aarch64.tar.gz"
      sha256 "5317128c8a1961558d7a387c9fd96ed7c2bb6961696f3522708d8f9cdc0e0a75"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.61/tune-server-v0.8.61-macos-x86_64.tar.gz"
      sha256 "02aaf3ade6f37f0f950a8c94a31ff533d1a60d4ecb44c543507b33cedebdc60d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.61/tune-server-v0.8.61-linux-aarch64.tar.gz"
      sha256 "047dc6d1d69ecb537f36df21f37f3b5725f89c96ac24230061202a9f3b2e32d4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.61/tune-server-v0.8.61-linux-x86_64.tar.gz"
      sha256 "803449d950511570574e5d697bcbb8d1adcbf21da7484639ee1737dc84fb87ee"
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
      Tune Server v0.8.61 (Rust) installed!

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
