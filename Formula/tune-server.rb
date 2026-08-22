class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.97"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.97/tune-server-v0.9.97-macos-aarch64.tar.gz"
      sha256 "780236f27eb008fbcfe214c3cf408dff431faa35628e91d2be30183197c36c96"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.97/tune-server-v0.9.97-macos-x86_64.tar.gz"
      sha256 "cbd292743206de5966fe614df98932f34157d6e5c18500728259dd38507db936"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.97/tune-server-v0.9.97-linux-aarch64.tar.gz"
      sha256 "9b54b5c2714086d50b97ffee69233c03f8fc165071a8fade7837927bcb26728d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.97/tune-server-v0.9.97-linux-x86_64.tar.gz"
      sha256 "98a26304e76d3f894f7c342f4d9951dcae7a505f0a9e148b89cea1c76e36bbde"
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
      Tune Server v0.9.97 (Rust) installed!

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
