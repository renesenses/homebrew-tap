class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.6/tune-server-v0.8.6-macos-aarch64.tar.gz"
      sha256 "471d4230c95f09c046e736f93d67c30e00bd1ed0626a20f8b20fdf03a525d565"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.6/tune-server-v0.8.6-macos-x86_64.tar.gz"
      sha256 "bb3ac1fbec0b3d5c42ccd60af55270a73472d9c5b6b2ffb9613f563b06ab95f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.6/tune-server-v0.8.6-linux-aarch64.tar.gz"
      sha256 "cd6cf04ec015ce4e1c68b772c245abcacd3243fd9c5f7d0e44d060c76d60238e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.6/tune-server-v0.8.6-linux-x86_64.tar.gz"
      sha256 "315d2b98a80b39d09d1ac13c2044cd0e550a142d3126344df3a12ff9dd5951e4"
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
      Tune Server v0.8.6 (Rust) installed!

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
