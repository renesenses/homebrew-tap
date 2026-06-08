class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.62"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.62/tune-server-v0.8.62-macos-aarch64.tar.gz"
      sha256 "8f3fcbdc0b5bfca8844ad4918de118ff03603e6d1ae8fcc0ee36ccce2938defd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.62/tune-server-v0.8.62-macos-x86_64.tar.gz"
      sha256 "4c737bec5260eac8ef3bc5779b7f83ba597279d106d4b4b098301b843e8dac18"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.62/tune-server-v0.8.62-linux-aarch64.tar.gz"
      sha256 "2ffd0165f163d1e4bc71118bfd36a8afb393186860208297e1d377d8d97ef09b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.62/tune-server-v0.8.62-linux-x86_64.tar.gz"
      sha256 "cd904d4f1f930397a5ae2e8b3c38decc65d2fc9f7055809d6edaa6f9aee05fc5"
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
      Tune Server v0.8.62 (Rust) installed!

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
