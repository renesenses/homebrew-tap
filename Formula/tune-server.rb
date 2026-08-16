class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.81"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.81/tune-server-v0.9.81-macos-aarch64.tar.gz"
      sha256 "2c9189a62792b0c9ea4c38ff0ac3fb5136bbf1adfba2ecd2e7d165bc3caac801"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.81/tune-server-v0.9.81-macos-x86_64.tar.gz"
      sha256 "809740e63d476b774d0a1eda60fa31c07ee99998f9f7e94763ed9b6bce3e25f8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.81/tune-server-v0.9.81-linux-aarch64.tar.gz"
      sha256 "e4e9bbeb3ec4cddef10a3dc788239d458b6cd7ab2b265e3bea48b5a5423817b3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.81/tune-server-v0.9.81-linux-x86_64.tar.gz"
      sha256 "81d8d464d3d9c1396f4e70b72ecb99540aa50e6735cab3c95c814b76be1123c5"
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
      Tune Server v0.9.81 (Rust) installed!

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
