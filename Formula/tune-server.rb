class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.118"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.118/tune-server-v0.9.118-macos-aarch64.tar.gz"
      sha256 "fb2a8bff188fd219f7d2c3a62a6d1b99741a826a489340e980f01157feb9336c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.118/tune-server-v0.9.118-macos-x86_64.tar.gz"
      sha256 "6cfc1011cc4099d87900fdae53aa91c0dd0dcfc5ba739e771d3d6ab4814769a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.118/tune-server-v0.9.118-linux-aarch64.tar.gz"
      sha256 "845438d5065873e5796c062e8c2f1310e0f4bb890ef0abc7d6a627a3395940f7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.118/tune-server-v0.9.118-linux-x86_64.tar.gz"
      sha256 "7d99de50f6250cf55cbff649fc9f8e645ecfa5bb841c63ddd29ed9d25698a77d"
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
      Tune Server v0.9.118 (Rust) installed!

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
