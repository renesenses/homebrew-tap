class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.91"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.91/tune-server-v0.8.91-macos-aarch64.tar.gz"
      sha256 "aa664b793f290b8993d555060340d5546bf5364d986137e3d7bc2c8ec3ca9bf0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.91/tune-server-v0.8.91-macos-x86_64.tar.gz"
      sha256 "90a705cd3f448d72fb2517dfe0ef61f59e76d584e3f1ff1433b3d6bbda768661"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.91/tune-server-v0.8.91-linux-aarch64.tar.gz"
      sha256 "dbff9d1889a2fe05333160b6f77c4eb3b175bfe71844ac27c25438824e2037a0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.91/tune-server-v0.8.91-linux-x86_64.tar.gz"
      sha256 "ce78493a54bcb5853ef50f22388bd2406ceb45b7d1695526f9649b1106a9356a"
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
      Tune Server v0.8.91 (Rust) installed!

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
