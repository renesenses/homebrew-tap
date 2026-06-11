class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.82"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.82/tune-server-v0.8.82-macos-aarch64.tar.gz"
      sha256 "5a3d4cadc270b86eb836fcf82caacc1579b4c729f90424ab3b3b04e973acfbc5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.82/tune-server-v0.8.82-macos-x86_64.tar.gz"
      sha256 "fdf7e20d1494543a563639b729efbc9ef864ebbb50e01616f993265ac69beb66"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.82/tune-server-v0.8.82-linux-aarch64.tar.gz"
      sha256 "b6dc775b10484a439701bb9f2c816d14d83f3590f47ae6472a34a3eb3f355a00"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.82/tune-server-v0.8.82-linux-x86_64.tar.gz"
      sha256 "d73ea8b2c13fb925b2171d86ce3b58cee7132adeb06138c74ab90973e35a0307"
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
      Tune Server v0.8.82 (Rust) installed!

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
