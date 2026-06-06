class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.53"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.53/tune-server-v0.8.53-macos-aarch64.tar.gz"
      sha256 "c3c73291d92bb2e880564239136e7ebc2cd8a200d478695a35e50d9ac8be16d0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.53/tune-server-v0.8.53-macos-x86_64.tar.gz"
      sha256 "0cb421be8fba36faa8360c017aed3e6b94a820f115ab0589cb7bed8bfdfbe115"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.53/tune-server-v0.8.53-linux-aarch64.tar.gz"
      sha256 "23a84ec24b2665ab4a7eb86aa709be71d44b81d9d765574cd95fd544b5761555"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.53/tune-server-v0.8.53-linux-x86_64.tar.gz"
      sha256 "bdbc1907a1e709eb944df10a5b454b164ce7410221aed215b9d8e8650ee196b1"
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
      Tune Server v0.8.53 (Rust) installed!

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
