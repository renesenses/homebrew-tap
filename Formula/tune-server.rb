class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.8/tune-server-v0.9.8-macos-aarch64.tar.gz"
      sha256 "d1d03e2b84b57287205ae031e2d84aa8bff2ed0a48aedb469fcfd9d66ee30d5f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.8/tune-server-v0.9.8-macos-x86_64.tar.gz"
      sha256 "b1b74f2bf642c64099f634b99b629f8c461307ef05be78918b21b72c2e14ad97"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.8/tune-server-v0.9.8-linux-aarch64.tar.gz"
      sha256 "86987a6f6819c33f5367290a80d1e440a6472431e3a8672229dedd43daf9eed7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.8/tune-server-v0.9.8-linux-x86_64.tar.gz"
      sha256 "852a722d4af4cae8fb68537fd75658ab3a0f2372229cfd8f30b1af2001e1f15a"
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
      Tune Server v0.9.8 (Rust) installed!

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
