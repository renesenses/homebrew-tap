class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.3/tune-server-v0.9.3-macos-aarch64.tar.gz"
      sha256 "bbd8821178ad2de8a3b7209b1333f7b0fc48157af52744cf8a25bfbbbc57a0c9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.3/tune-server-v0.9.3-macos-x86_64.tar.gz"
      sha256 "aa20646db562ef92b1fb68ccb17dd9493ca75526154d8631f8789899a8a0301a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.3/tune-server-v0.9.3-linux-aarch64.tar.gz"
      sha256 "7dfba56964e21ae06306a961c174c677f8bf78f3ab3404ed394f29c0a9e1b99f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.3/tune-server-v0.9.3-linux-x86_64.tar.gz"
      sha256 "41006fc6978d7f5881d69c21d075ed91504a34655ef9cfa26c4fcfcfea5c5c89"
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
      Tune Server v0.9.3 (Rust) installed!

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
