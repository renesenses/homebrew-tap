class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.60"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.60/tune-server-v0.9.60-macos-aarch64.tar.gz"
      sha256 "22bd9a30db2885876f4c09ed5ffa9030373564a09e0f7ef8d5540bea927a098f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.60/tune-server-v0.9.60-macos-x86_64.tar.gz"
      sha256 "f692839116b14bb37babba8e63284ed09795b52dbbb9c34d0a0375b2b11d5a9b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.60/tune-server-v0.9.60-linux-aarch64.tar.gz"
      sha256 "7b919d3fcb439e5a09ddf7ec54eff1981e4a65b988bd37697806194215594d38"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.60/tune-server-v0.9.60-linux-x86_64.tar.gz"
      sha256 "295b62a81d9c1076a803dd9b0bfb5ea54f604d9b5a4ff925e69978f04ff53a1d"
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
      Tune Server v0.9.60 (Rust) installed!

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
