class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.14"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-macos-aarch64.tar.gz"
      sha256 "82429fb82a2b1bca20891754d80f2c6f1a05247313a9071254e300adfea092cc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-macos-x86_64.tar.gz"
      sha256 "2d2f0f972c32da653bf02e7ae870583d016013d8a0cab41d128699b912fe1d6f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-linux-aarch64.tar.gz"
      sha256 "40b84a72fba2b6bb7d3429adc61be98e93c99bc3e1d366373aba24ef4bbe1b08"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.14/tune-server-v0.9.14-linux-x86_64.tar.gz"
      sha256 "62912ada9475acc8931a3fd4e803b4513191e133f43c20cd155a5fc3a8007e3d"
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
