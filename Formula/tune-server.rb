class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.161"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.161/tune-server-v0.9.161-macos-aarch64.tar.gz"
      sha256 "562fd8ab9ff102db742581a9d791ed3ba1826bdb05e57608644aaecb38b180c0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.161/tune-server-v0.9.161-macos-x86_64.tar.gz"
      sha256 "c6a629f529e2a18798eaa9e5bcb50b60235d85e4efbed94d8e91836659df48c5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.161/tune-server-v0.9.161-linux-aarch64.tar.gz"
      sha256 "9c7b91c1571b8057e30efb1c2967e4ecc78552bcca5cfa661e364f47a14ba7f5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.161/tune-server-v0.9.161-linux-x86_64.tar.gz"
      sha256 "b043bd1495478f7fda5fdce74ae276a7b0e8927d7b97982f46bbde89b1aeed88"
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
      Tune Server v0.9.161 (Rust) installed!

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
