class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.61"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.61/tune-server-v0.9.61-macos-aarch64.tar.gz"
      sha256 "f2c6bd7ef0262f22316e24f5d24a95d555bf85e5d5c4d3c6115854b91ec900e6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.61/tune-server-v0.9.61-macos-x86_64.tar.gz"
      sha256 "259cbe6d40915810725ac9b09ca64c07a683c15fcfc55fa5558c6cf7f83737f2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.61/tune-server-v0.9.61-linux-aarch64.tar.gz"
      sha256 "40dd941447d2c24390872971aaec83c1425e8f358d6e8443a4c0186cb9f95614"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.61/tune-server-v0.9.61-linux-x86_64.tar.gz"
      sha256 "dc24e15c6d25d9847f5dfef4b956e7ef53d844ab923a0535a27aea4512631a1b"
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
      Tune Server v0.9.61 (Rust) installed!

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
