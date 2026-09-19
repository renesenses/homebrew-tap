class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.156"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.156/tune-server-v0.9.156-macos-aarch64.tar.gz"
      sha256 "0c3576c8eeaa42e3d700e96d21e0606796037d4110b33046688d1b0b37ca342e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.156/tune-server-v0.9.156-macos-x86_64.tar.gz"
      sha256 "ba2e056075ea62929b91791a8d735593863adb088c6de669ba7b8c107eb07033"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.156/tune-server-v0.9.156-linux-aarch64.tar.gz"
      sha256 "d128093689b747eb79297e0b6fa472ac8d6cb12ab76551b49866fcfa61a2ab84"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.156/tune-server-v0.9.156-linux-x86_64.tar.gz"
      sha256 "6271138cdb02ff9ad60a371d3608cda885f9b16027a9f24671d1e9aa02e2129d"
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
      Tune Server v0.9.156 (Rust) installed!

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
