class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.91"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.91/tune-server-v0.9.91-macos-aarch64.tar.gz"
      sha256 "5cbd530b4dafa39979a6c03a8ac2a89f3b09bfa066a009bf24a8d066abdd7b0e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.91/tune-server-v0.9.91-macos-x86_64.tar.gz"
      sha256 "f646cdb8ddcd51f4201610da2801e8a11ba1a98f22288c58a05174221ce87f57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.91/tune-server-v0.9.91-linux-aarch64.tar.gz"
      sha256 "b5ae6e93b3a6f92b9e18c5e382b58621c532a12d72c050541a9caacf9eb97c6c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.91/tune-server-v0.9.91-linux-x86_64.tar.gz"
      sha256 "f1135e2a835096b2f6b3d13f090991ae3751e942e5d6eb3c4839ae2320427d3d"
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
      Tune Server v0.9.91 (Rust) installed!

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
