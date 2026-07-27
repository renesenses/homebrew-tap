class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.21"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.21/tune-server-v0.9.21-macos-aarch64.tar.gz"
      sha256 "861a21a601dad36d733cebc58dffdada557ea8d35537645b446068a52bc9deea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.21/tune-server-v0.9.21-macos-x86_64.tar.gz"
      sha256 "230c30eba178c5593f756ad2353706d32f526aea9ba38c29900f6665ad74e6a6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.21/tune-server-v0.9.21-linux-aarch64.tar.gz"
      sha256 "9f6a13c724b09f2927f300cfcaeb8adfe235790cc480dd59938508abb39e69e7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.21/tune-server-v0.9.21-linux-x86_64.tar.gz"
      sha256 "e762b7eb93cd4004e5abfadd8e7aa9adcb4472836b49db718c20dfd6da6b7a8d"
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
      Tune Server v0.9.21 (Rust) installed!

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
