class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.43"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "0ec4ae7f7e97b74f9ade420a592ce3276f6644f89f35e611d21e2bc3e1406185"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "9f3c1aadb417abecdea7b111df60d1d64ceedac2538026867f25b00cdc5f3071"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "62fd2b7b4707b9bdc8af296644229f8bd99aea3cc8802039300f5a2b8817d0ad"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.43/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "c954fb27443f7de5c83f54d7213850f1c88119705ce677d55fdc400ddbedaf74"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.43 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

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
