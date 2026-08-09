class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.59"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.59/tune-server-v0.9.59-macos-aarch64.tar.gz"
      sha256 "fd5934e8255e8a28c1ed89d1598c9f1a6cbc8c4e8a15a89143f52acc0fa0d7a7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.59/tune-server-v0.9.59-macos-x86_64.tar.gz"
      sha256 "f38eac687ead354666d11c1c7ee62a4c81d1b546fb19281afd0d64f30f54379b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.59/tune-server-v0.9.59-linux-aarch64.tar.gz"
      sha256 "3bffb12c8c3c4e39fc8cdf5474b0889a7cd8cbd03940a4f3e4286ff27215817a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.59/tune-server-v0.9.59-linux-x86_64.tar.gz"
      sha256 "db7d62d19e7a1272c7a9eb93d5ebc420d1680ba5a96c7acf7bc9db721798ab60"
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
      Tune Server v0.9.59 (Rust) installed!

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
