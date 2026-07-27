class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.20"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.20/tune-server-v0.9.20-macos-aarch64.tar.gz"
      sha256 "d80c36529f1d0e705158d796803f608c68c8339ae93e254cfff8abad756642ea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.20/tune-server-v0.9.20-macos-x86_64.tar.gz"
      sha256 "801157ec779f12dd4632ed78059f89c30b5cfcc0edd274c6cebfc06473cc205f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.20/tune-server-v0.9.20-linux-aarch64.tar.gz"
      sha256 "f1216936ea85c86ac4e902db00beb0f04b9b6fd469c117ab50f28a312c5e7e30"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.20/tune-server-v0.9.20-linux-x86_64.tar.gz"
      sha256 "9b4831f0041fa38a2d8ba9de1eea8257ca48ae8bf1d0ed61ff17ed32947f7d07"
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
      Tune Server v0.9.20 (Rust) installed!

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
