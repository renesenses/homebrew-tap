class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.46"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.46/tune-server-v0.9.46-macos-aarch64.tar.gz"
      sha256 "5749ad8f8e7cc8d92b813697932fdb6166a3766216e795c482d8dcacb248ea27"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.46/tune-server-v0.9.46-macos-x86_64.tar.gz"
      sha256 "ab0cff43662b49dc63bfd459e3540e9eabfffb099b808e23a42301da84830dfa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.46/tune-server-v0.9.46-linux-aarch64.tar.gz"
      sha256 "192474a457bd388d9eb555c5bfa225a68233338dd8d6824b59a429e0a8c94a60"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.46/tune-server-v0.9.46-linux-x86_64.tar.gz"
      sha256 "8639c68f6997af5bfdbdb85212e48eeb7513cd0eb2434bbadce43eb1c3aa3727"
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
      Tune Server v0.9.46 (Rust) installed!

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
