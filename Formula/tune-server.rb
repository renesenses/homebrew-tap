class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.79"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.79/tune-server-v0.8.79-macos-aarch64.tar.gz"
      sha256 "8a9b17ee2d90ae0270a318714bf8e8e00560692cc87df60fef3f2469222cb9b9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.79/tune-server-v0.8.79-macos-x86_64.tar.gz"
      sha256 "e31f8645c2d84b5cc4a6a1a40f65a89a0f5f34a3ad6cbc6319c2cdd5502933f6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.79/tune-server-v0.8.79-linux-aarch64.tar.gz"
      sha256 "6bc6b0acb8d95ba9701456aea9daa7eae13abf5df4f4608601ddfabc6763f8b6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.79/tune-server-v0.8.79-linux-x86_64.tar.gz"
      sha256 "baceab0d4ad45258495e675d6e7f6f477d0f35758d8d71488b44dd8d0fefc0b6"
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
      Tune Server v0.8.79 (Rust) installed!

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
