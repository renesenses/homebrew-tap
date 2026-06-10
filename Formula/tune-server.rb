class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.78"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.78/tune-server-v0.8.78-macos-aarch64.tar.gz"
      sha256 "59f4d5707ab55a8be39bbc8959b962eb7df47e899375a1e04c302480aa13a169"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.78/tune-server-v0.8.78-macos-x86_64.tar.gz"
      sha256 "4db1477be1ec2c9c772a6c07bf3edecb0f87c86304d52ef43af0008fe67faabb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.78/tune-server-v0.8.78-linux-aarch64.tar.gz"
      sha256 "be35e2977d140901de6283909a16501eaea2f29efb2ea4b8361bc5e2b37c7a7e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.78/tune-server-v0.8.78-linux-x86_64.tar.gz"
      sha256 "612897d3ac154ed87fdea849407ec18bfda31694e901f2b746d62ac36de4b9d9"
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
      Tune Server v0.8.78 (Rust) installed!

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
