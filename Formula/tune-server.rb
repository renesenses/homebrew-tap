class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.89"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.89/tune-server-v0.8.89-macos-aarch64.tar.gz"
      sha256 "fb49ab1eac1355f95c53fabf3084df39fa896e87b748bb5fa2cf9a14dac689da"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.89/tune-server-v0.8.89-macos-x86_64.tar.gz"
      sha256 "348e75b0aa5700dc3cfedeb2b9d4c7c2b2130da6eb7e0d916da06286e39c8a78"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.89/tune-server-v0.8.89-linux-aarch64.tar.gz"
      sha256 "c73c6e4689d1558809408550a34cb5cb91bca7b00b4dd5b985aa7c208d0217e6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.89/tune-server-v0.8.89-linux-x86_64.tar.gz"
      sha256 "fc692498d4cd6a950bb41d3bfa11518638e956ed7aba5c26c6be2f613f361ab0"
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
      Tune Server v0.8.89 (Rust) installed!

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
