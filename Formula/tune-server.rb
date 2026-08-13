class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.71"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.71/tune-server-v0.9.71-macos-aarch64.tar.gz"
      sha256 "9203f49e47756dfd5a8ccd5bbab3cad5904a7949f64c2e0d70feacb0a8a7ddd3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.71/tune-server-v0.9.71-macos-x86_64.tar.gz"
      sha256 "d08b3863e33327a9f518e0c10a8fd145ff956564fad7cbf802e454a9c48776f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.71/tune-server-v0.9.71-linux-aarch64.tar.gz"
      sha256 "96b5e7333055074309f39db521fb61dbc0843a6250d3413fdfe785c6302394d5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.71/tune-server-v0.9.71-linux-x86_64.tar.gz"
      sha256 "cd2cd8ce64c4d6eb235880caf894c75c7cb135dbf225f40ab12dc9195b7bb2b7"
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
      Tune Server v0.9.71 (Rust) installed!

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
