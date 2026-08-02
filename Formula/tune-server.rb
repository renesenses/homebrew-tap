class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.40"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.40/tune-server-v0.9.40-macos-aarch64.tar.gz"
      sha256 "91c7d7ffe95e0f2fab666e9359829d365d12aaf191bd8f26cc80722152fa9b38"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.40/tune-server-v0.9.40-macos-x86_64.tar.gz"
      sha256 "e64fac47b04a9f1b434023e5d9c1d79783a329d0ba3ee55084a88f97c85b2d16"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.40/tune-server-v0.9.40-linux-aarch64.tar.gz"
      sha256 "4e7419fa8bde583a046a1312ccc1666bc7447efc4ecc5c434d828d40ebf17c88"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.40/tune-server-v0.9.40-linux-x86_64.tar.gz"
      sha256 "d2838184cc3f7ceffa7dd7d66a37c89344e21d5747ee8be0198fb24633d024e1"
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
      Tune Server v0.9.40 (Rust) installed!

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
