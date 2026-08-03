class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.44"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.44/tune-server-v0.9.44-macos-aarch64.tar.gz"
      sha256 "9409b9d12790dfb7c61d828b587223b0319528d91229272e17985c52c335a1a2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.44/tune-server-v0.9.44-macos-x86_64.tar.gz"
      sha256 "90dad7c10d540e458281a57711916f7e0037dfed07579d308007c9b030698e0c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.44/tune-server-v0.9.44-linux-aarch64.tar.gz"
      sha256 "a8c4a8b9c666d73e3d3eed5ba4229cffeba1fa2ceb688a80e754cd3c5aca1f7b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.44/tune-server-v0.9.44-linux-x86_64.tar.gz"
      sha256 "9e15cc919aa66b5ca4bd458295d5f22073041e467558c537537c5aeb204a9824"
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
      Tune Server v0.9.44 (Rust) installed!

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
