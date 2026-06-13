class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.98"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.98/tune-server-v0.8.98-macos-aarch64.tar.gz"
      sha256 "8369288a0df7606b20819ea996ee31b5b7e762ac5dde182f4f35b7483700fe54"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.98/tune-server-v0.8.98-macos-x86_64.tar.gz"
      sha256 "64c6424d8cfe9cc4932716f308d9204a1e60d133d4574a2140244ab7cca2e555"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.98/tune-server-v0.8.98-linux-aarch64.tar.gz"
      sha256 "90905badf12447f8378c780702725368ea28dce804111c349544b6605fef2eb6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.98/tune-server-v0.8.98-linux-x86_64.tar.gz"
      sha256 "13c63b17a089142908e649af0bc27440a233b06536f4b367af2ed353408a151d"
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
      Tune Server v0.8.98 (Rust) installed!

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
