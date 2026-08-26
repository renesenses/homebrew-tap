class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.111"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.111/tune-server-v0.9.111-macos-aarch64.tar.gz"
      sha256 "6e641a8cde734b43d5cfa12cd41f65fb2d86c17a5cb9304dcb48e80e3ed67e8d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.111/tune-server-v0.9.111-macos-x86_64.tar.gz"
      sha256 "17c7cdd3eaac6732e18e040302c8435d37b2f8e39b35277ee07ad441a8e17641"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.111/tune-server-v0.9.111-linux-aarch64.tar.gz"
      sha256 "c165a28450ebe8170d1c19ed07e9f01f40b92e9ebaae81d4957211e6c2b19394"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.111/tune-server-v0.9.111-linux-x86_64.tar.gz"
      sha256 "a6c5252ac9e45b527fdbbafc201ba3e685bb1530a8a8eb6824abf6bcbbb34e04"
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
      Tune Server v0.9.111 (Rust) installed!

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
