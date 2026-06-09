class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.68"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.68/tune-server-v0.8.68-macos-aarch64.tar.gz"
      sha256 "47acd728abdb8f2ea578b5a55aa7415913098e31db9e01e8d3a3d60e4562ea3c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.68/tune-server-v0.8.68-macos-x86_64.tar.gz"
      sha256 "eb57f8e1d860b760659414ebcf7b5295f1591ccfa791354494618e1b0b80fc54"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.68/tune-server-v0.8.68-linux-aarch64.tar.gz"
      sha256 "551338e6b05a44072b01ec26be37a941d1aaf379ae5797cfafa93d8186a725e5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.68/tune-server-v0.8.68-linux-x86_64.tar.gz"
      sha256 "18c72038c57c61db3aa92790185fdac8412026187ec52a88a0487ee0de76ce1b"
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
      Tune Server v0.8.68 (Rust) installed!

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
