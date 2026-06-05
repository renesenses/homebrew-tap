class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.45"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "dcd6b6e359fbf20e067265b402cc29ca71d74d854f0bd26e818295b97770165a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "0edc79caf22f306bbcc9e707508737e08649db3d383bb5cbee060540e0608670"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "80e56c288f50cabd690366a758ed1f7c06b2dd2f9f1cd8c0d06a53de6a855457"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "bee7d8ce73de84688357b99038398df9a516df9f58d3b7446c6a211f1c26ef2d"
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
      Tune Server v0.8.45 (Rust) installed!

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
