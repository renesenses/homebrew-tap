class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.6/tune-server-v0.9.6-macos-aarch64.tar.gz"
      sha256 "d95218f2a8ea7a8c6ac8c66723b271860dbd493f2d8e52e6c601ff3b6d22ff49"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.6/tune-server-v0.9.6-macos-x86_64.tar.gz"
      sha256 "a08ee0dc9514cdcdf175aff0a26d58250bb8d64cb08ed6816340df8caf315a12"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.6/tune-server-v0.9.6-linux-aarch64.tar.gz"
      sha256 "83f029dacf66627a9089768487f03476435e037a80d7e27c6cf221d6bb8f7894"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.6/tune-server-v0.9.6-linux-x86_64.tar.gz"
      sha256 "c4683e41a2ce4b110e5f1606421599050ae7b1146a6c6601b4937c127bd7a685"
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
      Tune Server v0.9.6 (Rust) installed!

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
