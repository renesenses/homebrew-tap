class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.108"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.108/tune-server-v0.9.108-macos-aarch64.tar.gz"
      sha256 "877867c3f143e72aa59a5ccfba9248b33adf5907f79c2d686d19b2e04ed272cb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.108/tune-server-v0.9.108-macos-x86_64.tar.gz"
      sha256 "52c3f6d7812551df17af2add5e7bf671c1e4a56c8ecd19abc453bb0707f8bf11"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.108/tune-server-v0.9.108-linux-aarch64.tar.gz"
      sha256 "8011d8cc232faf85ad19fb88c34ea81f2bb6c4cb9cc3b990366ab33e107df017"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.108/tune-server-v0.9.108-linux-x86_64.tar.gz"
      sha256 "1ca93036af3824e9bee945e44619a1d3d18deecd7173e6000ee48300a8699253"
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
      Tune Server v0.9.108 (Rust) installed!

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
