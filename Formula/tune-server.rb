class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.42"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.42/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "d73164d3c7c924bddeb72e4035d4065df52afd82f69033b73a5a7df7be248bb6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.42/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "b2948f7bc2adae6c3e44cc0d94f418b6280878315f811da8d863d90c423ddf8f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.42/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "7cca78fc38a7af78d9f4ec384bce5ac6960d5ccb973f450578f5c0b5ec94488a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.42/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "6621cd2c16888bfe6e51326e31d77a5be2d7506124de8f6086ce94c5688f2f4c"
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
      Tune Server v0.8.42 (Rust) installed!

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
