class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.48"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.48/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "90bc38e16428bdad9cc35a3c40b023c83cb9680d143a9d0121304e784bca0171"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.48/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "b62e1def210aa894209e52c8c672f9ddc7f7942fb76ab8fa088345dc2c54cb14"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.48/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "260b9b1dc18ce2e3a99c0c55ffbb086c1765c31f7d88df58810ee063d6d8e36e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.48/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "5a7cc8a516969254241268d5145c4c30dea681a9d699f7d27a87556eaae903a5"
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
      Tune Server v0.8.48 (Rust) installed!

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
