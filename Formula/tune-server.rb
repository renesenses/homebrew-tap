class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.76"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.76/tune-server-v0.9.76-macos-aarch64.tar.gz"
      sha256 "fc67fc25544d0a60d75cd191d3a3b2e799f2d24d3aec7680281896ac235507e0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.76/tune-server-v0.9.76-macos-x86_64.tar.gz"
      sha256 "b2a11165aa2d744eb93e82bfe607d488d5f28e7ef03ac50f0b619fe39080b85d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.76/tune-server-v0.9.76-linux-aarch64.tar.gz"
      sha256 "f045a3fab2bd5b8d178a96d12f5418212f3adc6ea2e6fbd7b197c467ceb4cbe2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.76/tune-server-v0.9.76-linux-x86_64.tar.gz"
      sha256 "e5c4d7891bbda2f61adefd605f3b46571c0d2ed17828ff1d8292474ef88cd164"
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
      Tune Server v0.9.76 (Rust) installed!

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
