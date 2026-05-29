class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.3/tune-server-v0.8.3-macos-aarch64.tar.gz"
      sha256 "e3fb52f9cb2700d609cc49165e3cf87d1f859fd1b01456294c695a3976b6befb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.3/tune-server-v0.8.3-macos-x86_64.tar.gz"
      sha256 "ea103e1cfa872927eb9b5c05739600eee3fd0ea5d22792341954ab17610d05ce"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.3/tune-server-v0.8.3-linux-aarch64.tar.gz"
      sha256 "589714906fe2b89ace03e9de2c78531b6a58c6cc9495d6815316e511ae311f48"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.3/tune-server-v0.8.3-linux-x86_64.tar.gz"
      sha256 "320a6991202c4ef5a056614d004bd0cd10547bdb67721e139ad4474ebbd913f1"
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
      Tune Server v0.8.3 (Rust) installed!

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
