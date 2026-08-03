class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.42"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.42/tune-server-v0.9.42-macos-aarch64.tar.gz"
      sha256 "c1497c323b8260bfb9483a40b6520290e86d390fedacd89f0fdd6f4363109a98"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.42/tune-server-v0.9.42-macos-x86_64.tar.gz"
      sha256 "d4359be85b331f0440037e0f2d233f005145155dc886fa4a8c5056c25d24d4d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.42/tune-server-v0.9.42-linux-aarch64.tar.gz"
      sha256 "c31253eb633c7568c770a124bb0f82addcf9c5a4d053c25f86de174d2d60d073"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.42/tune-server-v0.9.42-linux-x86_64.tar.gz"
      sha256 "01412d31186b014229bea4c131389112a0b9c708e372bf705f3ae8638fc3eaa8"
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
      Tune Server v0.9.42 (Rust) installed!

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
