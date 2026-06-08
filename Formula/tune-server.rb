class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.64"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.64/tune-server-v0.8.64-macos-aarch64.tar.gz"
      sha256 "e361b517f46027247043e2233c0c9b53b6cabbbc6f491145c6702b0265193dd1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.64/tune-server-v0.8.64-macos-x86_64.tar.gz"
      sha256 "5ced3cfa5cf63edb8ea994e9cd9cab460e7a81a29a3190f2603c4ac70e2604a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.64/tune-server-v0.8.64-linux-aarch64.tar.gz"
      sha256 "b48c2becc38e530b89b456145ee071a8f2bc8b6d8e876289978f73f83a1df6d6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.64/tune-server-v0.8.64-linux-x86_64.tar.gz"
      sha256 "e26d732f620c479470b7daa818d697bbed6903a9aedcec6a18194d045e8b1952"
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
      Tune Server v0.8.64 (Rust) installed!

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
