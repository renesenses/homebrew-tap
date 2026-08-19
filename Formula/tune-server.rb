class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.88"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.88/tune-server-v0.9.88-macos-aarch64.tar.gz"
      sha256 "a20a94a1bc35a94056b8c7edb0359895a0786b3fc27deb45273c9fdb63cde4f2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.88/tune-server-v0.9.88-macos-x86_64.tar.gz"
      sha256 "564303f098b604d0ac992ebe3af200fa5bba396155d965e4ed6dadb7301f2ad6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.88/tune-server-v0.9.88-linux-aarch64.tar.gz"
      sha256 "12eb3d809de83e9c2b1602796ea98492c8822c327b385d5af76e9ccef43950dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.88/tune-server-v0.9.88-linux-x86_64.tar.gz"
      sha256 "7caf742563fa36b2e6f463ff186106d61ffdcd519af0de22630a0f3d44733854"
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
      Tune Server v0.9.88 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

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
