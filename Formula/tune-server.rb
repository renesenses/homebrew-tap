class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.29"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.29/tune-server-v0.9.29-macos-aarch64.tar.gz"
      sha256 "3e7a442e7c4d1aa9305fc2a384ebb4b4cd93666fabbcd749be643f229d68ead3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.29/tune-server-v0.9.29-macos-x86_64.tar.gz"
      sha256 "8abbace0ff6cf828a57f676934eff9354722da844d2e4f22a6b53eb843ca98b6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.29/tune-server-v0.9.29-linux-aarch64.tar.gz"
      sha256 "12b15f51384713b82966bb6db5c4414d8032472f4887ff7bd4db6c338664af47"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.29/tune-server-v0.9.29-linux-x86_64.tar.gz"
      sha256 "272b4f25611c2d4ebd149a22b7f6ff7881c9ab3c15325f72070f3baab6c4d9a8"
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
      Tune Server v0.9.29 (Rust) installed!

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
