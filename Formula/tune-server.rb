class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.41"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.41/tune-server-v0.9.41-macos-aarch64.tar.gz"
      sha256 "4119960822a1e955b5d4d3b31e7ddebd2ce4adcf3ad26717a0fff6631f65367a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.41/tune-server-v0.9.41-macos-x86_64.tar.gz"
      sha256 "b757d4df108233905437b3d78ac116d31e177dbce7b5126483ae6ca7b892e259"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.41/tune-server-v0.9.41-linux-aarch64.tar.gz"
      sha256 "acd6a09a670ff71629be7324fe4c270cbc50ea718780822318e190691fb18874"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.41/tune-server-v0.9.41-linux-x86_64.tar.gz"
      sha256 "897e9f76e122c0ad0401b910b100308c78448fc7e0f805b05fb6c23404033759"
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
      Tune Server v0.9.41 (Rust) installed!

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
