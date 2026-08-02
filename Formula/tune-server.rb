class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.39"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.39/tune-server-v0.9.39-macos-aarch64.tar.gz"
      sha256 "1301abb0dc5af9081f8564f85939cfa6284bbbfb01c7e7a79b92698de3fb15bb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.39/tune-server-v0.9.39-macos-x86_64.tar.gz"
      sha256 "223be0745ec964fe26ea955a0aae356aad58cbdc80c5fc5f13605f433068b256"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.39/tune-server-v0.9.39-linux-aarch64.tar.gz"
      sha256 "1766768c8098d799fa78e39977c96c66a98de9956db346e791e1eb5659f9511c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.39/tune-server-v0.9.39-linux-x86_64.tar.gz"
      sha256 "2209a33b354f072f8e42baebdbcd03c164da4d085e140cbc5e620d081b88ea7b"
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
      Tune Server v0.9.39 (Rust) installed!

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
