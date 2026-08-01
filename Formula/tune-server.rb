class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.35"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.35/tune-server-v0.9.35-macos-aarch64.tar.gz"
      sha256 "16097b61b9076a00c5b6d82f23c98b4ff774cffec55fac337d802c21d6922da2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.35/tune-server-v0.9.35-macos-x86_64.tar.gz"
      sha256 "615668df67ce7f00f2d7dcd2576bc678972c5240e77be19b5d71fe34443577ca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.35/tune-server-v0.9.35-linux-aarch64.tar.gz"
      sha256 "98e30befb553cd926ab12f3893aa9e2a582edef5f8e4a6826cc69c25e5ce912a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.35/tune-server-v0.9.35-linux-x86_64.tar.gz"
      sha256 "15222373afaf182dd590deed75efccb5ba81a3558c827017a819dc874b530295"
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
      Tune Server v0.9.35 (Rust) installed!

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
