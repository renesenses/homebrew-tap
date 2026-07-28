class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.24"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.24/tune-server-v0.9.24-macos-aarch64.tar.gz"
      sha256 "f99097636c6637f61b6ec71e5c2f8c32e159950ce687b8f319b0266369f7f0b9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.24/tune-server-v0.9.24-macos-x86_64.tar.gz"
      sha256 "fe695fa513e76bf24ecd4b9e4e9ff3ec245ca7c002be338d7dfb2143d29bfb4d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.24/tune-server-v0.9.24-linux-aarch64.tar.gz"
      sha256 "538e8f4a511fb9abbc63cb6c10c6cf4247c3c7f65b832aa449f3aa7156c359d2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.24/tune-server-v0.9.24-linux-x86_64.tar.gz"
      sha256 "c6bd671a9e399d30f3a83aa934cde706d7a0752111768d3d0f1a618135d4cec1"
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
      Tune Server v0.9.24 (Rust) installed!

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
