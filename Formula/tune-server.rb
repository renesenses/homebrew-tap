class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.98"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.98/tune-server-v0.9.98-macos-aarch64.tar.gz"
      sha256 "4d1756c4a113157f1fbdee192b739686a7597d6c1787f0717cd4f686b494ef23"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.98/tune-server-v0.9.98-macos-x86_64.tar.gz"
      sha256 "4bef7e4393e4fc69e4c49aeffddccde92477bb532456db46b7a85e0cff0a5075"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.98/tune-server-v0.9.98-linux-aarch64.tar.gz"
      sha256 "24841545598eeda6d35b3348dba626c64d63e9a7a96f0f9120542cc0ee3bbfe8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.98/tune-server-v0.9.98-linux-x86_64.tar.gz"
      sha256 "d4e599f6d4645d34ad8714c352072a93af3fc80469d49ee96ba8c0ec4780def7"
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
      Tune Server v0.9.98 (Rust) installed!

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
