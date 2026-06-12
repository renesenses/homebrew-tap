class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.87"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.87/tune-server-v0.8.87-macos-aarch64.tar.gz"
      sha256 "1010c6bacc5c8d4663aca10a2e0ff0e68c4f2ade1c03210fc0ff9edff88cd7ac"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.87/tune-server-v0.8.87-macos-x86_64.tar.gz"
      sha256 "deed16859d915484e3469b3b3cf7ba5e91738dd908177dab3d3df8642a4a0ec3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.87/tune-server-v0.8.87-linux-aarch64.tar.gz"
      sha256 "be82ae9b27654440ce9bc35ec3606c77bddd1d0a8aeacc47dfa3ea115d1462c1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.87/tune-server-v0.8.87-linux-x86_64.tar.gz"
      sha256 "9138b7ab4a95ec7f286a2135f1c4b9d053c06fc5b1f663166e93800e3c46e9bd"
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
      Tune Server v0.8.87 (Rust) installed!

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
