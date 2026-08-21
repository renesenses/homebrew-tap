class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.93"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.93/tune-server-v0.9.93-macos-aarch64.tar.gz"
      sha256 "d0549b40470c50d802136cebfcc96b417646c7f1dc7526b3644296dd0aaddf52"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.93/tune-server-v0.9.93-macos-x86_64.tar.gz"
      sha256 "bb51aaf005b6e2637c4c7f9309eb1b41e0f09c5395eabea0c6fabd81dd325db1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.93/tune-server-v0.9.93-linux-aarch64.tar.gz"
      sha256 "0d4ad27ebc6159b3ff08b8ad1ba1f4ebf3a7b1fb8578b056cdc2397888b052e9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.93/tune-server-v0.9.93-linux-x86_64.tar.gz"
      sha256 "8947a6ca4c268989dfae27a414970d1b4642e1c43e259e363984b31275c9c9bf"
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
      Tune Server v0.9.93 (Rust) installed!

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
