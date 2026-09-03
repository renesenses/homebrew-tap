class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.132"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.132/tune-server-v0.9.132-macos-aarch64.tar.gz"
      sha256 "f30e994d4a88804f1b7d7179b1ba73a2152b07191295614ea5785241a640efb6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.132/tune-server-v0.9.132-macos-x86_64.tar.gz"
      sha256 "0969307cba49e52e09624e36bd9071a4476586ae0ddfb7fade3ab04a5f72ab21"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.132/tune-server-v0.9.132-linux-aarch64.tar.gz"
      sha256 "e8d9164f58fba3e488577341c66db22a480c51612b5c44bf13def95cc766f54f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.132/tune-server-v0.9.132-linux-x86_64.tar.gz"
      sha256 "30f170df3c70e2db1bbb8d81e02c5caddc32af793c329b6b9460aa180ad36de2"
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
      Tune Server v0.9.132 (Rust) installed!

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
