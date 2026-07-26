class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.14"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-macos-aarch64.tar.gz"
      sha256 "e042e1d92a7a5a48685e3c753b4dc9cadcbe2b9e27d03331c20632da34143767"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-macos-x86_64.tar.gz"
      sha256 "63467448bd5b3ea29b651da21b51da8245d4c985afcf4d3722efac61311e5f57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-linux-aarch64.tar.gz"
      sha256 "e1b3c390ce64f52b6024d86979431d94cebf649e6961d11628d7d93c6319cb4f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-linux-x86_64.tar.gz"
      sha256 "0b8668250589e6fcd2d0fe4c48d5eaa7216a75f0d183ecaf3cf2c3ce4c30bd8f"
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
      Tune Server v0.9.14 (Rust) installed!

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
