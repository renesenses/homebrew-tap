class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.35"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.35/tune-server-v0.8.35-macos-aarch64.tar.gz"
      sha256 "28bc9554890d910444e20a3d82fd04ec90ff9f30f8c4b3aee100c9b1ba9f0d8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.35/tune-server-v0.8.35-macos-x86_64.tar.gz"
      sha256 "bc2a03a1b850d1253c699a3363a918bbae3dfb2aeb9d507339abf5407bf9090f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.35/tune-server-v0.8.35-linux-aarch64.tar.gz"
      sha256 "30582f09edbf53c88c75aa39d350a696447ec28a2795209c5ed383f1b91045a1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.35/tune-server-v0.8.35-linux-x86_64.tar.gz"
      sha256 "2f85f8a04696a47268f7fc7e74ace2e61dfde486f361572ac39cbd07353307c8"
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
      Tune Server v0.8.35 (Rust) installed!

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
