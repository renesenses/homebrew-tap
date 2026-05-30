class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.7/tune-server-v0.8.7-macos-aarch64.tar.gz"
      sha256 "21e3d00b804e534eae6d70d3b836fd6c6ea45a1b1eaedb704c001b1b1b1c97e2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.7/tune-server-v0.8.7-macos-x86_64.tar.gz"
      sha256 "a6943d7d637a70980fd7926799a550562ea530f3cc0fadd3c1382baa6d43b0b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.7/tune-server-v0.8.7-linux-aarch64.tar.gz"
      sha256 "76b2fbfed4d454938faffeeaaa73d1ee3b57b3306932b9e6db8586b882d5eac9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.7/tune-server-v0.8.7-linux-x86_64.tar.gz"
      sha256 "60582ae49977283b41b8b81e275bf8bcf8c9bc42f1393e28b564ce680012943e"
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
      Tune Server v0.8.7 (Rust) installed!

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
