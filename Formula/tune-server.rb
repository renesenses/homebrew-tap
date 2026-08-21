class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.95"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.95/tune-server-v0.9.95-macos-aarch64.tar.gz"
      sha256 "9cd43a8cf079fc2296c0fc764ea136c1836a1eb6b9783419d7d01ebbbed84628"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.95/tune-server-v0.9.95-macos-x86_64.tar.gz"
      sha256 "4b8a08a4aaf4c3eae360824eb4adf30dbcbdc7d04f0e67bb5b03f3f982f55a6b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.95/tune-server-v0.9.95-linux-aarch64.tar.gz"
      sha256 "07c660f7d0364bd7cca6ce0e325c3402ac6ca94ace91207caa7e194150cba981"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.95/tune-server-v0.9.95-linux-x86_64.tar.gz"
      sha256 "fcb06eacdf0b93cabb7296c79f3895dc6de3fbb7959f904103a42e8546f09fc4"
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
      Tune Server v0.9.95 (Rust) installed!

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
