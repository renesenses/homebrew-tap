class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.143"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.143/tune-server-v0.9.143-macos-aarch64.tar.gz"
      sha256 "2d8fb5a30c30b87253e313d6c25b832d88b0f1d21491227176cc313f844d5c4f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.143/tune-server-v0.9.143-macos-x86_64.tar.gz"
      sha256 "09ca1a7b11baa384854b000e0d97eb0652f7e514a7899c5b5b3fc7c148c89045"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.143/tune-server-v0.9.143-linux-aarch64.tar.gz"
      sha256 "2bf5d753debeaba62fd8eca16a6b862baeb0e495909775c2c6a4bcf31aa50f3e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.143/tune-server-v0.9.143-linux-x86_64.tar.gz"
      sha256 "9ebd5c4625824462be22b665cc616ff059cd807dae687b8c22fb7a824ad9bb0c"
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
      Tune Server v0.9.143 (Rust) installed!

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
