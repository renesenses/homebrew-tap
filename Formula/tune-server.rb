class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.131"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.131/tune-server-v0.9.131-macos-aarch64.tar.gz"
      sha256 "94a23fcf00a41b7b500ab6d8760a96d9c9c53d2a7bf8af2749918b015fba74b0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.131/tune-server-v0.9.131-macos-x86_64.tar.gz"
      sha256 "53c56936ac589cb23e0f72f42cbe4f80ab5d4e21d0207e6d428716975d50cd89"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.131/tune-server-v0.9.131-linux-aarch64.tar.gz"
      sha256 "8ee2d1af348434e4e61434a19ebe786ca51396aae6f58e487a2ff802a8d1ebca"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.131/tune-server-v0.9.131-linux-x86_64.tar.gz"
      sha256 "4b5ddfa4719a045fcb91fdd708d90c1fc14214907bebfe8d33a9409fa1a38bd8"
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
      Tune Server v0.9.131 (Rust) installed!

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
