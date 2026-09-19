class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.158"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.158/tune-server-v0.9.158-macos-aarch64.tar.gz"
      sha256 "a18e200f3375cdb4ac8f2f53c582e71155a5667ac24e4690567abf38cc7ede3b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.158/tune-server-v0.9.158-macos-x86_64.tar.gz"
      sha256 "77077046ffacf5bcd916181b90131add9459d189a6abdefb020e9650e7b5ab51"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.158/tune-server-v0.9.158-linux-aarch64.tar.gz"
      sha256 "c0c7e77ef48f9b077f7ec8cd1f3fba023373fdd2388e0a1953d3cead00059dc7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.158/tune-server-v0.9.158-linux-x86_64.tar.gz"
      sha256 "035768bf5a9e250ea18551da8671fdcb4f1438bbdbdfa3540cb918a527979ae4"
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
      Tune Server v0.9.158 (Rust) installed!

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
