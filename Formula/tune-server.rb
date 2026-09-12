class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.147"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.147/tune-server-v0.9.147-macos-aarch64.tar.gz"
      sha256 "864db8a0861876ff725ec5a63428e0bafdf4b27dd6119bd697d9a56dbd44ddef"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.147/tune-server-v0.9.147-macos-x86_64.tar.gz"
      sha256 "9ee30eb40d820959538e8b17c17671b1d9bb54cf8868b37bd667d5b53d751c5d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.147/tune-server-v0.9.147-linux-aarch64.tar.gz"
      sha256 "4748bdc9d7da2e920778ef9c16685764d9cef848f2decc70025faf8c523af612"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.147/tune-server-v0.9.147-linux-x86_64.tar.gz"
      sha256 "7e18e6c543bf93de00eb671ecc68bff983c75656c36a6bb9231f3df89bed419f"
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
      Tune Server v0.9.147 (Rust) installed!

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
