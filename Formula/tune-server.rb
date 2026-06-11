class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.80"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.80/tune-server-v0.8.80-macos-aarch64.tar.gz"
      sha256 "950e722101ded1972a270cc0e30e40fe89475800b2c3390517f8459dd4248165"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.80/tune-server-v0.8.80-macos-x86_64.tar.gz"
      sha256 "eb267934857f6af0fd51b62af5086886a89b93e637ba25857f2a8de2f9a9cf7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.80/tune-server-v0.8.80-linux-aarch64.tar.gz"
      sha256 "ee504a27086575170779c01274e81cd222b083074e914e33317941653a858667"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.80/tune-server-v0.8.80-linux-x86_64.tar.gz"
      sha256 "a6f62e7bd22b2d2d5499b2d4b531a9620ec55e3adefdd7ade261cdccdf3ba0ce"
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
      Tune Server v0.8.80 (Rust) installed!

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
