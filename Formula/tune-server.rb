class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.115"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.115/tune-server-v0.9.115-macos-aarch64.tar.gz"
      sha256 "b31c3c85e2e6b964e0b09a3dd328a707f5a83b988ab948ec0e08b24f0c527aea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.115/tune-server-v0.9.115-macos-x86_64.tar.gz"
      sha256 "8605e1214e9a8213f03c9c322f1d510e8c3df391fba7cc38859bbfe2dfdeb756"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.115/tune-server-v0.9.115-linux-aarch64.tar.gz"
      sha256 "abcd28386adb536723c96b3e4b1c1c494755d42f6423dccbb71c5649be7fb6b8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.115/tune-server-v0.9.115-linux-x86_64.tar.gz"
      sha256 "cb676eb7e5c6464e86234b4f4969e9a831db4060345f4cd515a329486e1cd318"
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
      Tune Server v0.9.115 (Rust) installed!

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
