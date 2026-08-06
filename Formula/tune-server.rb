class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.51"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.51/tune-server-v0.9.51-macos-aarch64.tar.gz"
      sha256 "645ee8ed2f064735540d443a6ea0f9cc2c10df7fd794037fd1576215cde9d9bb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.51/tune-server-v0.9.51-macos-x86_64.tar.gz"
      sha256 "3deddafd541bab67e05387ad27e81db21998af5551ce441d130adfa7774b3eac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.51/tune-server-v0.9.51-linux-aarch64.tar.gz"
      sha256 "1a5e073a0a91142b404a2ab35bae9911a04a48080a0b58e94687535dbd80d6dc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.51/tune-server-v0.9.51-linux-x86_64.tar.gz"
      sha256 "5fa2c6882ae0c681ada4cd2da7e9f8f33873b9db128465b41b20e28aa3473ae9"
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
      Tune Server v0.9.51 (Rust) installed!

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
