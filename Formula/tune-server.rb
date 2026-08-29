class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.125"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.125/tune-server-v0.9.125-macos-aarch64.tar.gz"
      sha256 "e8bf3726fc393fd41d2f1d0f57e37aea7cc4894808c287e170c253096707d79b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.125/tune-server-v0.9.125-macos-x86_64.tar.gz"
      sha256 "29de79d2dcbaa78c0a1eb48a65b62d4503f73abd7f1b65e92f0ef6fc11528604"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.125/tune-server-v0.9.125-linux-aarch64.tar.gz"
      sha256 "a87ba64c1dfcb085dcad8cb0f2d96571334bd914784dd34cd568da78f06fdf9a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.125/tune-server-v0.9.125-linux-x86_64.tar.gz"
      sha256 "7d0b0c45b5374095ecd2a873911c01df430bf23e7fbb53cb0efa9d0bed60b3e9"
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
      Tune Server v0.9.125 (Rust) installed!

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
