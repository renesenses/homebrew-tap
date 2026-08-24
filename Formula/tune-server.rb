class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.102"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.102/tune-server-v0.9.102-macos-aarch64.tar.gz"
      sha256 "c12f36671ff34fb1f64d040c17492a30ac5f32c14ab693f0869138d7f5584f7a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.102/tune-server-v0.9.102-macos-x86_64.tar.gz"
      sha256 "3b7ecf841bf9196072daec8f4379014a7cf770fb0e15ef9e2b41a0f7bf09be3b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.102/tune-server-v0.9.102-linux-aarch64.tar.gz"
      sha256 "14f4ab4ebc892c787a741de233ea63aba794c660772db55fb30fd4530666042d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.102/tune-server-v0.9.102-linux-x86_64.tar.gz"
      sha256 "a9b2118f0891630b2d028cf590206996a98bcd8b054a4db3e70e358aaec39e30"
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
      Tune Server v0.9.102 (Rust) installed!

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
