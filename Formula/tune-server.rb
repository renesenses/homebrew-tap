class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.162"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.162/tune-server-v0.9.162-macos-aarch64.tar.gz"
      sha256 "3912a7c8ac841349b29dcf95acaa3b4583af3a2f85758097de9bc37d39e969b9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.162/tune-server-v0.9.162-macos-x86_64.tar.gz"
      sha256 "d9b1a477666cc9d7d2b511a543da650574756b145a02f85c247ed170189957ac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.162/tune-server-v0.9.162-linux-aarch64.tar.gz"
      sha256 "fe5f474bfac2ce47ca2f49385aeecc1914364b97f6e94e95c1d1f631244a2f92"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.162/tune-server-v0.9.162-linux-x86_64.tar.gz"
      sha256 "4749c7bc7b0225fe66805f8a9c5b71270afb9137a33918a5a1e3a06dab2d2ea2"
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
      Tune Server v0.9.162 (Rust) installed!

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
