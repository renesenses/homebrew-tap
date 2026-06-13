class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.99"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.99/tune-server-v0.8.99-macos-aarch64.tar.gz"
      sha256 "42063d579894eb7716274ee954c41eadec86b286cd9cf1adbb62bce5686d4a57"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.99/tune-server-v0.8.99-macos-x86_64.tar.gz"
      sha256 "454dcfaf8dc4e91b3a21fe445a1ff1b04b2c1ef27d69b9d64f9c14d9aa8f0573"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.99/tune-server-v0.8.99-linux-aarch64.tar.gz"
      sha256 "058df8dd0f8f48f53316e16a1e1340de57654f59105c973c946ca29a8b81cef1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.99/tune-server-v0.8.99-linux-x86_64.tar.gz"
      sha256 "35388d406c716a441804fafb7a67bbe7e91d020937fd945b029187bde1e95770"
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
      Tune Server v0.8.99 (Rust) installed!

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
