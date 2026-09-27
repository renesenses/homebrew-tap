class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.167"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.167/tune-server-v0.9.167-macos-aarch64.tar.gz"
      sha256 "6c647cbe2d7370989c7ad028af617458a337c4877a109f1fcd0716b75178dc89"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.167/tune-server-v0.9.167-macos-x86_64.tar.gz"
      sha256 "21b8bf8442303818c010d74d6b868d192c1528916ad480a4e1c27016303c80e1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.167/tune-server-v0.9.167-linux-aarch64.tar.gz"
      sha256 "2635a343a9135ac5c32c711e9a8526df10766d02b23a8a0276accb918ff385cc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.167/tune-server-v0.9.167-linux-x86_64.tar.gz"
      sha256 "e70200d6346f7ef94b0b3a11b7910fab026dde9a8a9b5d343cc47d3f7605feb4"
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
      Tune Server v0.9.167 (Rust) installed!

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
