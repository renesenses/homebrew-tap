class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.41"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.41/tune-server-v0.8.41-macos-aarch64.tar.gz"
      sha256 "2bf91a8824b0bc2dd9145ab94e294dec0da90975d859a84b2979ffc1c272bb19"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.41/tune-server-v0.8.41-macos-aarch64.tar.gz"
      sha256 "2bf91a8824b0bc2dd9145ab94e294dec0da90975d859a84b2979ffc1c272bb19"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.41/tune-server-v0.8.41-linux-aarch64.tar.gz"
      sha256 "9ef2daf5296a8f779a7492ba66e8a798bb6fed77731a35403df348259740dbf6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.41/tune-server-v0.8.41-linux-x86_64.tar.gz"
      sha256 "1ac1ee573ef4a90c7f651731508a3974252b07048046241a052201cd588a70d0"
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
      Tune Server v0.8.41 (Rust) installed!

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
