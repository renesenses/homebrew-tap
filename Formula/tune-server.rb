class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.27"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.27/tune-server-v0.9.27-macos-aarch64.tar.gz"
      sha256 "42c6ceb62c3c17c322dfbfc4c510354282af553d392a222c4e968a0c60fb2d7d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.27/tune-server-v0.9.27-macos-x86_64.tar.gz"
      sha256 "ecb1465db8267e365aca9569a256cd90fc60ead1191891c9f61d8edffde3ace2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.27/tune-server-v0.9.27-linux-aarch64.tar.gz"
      sha256 "091aacc539479e428eec94af68f672f975bc05786401ff46ec3ca13405f93fd5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.27/tune-server-v0.9.27-linux-x86_64.tar.gz"
      sha256 "58169720e421c02646fc044ec59dcf14b5a9ddfb21f9c873ea4f7335f89feaa2"
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
      Tune Server v0.9.27 (Rust) installed!

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
