class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.150"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.150/tune-server-v0.9.150-macos-aarch64.tar.gz"
      sha256 "4d0a3b89df99d105242c31484d022557f307ad8f40de8b954defbf596b634552"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.150/tune-server-v0.9.150-macos-x86_64.tar.gz"
      sha256 "1959dd79ea035fbfbdd1097ce60671e3b12b28cb905d82012e302c94b33a79a0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.150/tune-server-v0.9.150-linux-aarch64.tar.gz"
      sha256 "e4731331f4dfe565fb4b6ebd2c045593dad392743b8ee780e595e64e8dbf7cb1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.150/tune-server-v0.9.150-linux-x86_64.tar.gz"
      sha256 "4848ca4b6bb675eb69c6d1a299efbbcf4144a02bdcc3aecf7ca6cf4c6fade1f4"
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
      Tune Server v0.9.150 (Rust) installed!

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
