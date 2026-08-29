class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.124"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.124/tune-server-v0.9.124-macos-aarch64.tar.gz"
      sha256 "1043449d54a9adc811bfc5e9dc7734f4c62d06df12445bd4dd1570e7385bb0d2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.124/tune-server-v0.9.124-macos-x86_64.tar.gz"
      sha256 "c7271d7a8265401044a2222696a0e83a8a2f49ecb128c4ce44c607ed861006e0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.124/tune-server-v0.9.124-linux-aarch64.tar.gz"
      sha256 "1d2c0cd36edc4117eace10292caf5a7559e557208602acf36f69ef56781b4f28"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.124/tune-server-v0.9.124-linux-x86_64.tar.gz"
      sha256 "b7dcab27d3857b8a67b095c75a838b89a2c89697098428583aa1caef606d2be6"
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
      Tune Server v0.9.124 (Rust) installed!

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
