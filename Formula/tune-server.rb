class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.146"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.146/tune-server-v0.9.146-macos-aarch64.tar.gz"
      sha256 "080a884e1b1a477aebb1e733b595f5690c65452cf06c79a3633bb344c70d9380"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.146/tune-server-v0.9.146-macos-x86_64.tar.gz"
      sha256 "95b2462f954c0373eae7177ad76629943002c027516b6482e4b2b65d392790b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.146/tune-server-v0.9.146-linux-aarch64.tar.gz"
      sha256 "6c2907f00cda2dea3399af4771ffd251d723ced72310f2927ce4bbe4b65b7adc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.146/tune-server-v0.9.146-linux-x86_64.tar.gz"
      sha256 "fe35eb08f28653ac4a630863775595bbef8107d28519c5874fbb309cb10e4d85"
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
      Tune Server v0.9.146 (Rust) installed!

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
