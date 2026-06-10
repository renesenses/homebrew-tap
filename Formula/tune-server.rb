class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.72"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.72/tune-server-v0.8.72-macos-aarch64.tar.gz"
      sha256 "67bffd1bed790f876630e57238e927d5de37d51bd6142e7f70ae309a20a0006f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.72/tune-server-v0.8.72-macos-x86_64.tar.gz"
      sha256 "035f8c814d4413d018119ebfed8f1b0f18009e4fc3035d863edf2ccaa7503ecc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.72/tune-server-v0.8.72-linux-aarch64.tar.gz"
      sha256 "d3ac5bf6aec780cc2def2028fa9bd777e2dc0b6f769a2f93b527ec211e12ffa9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.72/tune-server-v0.8.72-linux-x86_64.tar.gz"
      sha256 "bdb75289f8872ed5f799bb4b7f733508ec0cfa4bf14aae2b5e32e8d1adcadffa"
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
      Tune Server v0.8.72 (Rust) installed!

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
