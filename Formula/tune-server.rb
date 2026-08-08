class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.58"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.58/tune-server-v0.9.58-macos-aarch64.tar.gz"
      sha256 "514ba36eefd34eb2cc5044b2e318f1abb18ee2bcf5ea2987b967cb4faf924cad"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.58/tune-server-v0.9.58-macos-x86_64.tar.gz"
      sha256 "f0507321b73089048970959f2ed6ff2bc5bc018e47b8903ef0d4145bf07fce4c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.58/tune-server-v0.9.58-linux-aarch64.tar.gz"
      sha256 "eece05b888cd4c7d27a8e8dee39691d0029cb7d50802f490e275141e628df57c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.58/tune-server-v0.9.58-linux-x86_64.tar.gz"
      sha256 "54ef16d0784bdb6cb5543a7aa97feff7883255e16fc86e327c3b19106ca99002"
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
      Tune Server v0.9.58 (Rust) installed!

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
