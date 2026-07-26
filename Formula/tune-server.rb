class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.13"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.13/tune-server-v0.9.13-macos-aarch64.tar.gz"
      sha256 "f28ae602c002772ccdc054b4ae49c12f47d140e48bd4b65cf1209b43a7600911"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.13/tune-server-v0.9.13-macos-x86_64.tar.gz"
      sha256 "66afa05123f4d8c57eb2e9f6aece886d20105f4d3434aae715e95feabd65cdd1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.13/tune-server-v0.9.13-linux-aarch64.tar.gz"
      sha256 "4f0b80c73cced73abafa8a5ec40c8f4d80569feeca1586954977f8c3df7c28a2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.13/tune-server-v0.9.13-linux-x86_64.tar.gz"
      sha256 "8c5ba36816d16ce5cbd7e6f07f48b06ddcfedbfcda70eb4e069bb3cdb4a11bb0"
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
      Tune Server v0.9.13 (Rust) installed!

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
