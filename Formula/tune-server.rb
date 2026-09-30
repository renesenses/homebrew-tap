class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.169"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.169/tune-server-v0.9.169-macos-aarch64.tar.gz"
      sha256 "d4afe670965db8116a2c342a1c38c87f515b1e28dc333a54b15af8747c85736f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.169/tune-server-v0.9.169-macos-x86_64.tar.gz"
      sha256 "2e607d3ce3f1abe993159ca8177473ce687d77dc1728bb96cb823a92d767da59"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.169/tune-server-v0.9.169-linux-aarch64.tar.gz"
      sha256 "710918b8dcf6c01d25f5da043ab6f28433da0c42abd899ca771cf62a87e3563b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.169/tune-server-v0.9.169-linux-x86_64.tar.gz"
      sha256 "12f278a6f4f69fe5294315f123a374b4bebf23ab3d1af6dfa7c13d3660b1500d"
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
      Tune Server v0.9.169 (Rust) installed!

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
