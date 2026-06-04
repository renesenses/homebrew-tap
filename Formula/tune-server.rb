class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.43"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "5b2ac0d94b249151b4930e1347e8f3eb627e0af63bcae9807b37e3a1bade8e80"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "2cdf3def44724fc56b173c6c3cb7e9b8c15d51954ff7560eb1014d751d4e4a32"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "7971fc5f224333b51f47cc2ea0c46b0f793cabc5dacc5b12c3b706d2a4f0f1c1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "8d04c6e1fcf23e32e641d490342c6f0e954c68ddfe13471be45822eb93275a25"
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
      Tune Server v0.8.43 (Rust) installed!

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
