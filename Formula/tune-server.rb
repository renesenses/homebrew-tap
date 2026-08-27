class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.114"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.114/tune-server-v0.9.114-macos-aarch64.tar.gz"
      sha256 "5e43805b34f19fd499a3a1aac5ee503b4f8669c4e3f6679250c98b9bf32fed2c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.114/tune-server-v0.9.114-macos-x86_64.tar.gz"
      sha256 "8ab4bb1055be6c22bf05cd94efc9ed3773b9490bd1909bf2249c44024eb58b30"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.114/tune-server-v0.9.114-linux-aarch64.tar.gz"
      sha256 "725f7e8ba2c6b03e3729a30543b46150aa17ae5c6b1e532761be3e0ff420c65d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.114/tune-server-v0.9.114-linux-x86_64.tar.gz"
      sha256 "1d43c35affa8cf70b74ddcc108b4e5cbfac2e120a1809325bd5eaa76901d5ea8"
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
      Tune Server v0.9.114 (Rust) installed!

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
