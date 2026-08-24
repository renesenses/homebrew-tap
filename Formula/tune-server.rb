class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.104"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.104/tune-server-v0.9.104-macos-aarch64.tar.gz"
      sha256 "181b5d67fd3e1f0d652dc626826e22c03d3e2b7d3923253fc5a5f7083413e729"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.104/tune-server-v0.9.104-macos-x86_64.tar.gz"
      sha256 "7e1db42895af0cd74a6a8b0d6213a8e787df9ee8737b0a48cd7d42719886de8a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.104/tune-server-v0.9.104-linux-aarch64.tar.gz"
      sha256 "c42e848221481177d741eac23a6ef229300111d8cd1976d64c4c1192e2f4e69c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.104/tune-server-v0.9.104-linux-x86_64.tar.gz"
      sha256 "61e58718b3ba17875e5897b25528ed2ecdb873248145a5ba2b1562b2acaf187f"
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
      Tune Server v0.9.104 (Rust) installed!

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
