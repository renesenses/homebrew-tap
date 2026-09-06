class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.139"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.139/tune-server-v0.9.139-macos-aarch64.tar.gz"
      sha256 "228640ab986fa5ac950bb62e62d4f60f33f57a952257b3e399b5d746115ac868"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.139/tune-server-v0.9.139-macos-x86_64.tar.gz"
      sha256 "56ec23426d889725b36d9f4385d087d16990c2c2e61d45fa1d84330e776c23fe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.139/tune-server-v0.9.139-linux-aarch64.tar.gz"
      sha256 "d2fe02d140461abe146900ff70d9fcc03dac5089a30ed9b1e6e8439e20e076f8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.139/tune-server-v0.9.139-linux-x86_64.tar.gz"
      sha256 "7a05954d8882e9ad636bd711d00b9fe12d0973d961518becebc489ce61078ec4"
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
      Tune Server v0.9.139 (Rust) installed!

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
