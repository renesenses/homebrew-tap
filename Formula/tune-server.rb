class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.126"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.126/tune-server-v0.9.126-macos-aarch64.tar.gz"
      sha256 "3386934a71dd2958d63ede3b06ed6fe665c419ca48a5effc4d77eb7100c8d08a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.126/tune-server-v0.9.126-macos-x86_64.tar.gz"
      sha256 "0da283357563df0a1ff4f7598dfadaf86701f307e6f6e2d41c88d314c4944e0a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.126/tune-server-v0.9.126-linux-aarch64.tar.gz"
      sha256 "73359af281e88d769d644989a90a68cafbd6da162d34fdacbdbe267619c61282"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.126/tune-server-v0.9.126-linux-x86_64.tar.gz"
      sha256 "62d7e6a59cefeb313ae3242ce5ffaa4a65dc779ca4dcf376319aa19c022a7103"
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
      Tune Server v0.9.126 (Rust) installed!

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
