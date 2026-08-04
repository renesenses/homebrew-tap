class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.49"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.49/tune-server-v0.9.49-macos-aarch64.tar.gz"
      sha256 "f6d59d7d4350d5896fcd7598c05007aed0ba5bbda1c89e05e440670e74ef590d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.49/tune-server-v0.9.49-macos-x86_64.tar.gz"
      sha256 "3f16b66f26a31069a79d14e62f30d0d3d50dc752961b4d1a00aa0896c759eb96"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.49/tune-server-v0.9.49-linux-aarch64.tar.gz"
      sha256 "72400a269c0a433c5ec8a996fa82ba68a42feab1890c9b4361c72313b57e6fcf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.49/tune-server-v0.9.49-linux-x86_64.tar.gz"
      sha256 "2ac0b9c198fb0108a5dc3d6e96e8f3df8ecf7613145e266b7b2f175d17a9e280"
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
      Tune Server v0.9.49 (Rust) installed!

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
