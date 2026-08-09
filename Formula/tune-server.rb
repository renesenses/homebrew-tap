class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.63"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.63/tune-server-v0.9.63-macos-aarch64.tar.gz"
      sha256 "43f4fe3789d9e3ef8da76770ea01816476068aa05454a5cb486f7f8b7bc69bb2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.63/tune-server-v0.9.63-macos-x86_64.tar.gz"
      sha256 "52ce84406e88c7e43558925e7eea0151583985165d3f99048dce0b769c9af05c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.63/tune-server-v0.9.63-linux-aarch64.tar.gz"
      sha256 "7775073b71a201c449f9c5333a97bed705415a8200bedec1015a9678f586c0ee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.63/tune-server-v0.9.63-linux-x86_64.tar.gz"
      sha256 "55f12e5712ac7631978a2d13e9a0a0a4ff9e7d85d86eb8f71265baaf0bd4c8bf"
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
      Tune Server v0.9.63 (Rust) installed!

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
