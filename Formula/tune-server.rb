class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.54"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.54/tune-server-v0.9.54-macos-aarch64.tar.gz"
      sha256 "ddae01b1f26c1782a5dde24f5316df8cfb96933b81a8551f507017b0957d85a1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.54/tune-server-v0.9.54-macos-x86_64.tar.gz"
      sha256 "233ac34f468e628609c2b2c4538a8a813ebaffab7ce13f2df080bb1b04371464"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.54/tune-server-v0.9.54-linux-aarch64.tar.gz"
      sha256 "688251fabfb7f5e37825901f44b5c759ce554ff11ee32f93d285768c5d9a8323"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.54/tune-server-v0.9.54-linux-x86_64.tar.gz"
      sha256 "d49951be7c4876347e4d3a634a16b1bbb065dbfca7bac43da69c387455685c0f"
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
      Tune Server v0.9.54 (Rust) installed!

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
