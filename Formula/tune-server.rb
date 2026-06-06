class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.51"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.51/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "3c226d2caa0fb37b764a06bdec520bc2ebbf235f9a32d3097df19db06df681fe"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.51/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "5e3ede19baaea7fa446a2cc24112c747a449d063cad9a0f689d5e009ae564da3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.51/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "b1d6f2325ad8a56bd107669b45fa87e72dc24dc448fefd4dc4c0fe08e88c1b87"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.51/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "9c141888b4be4e66ebce26963aa6dfefd6fd0b1156e45d323b22e9615d8a6e55"
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
      Tune Server v0.8.51 (Rust) installed!

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
