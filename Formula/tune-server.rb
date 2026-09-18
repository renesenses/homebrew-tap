class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.154"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.154/tune-server-v0.9.154-macos-aarch64.tar.gz"
      sha256 "5fa8eba1343c26581594db17c59a19f008492ba927f3999ab065a2de04dc29d6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.154/tune-server-v0.9.154-macos-x86_64.tar.gz"
      sha256 "955f2e2acff87e6104a0046d76b44020fdd40aabe14fac76897bd1ffed66203d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.154/tune-server-v0.9.154-linux-aarch64.tar.gz"
      sha256 "acb114ab2963239f83804b760c408b141afdb996dea93cd2b04d3a626810e884"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.154/tune-server-v0.9.154-linux-x86_64.tar.gz"
      sha256 "2c52fe41f56f8e0958d53162e5aac5ccd51707bdaeaa40c875ff53c19a5563cf"
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
      Tune Server v0.9.154 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

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
