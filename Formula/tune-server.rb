class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.15"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.15/tune-server-v0.9.15-macos-aarch64.tar.gz"
      sha256 "65106e0a1a9dfe1dc17ecafbbcc1734c9857d7153be7013276361fc6d7a4f674"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.15/tune-server-v0.9.15-macos-x86_64.tar.gz"
      sha256 "28eb84243e32e97aa52b403a171ab05fe5630246504294cfafeb1dfd6be2a6f2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.15/tune-server-v0.9.15-linux-aarch64.tar.gz"
      sha256 "510074f6b27a3302e8559e73e6b0b2704df4cd5bedb81023618f95e3477db1e1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.15/tune-server-v0.9.15-linux-x86_64.tar.gz"
      sha256 "dd7b6e69ca13a193e69b236194437f9ae0344fc2a9e9e25a47f964958e8b7627"
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
      Tune Server v0.9.15 (Rust) installed!

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
