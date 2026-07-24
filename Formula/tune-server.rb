class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.4/tune-server-v0.9.4-macos-aarch64.tar.gz"
      sha256 "d5dfa03ea2d3cb3b01d762da78a383d281954a2e545f87e3796dfa26c16a24e4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.4/tune-server-v0.9.4-macos-x86_64.tar.gz"
      sha256 "1bca3ec72ad88033878178739829f29b7ef33b11fc31a2d53c814f5be2801639"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.4/tune-server-v0.9.4-linux-aarch64.tar.gz"
      sha256 "81ff3edbaa4f323e42088a393c5464e0b4b631c1893b38957104ca08312db8c2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.4/tune-server-v0.9.4-linux-x86_64.tar.gz"
      sha256 "f4b9f1774e0e269555fa2c6eaeeb2d90478a7d27714f18938e082cd20d7dfd9c"
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
      Tune Server v0.9.4 (Rust) installed!

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
