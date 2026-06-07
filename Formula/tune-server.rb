class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.57"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.57/tune-server-v0.8.57-macos-aarch64.tar.gz"
      sha256 "ee3fdd94d5465a18389afe7d3d3a805b327cd8aef6800fdf1d89981668e33d3c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.57/tune-server-v0.8.57-macos-x86_64.tar.gz"
      sha256 "96114ead81077c202731fbfaabbe970f8c899a8f486c3fcf96c923ecc86d2310"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.57/tune-server-v0.8.57-linux-aarch64.tar.gz"
      sha256 "a2329e8ce035ca4091f9d6c819ac62bea5d78dc7cd3351d2d90eccdb7726c8fb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.57/tune-server-v0.8.57-linux-x86_64.tar.gz"
      sha256 "adc0244f0bf162c0416587e4a569e1fbb2436d7b573f28227c09236dee7c7fab"
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
      Tune Server v0.8.57 (Rust) installed!

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
