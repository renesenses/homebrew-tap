class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.66"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.66/tune-server-v0.9.66-macos-aarch64.tar.gz"
      sha256 "2c25ba06c95516c98e694ba92bca96528e9fd92dec240573603ffa634ba2c497"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.66/tune-server-v0.9.66-macos-x86_64.tar.gz"
      sha256 "ed0145a4008541f89e89b47ed6911550fc34f3873c84f779d3ef7121299c1295"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.66/tune-server-v0.9.66-linux-aarch64.tar.gz"
      sha256 "3465ff31fa6b43867924bfd316d98e3f6f47c06ceb6af5b2f7a86a92d52f9043"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.66/tune-server-v0.9.66-linux-x86_64.tar.gz"
      sha256 "16a9e219b42a3bd1340aac31a2394559cc0176080c0d2353af1bd3db3d45d5c4"
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
      Tune Server v0.9.66 (Rust) installed!

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
