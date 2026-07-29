class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.28"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.28/tune-server-v0.9.28-macos-aarch64.tar.gz"
      sha256 "0ea3faa602eda3b2ea77e29d4269ecae90fc31c6fea236f71245b5b21802c814"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.28/tune-server-v0.9.28-macos-x86_64.tar.gz"
      sha256 "4938f30424e0d4eb23be295d926cd96f0efd93b9adba1aef513996c189d74811"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.28/tune-server-v0.9.28-linux-aarch64.tar.gz"
      sha256 "37b04e9c4e9a6f48afb63a4f885790a0832ad68c5ebd744fe1e4b8e9d4e4ff1c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.28/tune-server-v0.9.28-linux-x86_64.tar.gz"
      sha256 "9012c9f0d723a7570a3b2d6080a51a994502e81281b2345812c09b8fe428371f"
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
      Tune Server v0.9.28 (Rust) installed!

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
