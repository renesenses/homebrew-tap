class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.77"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.77/tune-server-v0.8.77-macos-aarch64.tar.gz"
      sha256 "d4a802985a0b359bd62cd8c208e183a14a8b97bdea3e96433b40741f231b99b1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.77/tune-server-v0.8.77-macos-x86_64.tar.gz"
      sha256 "92bf5d3286a15922563a7c30dee08d53105cd2e10cffa83d903cb19dc57e0a28"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.77/tune-server-v0.8.77-linux-aarch64.tar.gz"
      sha256 "fe2ab185c5df95da5960652940df98af83f7f1ac01e95c5dcf82a9f0366917b8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.77/tune-server-v0.8.77-linux-x86_64.tar.gz"
      sha256 "49e9b98024755a83ece6a206a40cf962a289dcc30f7da7b0fff0e81a1bf003a8"
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
      Tune Server v0.8.77 (Rust) installed!

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
