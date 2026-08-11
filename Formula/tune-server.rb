class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.68"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.68/tune-server-v0.9.68-macos-aarch64.tar.gz"
      sha256 "4f8c9a03cdea16ea4faac3bc76203e3ae6eabfbee4c7e1a5e90e01e29cfaccff"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.68/tune-server-v0.9.68-macos-x86_64.tar.gz"
      sha256 "d8e9b850c32ee826a90c5795e0381e642d20393d261073deb81662c86fa7e914"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.68/tune-server-v0.9.68-linux-aarch64.tar.gz"
      sha256 "5a2a1e0272f6bce6a615bf7d1cf2f460c4677ce9a694bab2a07b4f0f46c0c3e9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.68/tune-server-v0.9.68-linux-x86_64.tar.gz"
      sha256 "05be316cb4354f071052cfbc4dce2dcc8160329551139be93a538babc07c64db"
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
      Tune Server v0.9.68 (Rust) installed!

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
