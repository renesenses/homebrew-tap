class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.44"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.44/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "3d6a3694f82def17da5574567b2897be57e2b23ddcb30a4268020ae7ee092749"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.44/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "4bbb940ab7dece3c57cc7c3a4bb12c13453cbb6bc1624c679a27bf1f4c0b4a2a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.44/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "869b75c277044984e038eb75ba4242bfd498326c9da7d1c789e63151e6d1990e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.44/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "050483a9e4bd2a1aadff0a87218ede0ab64adeff58dfa849ff59f0b1722dfd7c"
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
      Tune Server v0.8.44 (Rust) installed!

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
