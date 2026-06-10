class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.70"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.70/tune-server-v0.8.70-macos-aarch64.tar.gz"
      sha256 "53752916b0b5033c449d55eef1529f46d8ce64de23381d2140ba97031a2f2ebf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.70/tune-server-v0.8.70-macos-x86_64.tar.gz"
      sha256 "b02b2834ca87457543808e5677379f185d16eaca2f647015ae632059a71c7fcb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.70/tune-server-v0.8.70-linux-aarch64.tar.gz"
      sha256 "21b2e677b0c3bbf51aac293ed39a397d0b5c8d0625f2c28b15b53691e665a5c5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.70/tune-server-v0.8.70-linux-x86_64.tar.gz"
      sha256 "ff2fa23e8d2b003ad1c9011913f19360b8ce56bff0a80de6bd690bc3d54136c7"
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
      Tune Server v0.8.70 (Rust) installed!

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
