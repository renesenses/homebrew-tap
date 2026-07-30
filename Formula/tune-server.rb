class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.30"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.30/tune-server-v0.9.30-macos-aarch64.tar.gz"
      sha256 "34d1d0b2348e20af01042888d77073ccba8fb08b6957df9f1c72e10581465a5a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.30/tune-server-v0.9.30-macos-x86_64.tar.gz"
      sha256 "34af50613aa65a71acb95d91f21873a29bc07ef56750e2502bf0339af6a086bc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.30/tune-server-v0.9.30-linux-aarch64.tar.gz"
      sha256 "8168b3d86e2192483169b74707a8c2f3599614d1ebc329d66b628a2376cda57e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.30/tune-server-v0.9.30-linux-x86_64.tar.gz"
      sha256 "11b5981f44c2662db34e1620e43f626d7af121c89a0365f6dd09bad0f53fed97"
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
      Tune Server v0.9.30 (Rust) installed!

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
