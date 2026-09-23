class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.163"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.163/tune-server-v0.9.163-macos-aarch64.tar.gz"
      sha256 "584b2fc6be303c5eb177131352fe8432dee4f88d61d182895faad6c97156eaa3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.163/tune-server-v0.9.163-macos-x86_64.tar.gz"
      sha256 "2172ba72b02e54ef8ec3975c9118d009e6dab904f5c5e7af5a83c6bce605b26a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.163/tune-server-v0.9.163-linux-aarch64.tar.gz"
      sha256 "49078ec3c4a5a14cecf36fbde0871effa1502c2fbb30b27ef72a782cf53947de"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.163/tune-server-v0.9.163-linux-x86_64.tar.gz"
      sha256 "9b0903b62f909718de3002af327c89d6e7cee40d21b59f6a3f736aff329f22c0"
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
      Tune Server v0.9.163 (Rust) installed!

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
