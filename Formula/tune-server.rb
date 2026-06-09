class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.69"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.69/tune-server-v0.8.69-macos-aarch64.tar.gz"
      sha256 "2dfd3bbb18ec76d112b454fd7a1c629cd3b472a57a7458a2c49a735116d3ef8b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.69/tune-server-v0.8.69-macos-x86_64.tar.gz"
      sha256 "bf0da59ed3b19d2b00b3f96e5b7d1b2a4300d73c7803488e81dc7a14954b782a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.69/tune-server-v0.8.69-linux-aarch64.tar.gz"
      sha256 "eb0ee764ae5e7c1ce3e00f9b7cc86210c426621030a83f7095f77b6b7b909d42"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.69/tune-server-v0.8.69-linux-x86_64.tar.gz"
      sha256 "9fba21db7d45f474e8c28523784e25e57871ed3b01daf1acd1453008b2bb2b37"
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
      Tune Server v0.8.69 (Rust) installed!

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
