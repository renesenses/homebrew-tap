class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.134"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.134/tune-server-v0.9.134-macos-aarch64.tar.gz"
      sha256 "87d9fee739508271e4f4498b1a30d86348b3c64537228a07ad0b89889dad94ea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.134/tune-server-v0.9.134-macos-x86_64.tar.gz"
      sha256 "9f529eb992d9793430cf21f4996ab75df6836ebe031bb0c731a62d35a5be1df2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.134/tune-server-v0.9.134-linux-aarch64.tar.gz"
      sha256 "013c65f7b5cb479e37fd9eb9904ce20f2e4895e2bfb5bacb0a13589a4b45383b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.134/tune-server-v0.9.134-linux-x86_64.tar.gz"
      sha256 "551a77c3a57eb811628dd878d99a9c8b67cfa09bff53e3a2b6de52073a4db0c7"
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
      Tune Server v0.9.134 (Rust) installed!

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
