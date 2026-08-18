class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.84"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.84/tune-server-v0.9.84-macos-aarch64.tar.gz"
      sha256 "0f0dbaceb59cf41cc1e6a53692b11aded900094fa95fafc10a1615cb9518e530"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.84/tune-server-v0.9.84-macos-x86_64.tar.gz"
      sha256 "6397437ea79163d9c90bd08df0281321258d338136719728ea07184d6445677d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.84/tune-server-v0.9.84-linux-aarch64.tar.gz"
      sha256 "629c3d76ae06f01f9cc649864c4fd18ad9ef80c4e206b49f0d04cf2de38a7e5a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.84/tune-server-v0.9.84-linux-x86_64.tar.gz"
      sha256 "fd20a3f483cc0ec4db95c75b32efec1bbfd851be1e1693ffbcd5dd3825011ff1"
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
      Tune Server v0.9.84 (Rust) installed!

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
