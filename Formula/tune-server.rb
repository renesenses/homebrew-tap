class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.75"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.75/tune-server-v0.8.75-macos-aarch64.tar.gz"
      sha256 "c707b3d22421f80b5c14cc2b08f6045af22036c7d1ba38a1a67f471a889630f4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.75/tune-server-v0.8.75-macos-x86_64.tar.gz"
      sha256 "ec11b1980fcbfa7ace5895284e956d9a735b7e9798c7983e70d4878d8eda0232"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.75/tune-server-v0.8.75-linux-aarch64.tar.gz"
      sha256 "2b6282f352e67c36666cd396abcc085044c6370beffa62965fc900cf882698c5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.75/tune-server-v0.8.75-linux-x86_64.tar.gz"
      sha256 "5f42193dccdde8e7ebfc1454c7b66f7cae22b1dffbc1762c8313c897765517a8"
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
      Tune Server v0.8.75 (Rust) installed!

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
