class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.83"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.83/tune-server-v0.9.83-macos-aarch64.tar.gz"
      sha256 "94f402d9341d390fcc6f04f63856fce4eaabe2f87fb208c0f0ad61aa992d0ca7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.83/tune-server-v0.9.83-macos-x86_64.tar.gz"
      sha256 "99948db13080a5b654c7a10ab538528fdf2b659b50b7b390b3bc6827f0434c2d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.83/tune-server-v0.9.83-linux-aarch64.tar.gz"
      sha256 "5f1ea735f407c709220bedc74c0a52a5efbca980329cd42ae686876ded766821"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.83/tune-server-v0.9.83-linux-x86_64.tar.gz"
      sha256 "086871e5eb19e177b871788cf1b853ed10c17c2d2af61f41a698e7415c301150"
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
      Tune Server v0.9.83 (Rust) installed!

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
