class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.117"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.117/tune-server-v0.9.117-macos-aarch64.tar.gz"
      sha256 "2ec83ed6f543df87e4477df76c2c0c9de8db75ebb34c7418b3ec4c630a056ba1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.117/tune-server-v0.9.117-macos-x86_64.tar.gz"
      sha256 "b73f10016ed953cfac9765c8856eaf75e840578a588bdf0f2f7e58b695c1713e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.117/tune-server-v0.9.117-linux-aarch64.tar.gz"
      sha256 "0545d8d9f38c80589885607b5c4b8a68fe08ec710af4b436c65a17295c11a439"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.117/tune-server-v0.9.117-linux-x86_64.tar.gz"
      sha256 "7a73b15f56f5b08fc4fa76d51d30c254d4efa7d27d9655df48b6a827ec661320"
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
      Tune Server v0.9.117 (Rust) installed!

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
