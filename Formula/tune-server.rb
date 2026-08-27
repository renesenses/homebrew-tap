class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.116"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.116/tune-server-v0.9.116-macos-aarch64.tar.gz"
      sha256 "a528508a6d963f904024c1a068ac17e53a75ca134a0252e05b67a57b28bdae6a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.116/tune-server-v0.9.116-macos-x86_64.tar.gz"
      sha256 "c541657af0ed3c9a7b36a64165744e3cbf93e02d912128506454f647c130eafd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.116/tune-server-v0.9.116-linux-aarch64.tar.gz"
      sha256 "b0e5817a407d3e3b5ba47ddb45d4560da42bf54ad3b47d38034dcbeb932f9c21"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.116/tune-server-v0.9.116-linux-x86_64.tar.gz"
      sha256 "8360a2902c63901ea56258efd0b33a723b936b800e7fc353b939e7c6aebd5349"
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
      Tune Server v0.9.116 (Rust) installed!

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
