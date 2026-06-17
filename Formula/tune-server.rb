class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.126"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.126/tune-server-v0.8.126-macos-aarch64.tar.gz"
      sha256 "8a2a9caae6767b7c48027db28749add09e723d6ffec2ad41e773b43dcea95697"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.126/tune-server-v0.8.126-macos-x86_64.tar.gz"
      sha256 "96a47b49d106e035d4f38dd88b96b56e37bf1132de8de9ce408b0d66c86650f0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.126/tune-server-v0.8.126-linux-aarch64.tar.gz"
      sha256 "aa1dcdd0821f431a977b000f8c7d0ff49879268fe65ccc202f46c27e597df354"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.126/tune-server-v0.8.126-linux-x86_64.tar.gz"
      sha256 "da44da5bc32d61012fed56be7134c63252af1527d3ec43282ed6f10a89cbf0ba"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
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
      Tune Server v0.8.126 (Rust) installed!

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
