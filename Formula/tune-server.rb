class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.11/tune-server-v0.8.11-macos-aarch64.tar.gz"
      sha256 "aac0dd4a9fe8c38e639044ca3430409f36326ff0bcb1baf7c5b135226f8fa1dc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.11/tune-server-v0.8.11-macos-x86_64.tar.gz"
      sha256 "2873e01789f750087397dc3ff3239f09a386bd261d4510efe4e2ad127b75385e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.11/tune-server-v0.8.11-linux-aarch64.tar.gz"
      sha256 "15faa4bad8f34dffb1d2a051fa881eb9722b701ee7281511f347e13097729cdc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.11/tune-server-v0.8.11-linux-x86_64.tar.gz"
      sha256 "09497a63b1280130f4fa70c2578fa377c03e97c12631a94a5232437f1ce95b62"
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
      Tune Server v0.8.11 (Rust) installed!

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
