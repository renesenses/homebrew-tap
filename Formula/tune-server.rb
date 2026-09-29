class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.168"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.168/tune-server-v0.9.168-macos-aarch64.tar.gz"
      sha256 "ceb8ea252fbd5b5ba478033417885af8fed19e82500a20d86517554d85b2af98"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.168/tune-server-v0.9.168-macos-x86_64.tar.gz"
      sha256 "127133a1fd73c4ce18b22832d615c724134a0f53b175e59fae9e8e1788fa8277"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.168/tune-server-v0.9.168-linux-aarch64.tar.gz"
      sha256 "a4190275d9cad88578c698d56ccce63bfc1c92baf92473e4651bec06e6e738f4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.168/tune-server-v0.9.168-linux-x86_64.tar.gz"
      sha256 "dffb6af61a4dd4908e5171897da47970f49e1c3a72ad84f7332747812b7f6c53"
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
      Tune Server v0.9.168 (Rust) installed!

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
