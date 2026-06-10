class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.74"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.74/tune-server-v0.8.74-macos-aarch64.tar.gz"
      sha256 "27d1693124c217f91dc574185a07ff11571e99518c26c315a9123c03e1ab59c4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.74/tune-server-v0.8.74-macos-x86_64.tar.gz"
      sha256 "8e09dd2439ad2b5fedc08466c74c1354b148c21d55b72d5a10bda9bac1e3b010"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.74/tune-server-v0.8.74-linux-aarch64.tar.gz"
      sha256 "992c92cd73be9ae1e0fa12a8951f58ad56142efada779f11153fbd997232b72b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.74/tune-server-v0.8.74-linux-x86_64.tar.gz"
      sha256 "4eb4c80f683eaa219c5533fbff5351d15d2ea3a1e9d376a04f4edc3e5e7babae"
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
      Tune Server v0.8.74 (Rust) installed!

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
