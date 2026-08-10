class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.67"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.67/tune-server-v0.9.67-macos-aarch64.tar.gz"
      sha256 "c703b192af22b1fe7d14f80997bfa9229a04267339fafa6ec3cbcc184ff6c12b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.67/tune-server-v0.9.67-macos-x86_64.tar.gz"
      sha256 "379c7cb3a755a97382f13f45c78f529f0f375aaf20af1c2a3e1925e355a39a01"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.67/tune-server-v0.9.67-linux-aarch64.tar.gz"
      sha256 "992eb56609d4a022f436f71e9dfbaf9c76b25891c01bdb42f32dc84538de8860"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.67/tune-server-v0.9.67-linux-x86_64.tar.gz"
      sha256 "a2f9b0e6049a9bab37205bee2ee0ba77c2a375453e483aee4429a8ac93e54979"
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
      Tune Server v0.9.67 (Rust) installed!

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
