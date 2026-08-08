class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.56"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.56/tune-server-v0.9.56-macos-aarch64.tar.gz"
      sha256 "1fe15bf25e9ac690f56073e9e56de283c82df8cac61207d403c53abdaec46189"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.56/tune-server-v0.9.56-macos-x86_64.tar.gz"
      sha256 "7a8264c04bbce9bf70febbdf30a2aa0dcc087f56c76ccdba2f8a73e8718ffc96"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.56/tune-server-v0.9.56-linux-aarch64.tar.gz"
      sha256 "677a82f77171db8ca492d3a97f04a3febc4da8687710fe022b793b508e258ad2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.56/tune-server-v0.9.56-linux-x86_64.tar.gz"
      sha256 "898905ddb16a01b1761fccfe3e3d1ea9f7312a36d4c66899e07239085be2765c"
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
      Tune Server v0.9.56 (Rust) installed!

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
