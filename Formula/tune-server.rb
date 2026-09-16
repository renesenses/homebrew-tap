class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.151"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.151/tune-server-v0.9.151-macos-aarch64.tar.gz"
      sha256 "f0af5dbcf62017bca735e77c2633ba0b796dfb5700161c0870c831206bd549af"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.151/tune-server-v0.9.151-macos-x86_64.tar.gz"
      sha256 "6de6b8eaae0f06788b5f15b112f618dda099002e01fc3fc75dd67dbfe62b9838"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.151/tune-server-v0.9.151-linux-aarch64.tar.gz"
      sha256 "8022beee3f7a5768efabd42dddb3151810b34f660e282a3fdff588e368c01f30"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.151/tune-server-v0.9.151-linux-x86_64.tar.gz"
      sha256 "e6937b5c51756a63a29c1af01a4b4d1702a4611f98628071d2652d7520e58ed2"
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
      Tune Server v0.9.151 (Rust) installed!

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
