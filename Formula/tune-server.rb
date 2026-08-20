class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.90"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.90/tune-server-v0.9.90-macos-aarch64.tar.gz"
      sha256 "bcc2f01310bc6a7b03074f2c423b4b482647c481f4f8d103e7cf6a0bd61bfef8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.90/tune-server-v0.9.90-macos-x86_64.tar.gz"
      sha256 "4343b4294b6b778d0186b3b25a1e9dabd45e0bb7bfa21ccdd58853978c8f5b4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.90/tune-server-v0.9.90-linux-aarch64.tar.gz"
      sha256 "379cc6291af47b8e49c5091fbd189d4a1511e927bf97dd6491917f71b4bd0e89"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.90/tune-server-v0.9.90-linux-x86_64.tar.gz"
      sha256 "aade901b21543283fe8abb46561dfa74f5505413e27d9980c0602316c362bd97"
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
      Tune Server v0.9.90 (Rust) installed!

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
