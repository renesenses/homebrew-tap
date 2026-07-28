class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.26"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.26/tune-server-v0.9.26-macos-aarch64.tar.gz"
      sha256 "666188ebd7f8f93750f22af6ce394ad564586fbe5f2d867a31c7d64035884556"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.26/tune-server-v0.9.26-macos-x86_64.tar.gz"
      sha256 "4a3812bd526e0577f689f32205eae4fe7d35cc7f95b614522369d2b7bae3d0fa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.26/tune-server-v0.9.26-linux-aarch64.tar.gz"
      sha256 "5e1fb8dd4173f793baedb166fd996863d1d132e3cc641808ca4f43d52a074c7c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.26/tune-server-v0.9.26-linux-x86_64.tar.gz"
      sha256 "33d91fbbc2506b31e6dce99097c33f0a8243cae4089472970d92a805dc664d62"
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
      Tune Server v0.9.26 (Rust) installed!

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
