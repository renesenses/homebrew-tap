class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.144"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.144/tune-server-v0.9.144-macos-aarch64.tar.gz"
      sha256 "4dd9bd1d9722e46eee87df3a6c0d89944885b8a75542b3413f4f313dff11bd4a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.144/tune-server-v0.9.144-macos-x86_64.tar.gz"
      sha256 "77d9f34a6fadb24ced69da398b9044604d4b1b38fb63c83f87a851bdf80ac1da"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.144/tune-server-v0.9.144-linux-aarch64.tar.gz"
      sha256 "563e74ee94a88003c0b5bbbc209a22ffdd03d5f9814a09dd30d00702cecb2156"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.144/tune-server-v0.9.144-linux-x86_64.tar.gz"
      sha256 "9413d847377815aa8d5fdffd9359e00e3399fa07d67063d240e81ba07f53d47f"
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
      Tune Server v0.9.144 (Rust) installed!

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
