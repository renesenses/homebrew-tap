class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.43"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.43/tune-server-v0.9.43-macos-aarch64.tar.gz"
      sha256 "12973f8cee05c40cebba4bf996bcd27ee4b9348dee44d1e86181f5ac4937370e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.43/tune-server-v0.9.43-macos-x86_64.tar.gz"
      sha256 "ea6b7bace3f922cbf3d021508e407bf88b4eb3fc74f51a1488042298f4db26a5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.43/tune-server-v0.9.43-linux-aarch64.tar.gz"
      sha256 "e9b2a349805ae5e0a7a28d3c7881bef6f5f2a038a1a44f94fde43958a903e247"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.43/tune-server-v0.9.43-linux-x86_64.tar.gz"
      sha256 "712871428c421de309433ff086fdd458e686f2fd9719fb15a2810c45d27cb65c"
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
      Tune Server v0.9.43 (Rust) installed!

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
