class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.119"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.119/tune-server-v0.9.119-macos-aarch64.tar.gz"
      sha256 "f1e7bdfed3726e64bd1c1d7d989194c16f3e09f08ed8189ebf102876324cc976"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.119/tune-server-v0.9.119-macos-x86_64.tar.gz"
      sha256 "bca0141a1f1eeb89861d26f59f84e15a11bae9fbeb5ed5a7ca16fac47d17ae8e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.119/tune-server-v0.9.119-linux-aarch64.tar.gz"
      sha256 "c6fba0ab40e931a3c2e887e3e7a04510d3ad514133a9823160c49241e8ab5fbb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.119/tune-server-v0.9.119-linux-x86_64.tar.gz"
      sha256 "2f4b7f02b86339b445e9fba94407aa5747b2d31f42fe34e50cf0a996fb7aaae6"
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
      Tune Server v0.9.119 (Rust) installed!

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
