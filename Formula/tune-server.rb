class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.136"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.136/tune-server-v0.9.136-macos-aarch64.tar.gz"
      sha256 "932bf34ca96661ab079d3aa777d2908b0af94fe3a815897adc204f4dc5cab031"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.136/tune-server-v0.9.136-macos-x86_64.tar.gz"
      sha256 "afd7c2538b78c3d2b438a6ba589f0db40a3fea000c611cf7bb762cda5462747d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.136/tune-server-v0.9.136-linux-aarch64.tar.gz"
      sha256 "d4269270d3bab962339bbbe31420a44b56927c8a5c411c24a1543a405a3a47a9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.136/tune-server-v0.9.136-linux-x86_64.tar.gz"
      sha256 "676d5a8bc24c99b58a0a1b34936f1ecdd5e50e05be441b94ad6bc4809f5615e3"
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
      Tune Server v0.9.136 (Rust) installed!

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
