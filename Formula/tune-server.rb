class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.5/tune-server-v0.8.5-macos-aarch64.tar.gz"
      sha256 "cd609962199bcc9c1f502dfbd39530eb5db352409fb7c98ddf7ee638fbd15912"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.5/tune-server-v0.8.5-macos-x86_64.tar.gz"
      sha256 "81df3dabbc078488d19468481fa7b54dd13c5cfc1772106ae909ed688b5ccedb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.5/tune-server-v0.8.5-linux-aarch64.tar.gz"
      sha256 "242282644ed8c418669561091c04acb27ed1558cd23cedb34081c928b00670dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.5/tune-server-v0.8.5-linux-x86_64.tar.gz"
      sha256 "426260f0b6766a5f2c70732c027688cb5097d4e7dc3cdf10d52e4149ae5c5487"
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
      Tune Server v0.8.5 (Rust) installed!

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
