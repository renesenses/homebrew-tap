class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.12/tune-server-v0.8.12-macos-aarch64.tar.gz"
      sha256 "64de597cea848a51fb9eb3291be86152277c7a6bb046abd2c94c6ae2e916feaa"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.12/tune-server-v0.8.12-macos-x86_64.tar.gz"
      sha256 "b6c9b5c6fec960a376e37dd5be50b1d1b0881d1a877cda3b5317c68c19d0b988"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.12/tune-server-v0.8.12-linux-aarch64.tar.gz"
      sha256 "aabc0ce06f13153fa12dc92a3e4d7109ff7a2ea46fe2bbcb83f21290e277cbe0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.12/tune-server-v0.8.12-linux-x86_64.tar.gz"
      sha256 "18b56b9a1dee2646a6c4fb1df6330fc68ec70aa6312ba80be069e44ed1b07170"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.12 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

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
