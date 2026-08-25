class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.110"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.110/tune-server-v0.9.110-macos-aarch64.tar.gz"
      sha256 "d951b43a68be8f77ceb73840f2a9e5d6af38f2750fb852cad09330a39a7b4639"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.110/tune-server-v0.9.110-macos-x86_64.tar.gz"
      sha256 "9f5972f07181d3b46b2eb7e929a471df0a279891910fb3dfb586a00a3bc6e999"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.110/tune-server-v0.9.110-linux-aarch64.tar.gz"
      sha256 "79122c30d4d697aefb6a85f0dcb0ae8710aac12695ed32589f49e3f263bd7cdf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.110/tune-server-v0.9.110-linux-x86_64.tar.gz"
      sha256 "97aed3417dad4089e07aa8e5cb6176d34eddd4b30584b6336c066c730823d819"
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
      Tune Server v0.9.110 (Rust) installed!

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
