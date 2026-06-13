class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.95"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.95/tune-server-v0.8.95-macos-aarch64.tar.gz"
      sha256 "1909c754e129ec22d2f82a9610abc71bcb546b9dfc59992e351c617de7b809dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.95/tune-server-v0.8.95-macos-x86_64.tar.gz"
      sha256 "395b4420271f13e5ade8f65a9a443cb204c9d8ab4e17037d94dcd9e4383969ee"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.95/tune-server-v0.8.95-linux-aarch64.tar.gz"
      sha256 "2e2c8acd194e468b4f9df4497b7639b3f5a672360ccd0e9aadb60cc4313cf9af"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.95/tune-server-v0.8.95-linux-x86_64.tar.gz"
      sha256 "ae3661896d8c0336a63af401b1bb737a8faaa0bec3554138c1751a4a89e29b98"
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
      Tune Server v0.8.95 (Rust) installed!

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
