class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.152"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.152/tune-server-v0.9.152-macos-aarch64.tar.gz"
      sha256 "1f1040585389a5f1936134551bfd7c0154c8449b3070bade7aa9905832bf8073"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.152/tune-server-v0.9.152-macos-x86_64.tar.gz"
      sha256 "6686ddc7608c3b3a658437a8a609e8b38c4414242d2e7816bf301a497a280b51"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.152/tune-server-v0.9.152-linux-aarch64.tar.gz"
      sha256 "bec7ee9c97e167ed0a0beca60a51089c6304c3f45e32f438266580152ad21b2b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.152/tune-server-v0.9.152-linux-x86_64.tar.gz"
      sha256 "6b1dcaeaf69b4f0ba9855adb83bf63e4255d4d72a988d3645d4f806e89baff50"
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
      Tune Server v0.9.152 (Rust) installed!

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
