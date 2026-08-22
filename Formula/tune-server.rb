class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.99"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.99/tune-server-v0.9.99-macos-aarch64.tar.gz"
      sha256 "5463bd5e03c39d7df833424fc0dccad5ddc94ad57bd5b543c1f6fe3f047f6b6f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.99/tune-server-v0.9.99-macos-x86_64.tar.gz"
      sha256 "d8877385221fb0de42a75798ea17c7d568d1efedb7f8ca2fbd04346a6077df7a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.99/tune-server-v0.9.99-linux-aarch64.tar.gz"
      sha256 "7fc238b7ec1d41f6846063f82cb0b5c3b2f38bcf61da093a714ac834efefa851"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.99/tune-server-v0.9.99-linux-x86_64.tar.gz"
      sha256 "4a8249d2a76d6e51a6c9d0dfd1ad75467022a0a204a6b276d40d1569dd2bdec4"
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
      Tune Server v0.9.99 (Rust) installed!

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
