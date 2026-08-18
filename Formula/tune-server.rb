class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.85"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.85/tune-server-v0.9.85-macos-aarch64.tar.gz"
      sha256 "98b6e359c6cdebf8833d07a328fae1b04934a29552ee25c65fc7738628aa5d08"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.85/tune-server-v0.9.85-macos-x86_64.tar.gz"
      sha256 "204bf2d6e8abd1e482a0675959a5af6fbc61327e3cdc664a786fdcaa5c732bc2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.85/tune-server-v0.9.85-linux-aarch64.tar.gz"
      sha256 "fbbc566cb5905255190afd7c3a8ef172283400912bc4810928462ea8ec8fb356"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.85/tune-server-v0.9.85-linux-x86_64.tar.gz"
      sha256 "f13e3a443faab9b6865434f11cabf7ba862e6bb381b3491baabe5cbf61ae3213"
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
      Tune Server v0.9.85 (Rust) installed!

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
