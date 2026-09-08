class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.142"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.142/tune-server-v0.9.142-macos-aarch64.tar.gz"
      sha256 "30ab6790b40e81f7755459109e460a65540eb7a64ed8b8accd9984725eaa8125"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.142/tune-server-v0.9.142-macos-x86_64.tar.gz"
      sha256 "052dd983efc8ff8f7a8a56273763a84c6886b14742812ed1c5bc1ed9b3743aea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.142/tune-server-v0.9.142-linux-aarch64.tar.gz"
      sha256 "1f1330df47e949e5bbda965cbc5c9639565caa98536fedc0595553c00d0b833e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.142/tune-server-v0.9.142-linux-x86_64.tar.gz"
      sha256 "294cffba07af47e8aeb8b7c0cb77249c7dccc377ed1ac54799cff66f099cac0e"
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
      Tune Server v0.9.142 (Rust) installed!

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
