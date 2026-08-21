class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.96"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.96/tune-server-v0.9.96-macos-aarch64.tar.gz"
      sha256 "f73bd24ac673699b08566627217a5c2f989b01ad57e14033f3ea13de3cb7d425"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.96/tune-server-v0.9.96-macos-x86_64.tar.gz"
      sha256 "1b2bd8ce424023530d1ad73e2c6d7a3286f3914fbb6a9ad5b6760d5026fd6706"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.96/tune-server-v0.9.96-linux-aarch64.tar.gz"
      sha256 "18a6f7e4985f2e160ac21969012e1aec0375ceb0bd5a4a922a181847b84f3916"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.96/tune-server-v0.9.96-linux-x86_64.tar.gz"
      sha256 "1637a1a4f52ac9a8f653ddc3897738b0ff61f6e9653a6acb7a714a583da83026"
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
      Tune Server v0.9.96 (Rust) installed!

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
