class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.79"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.79/tune-server-v0.9.79-macos-aarch64.tar.gz"
      sha256 "5cc91f622c383a4a469e303a537046c70184521b35b37f2b03fe651da4c46abe"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.79/tune-server-v0.9.79-macos-x86_64.tar.gz"
      sha256 "0df3031950ffe604592c1626fac6e3f48c1110bf87af8a14d53a54768d7e1c0b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.79/tune-server-v0.9.79-linux-aarch64.tar.gz"
      sha256 "8e71b05b01d2b3d00c368de842c25a9c33d71f88266980064e8ceaabb9de7813"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.79/tune-server-v0.9.79-linux-x86_64.tar.gz"
      sha256 "304a5760014177fed03c079fde6e51419e6883a2f8470a527f1e433b0ce16026"
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
      Tune Server v0.9.79 (Rust) installed!

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
