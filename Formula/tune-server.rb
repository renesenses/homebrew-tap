class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.2/tune-server-v0.9.2-macos-aarch64.tar.gz"
      sha256 "eeb012cce6fefdddfe7c7e06ae408b6bfce141230eeb263ef430e003da9142b3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.2/tune-server-v0.9.2-macos-x86_64.tar.gz"
      sha256 "cec662ff128c8cf40c70fa6555b123934b08c57b15559d9a9cb4fabd25acbddb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.2/tune-server-v0.9.2-linux-aarch64.tar.gz"
      sha256 "376c3e3493af1b2275347ff2c61c14156db7c4e933849bc03207dea55d39ff15"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.2/tune-server-v0.9.2-linux-x86_64.tar.gz"
      sha256 "bc87e177bde948a8063283a8df2bdc75ff47a95e993b214946bda3648b47c2ea"
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
      Tune Server v0.9.2 (Rust) installed!

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
