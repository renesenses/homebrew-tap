class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.65"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.65/tune-server-v0.9.65-macos-aarch64.tar.gz"
      sha256 "a523e03d66cc9f679717a8b80081d59dd7b5b7cbdd44c0397851f973fc456966"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.65/tune-server-v0.9.65-macos-x86_64.tar.gz"
      sha256 "dc91954b9ccf8b841142fbcc5dbad18579f71abdda2d3dc2122111d3ab86124e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.65/tune-server-v0.9.65-linux-aarch64.tar.gz"
      sha256 "6d6e17c4293a295b6da0e81b7bf7b7236156bd88afaa090555580dda7b3959b3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.65/tune-server-v0.9.65-linux-x86_64.tar.gz"
      sha256 "58868c18bcae944bead96baca34688b6060f3aa980ec6075d42c0421fa0b465c"
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
      Tune Server v0.9.65 (Rust) installed!

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
