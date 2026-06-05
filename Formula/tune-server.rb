class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.47"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "5fe172415e961b5b434e476f94fef03c8206fcf30a098726f41527cef9227cc8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "e52ca76c1a5bd6ea99ff18c3279d504c86d2b4b761d86aeecc895db0059a9d60"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "4e904038ae4764ba12a691fe195e9edde0ef12fc876c167c4165f11a9c907e89"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "afb87c263fb35fc61cd8e3b017284b08251d764a246d981997a9b63a973618aa"
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
      Tune Server v0.8.47 (Rust) installed!

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
