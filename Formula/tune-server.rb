class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.12/tune-server-v0.9.12-macos-aarch64.tar.gz"
      sha256 "0073069189e30252ea0da5d66b05674d7303aee7a2fe499d839e2fc9de9c3660"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.12/tune-server-v0.9.12-macos-x86_64.tar.gz"
      sha256 "7c19f1dece74c86d3bb8d45d3c1540873cd35aef045da28fbe3e7f4f122d6568"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.12/tune-server-v0.9.12-linux-aarch64.tar.gz"
      sha256 "d78c67371f2602b2aad42382d3cd95d9e35a3dedccb72af880c512afccfac8d1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.12/tune-server-v0.9.12-linux-x86_64.tar.gz"
      sha256 "ad1b529696a5a20a64bf51b103bfd5a6dd3d3cde4da2fbb6a74063995bdd2379"
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
      Tune Server v0.9.12 (Rust) installed!

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
