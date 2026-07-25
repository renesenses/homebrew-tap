class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-macos-aarch64.tar.gz"
      sha256 "9806340200c882a4b2a83ad753fc1945076d016906c46b3e98baee6076dc6311"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-macos-x86_64.tar.gz"
      sha256 "8c0d4006daa321e5f86ea143a4a4455cddd5871108abf713fd44ae2f38d435d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-linux-aarch64.tar.gz"
      sha256 "7ddab831949dd4f7de47295000f7ef4c54568e935f4b25215387b76f02feb7cb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.7/tune-server-v0.9.7-linux-x86_64.tar.gz"
      sha256 "b1bb322afea444d522bc2fc50003d64197ab1098610d6139fd8801f7fc5ed468"
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
      Tune Server v0.9.7 (Rust) installed!

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
