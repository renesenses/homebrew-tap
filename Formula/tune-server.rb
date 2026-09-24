class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.164"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.164/tune-server-v0.9.164-macos-aarch64.tar.gz"
      sha256 "a7a5b4d8d5319a00b581d561b59ff61edda0df2c16d6618828f6b9395ff6cae8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.164/tune-server-v0.9.164-macos-x86_64.tar.gz"
      sha256 "ba3113fc0031529140e711960cccd5fa7d90743cea51e2f5c7447b03b43605ae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.164/tune-server-v0.9.164-linux-aarch64.tar.gz"
      sha256 "333fa79a87441cc592ada9ce8dbec8a93cfc2c9e9c4ddaf1ac05138add48a1ff"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.164/tune-server-v0.9.164-linux-x86_64.tar.gz"
      sha256 "2ead3ab104747a7a14d4bc5e22345d4f55df6f6a41dc5886dc470fd847dd3d54"
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
      Tune Server v0.9.164 (Rust) installed!

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
