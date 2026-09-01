class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.130"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.130/tune-server-v0.9.130-macos-aarch64.tar.gz"
      sha256 "65916295470115b83257795becf8b50cbb8b6a4a50399b52eb53316c8764c798"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.130/tune-server-v0.9.130-macos-x86_64.tar.gz"
      sha256 "39c9043b4cea5d3030abdca09a6f8c26d01158d2fdd87e7e027817107b873a8e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.130/tune-server-v0.9.130-linux-aarch64.tar.gz"
      sha256 "e0a6f31a7a7c70d0039a62875fa42399b422b0805043172170582aa3a66aafc8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.130/tune-server-v0.9.130-linux-x86_64.tar.gz"
      sha256 "a77fc75b42a876c0fd88e5b39e4fb33779041470fa450d3189a70461e73573b2"
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
      Tune Server v0.9.130 (Rust) installed!

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
