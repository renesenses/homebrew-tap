class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.9/tune-server-v0.8.9-macos-aarch64.tar.gz"
      sha256 "12cb127838fbae2f80778033219208e8ca4b9379cbf54222141880ea6f63f405"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.9/tune-server-v0.8.9-macos-x86_64.tar.gz"
      sha256 "e5a49d738014ff95fc5010010a367093e24c7f4cfc7309d70d3f30806d3d83b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.9/tune-server-v0.8.9-linux-aarch64.tar.gz"
      sha256 "be1e6f5c03d6eb67be992979cc1431bb0e52d5b8926d3c2b68b35b0854b22693"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.9/tune-server-v0.8.9-linux-x86_64.tar.gz"
      sha256 "5202db6c764c9281b73b4b13505df964fa8e19f2962a8bd7060c6e42841c1920"
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
      Tune Server v0.8.9 (Rust) installed!

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
