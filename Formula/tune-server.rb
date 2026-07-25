class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-macos-aarch64.tar.gz"
      sha256 "cb05bafc07250e454fafb13140df0de6b9ff3693f5deb12cf910db88152fa5da"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-macos-x86_64.tar.gz"
      sha256 "4b79619df0c9e927193b25d53beaae0d8414eba32f60e0f9526a80ef80e27ba6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-linux-aarch64.tar.gz"
      sha256 "c3467bfcd1b9b8f24d71ff3e796c6fe54ce8048722c97a3f29f5533b4d2973e4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-linux-x86_64.tar.gz"
      sha256 "99365fe265f6535034b6f691ab17d18f138c2e3abe842aaa0bcb8c7ea9ce3cba"
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
      Tune Server v0.9.7 (Rust) installed!

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
