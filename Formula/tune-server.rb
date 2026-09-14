class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.149"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.149/tune-server-v0.9.149-macos-aarch64.tar.gz"
      sha256 "a48bd13f3f7550cd019cb4e7c6ae5d970ccae6fd4c6731cf140cb1b7d8f7eb20"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.149/tune-server-v0.9.149-macos-x86_64.tar.gz"
      sha256 "2b25195dd37f12eeda279cb9126cb8157b8473b2d08c10321524526c7a02d86d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.149/tune-server-v0.9.149-linux-aarch64.tar.gz"
      sha256 "e17e209f79300e1faaaf6d9159fdbca443d9cd9a32de48b6c41648b4ae254766"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.149/tune-server-v0.9.149-linux-x86_64.tar.gz"
      sha256 "c7c726e21ab2196075a40705cfb54e3dcc17a193ebbc7f5015b47fc7821f9864"
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
      Tune Server v0.9.149 (Rust) installed!

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
