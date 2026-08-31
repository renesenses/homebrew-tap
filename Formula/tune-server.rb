class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.129"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.129/tune-server-v0.9.129-macos-aarch64.tar.gz"
      sha256 "0546d8a3b12877c9f667a2fb0059a0b268ba1daef4212d4f4ea95c9be2a5623f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.129/tune-server-v0.9.129-macos-x86_64.tar.gz"
      sha256 "97927446afb9ce559bbf2c1f4ae3a1224fecca5ff5ba1741564b1e3ba2b668c3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.129/tune-server-v0.9.129-linux-aarch64.tar.gz"
      sha256 "ee31e961b9d484421abc37d0bfdadfd00f62ae91b07c1f78e2616dbb037ddcb7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.129/tune-server-v0.9.129-linux-x86_64.tar.gz"
      sha256 "0083473cfe5b85f31bbf1eb79d72ef992b0aec7aa225944ec6f64b8ac40a2524"
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
      Tune Server v0.9.129 (Rust) installed!

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
