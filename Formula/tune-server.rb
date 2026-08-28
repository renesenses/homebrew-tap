class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.121"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.121/tune-server-v0.9.121-macos-aarch64.tar.gz"
      sha256 "1a1cd241c8a236e695ce01b562d84ff6ec82df2ae739bb9e297d0b4960efb4c2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.121/tune-server-v0.9.121-macos-x86_64.tar.gz"
      sha256 "7d4ca723710edd66fa030d1fd8fe4ee085515bd65cb8d490ead9f40f9a774c55"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.121/tune-server-v0.9.121-linux-aarch64.tar.gz"
      sha256 "b2f5b8216e0b7caf90e01d2e80b11011a259e828fa987a346b8ec71b5bdfa07b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.121/tune-server-v0.9.121-linux-x86_64.tar.gz"
      sha256 "acd1d338b2df47c5052063714267b80eeaa8ea71aa111edd025c73e2d56207a1"
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
      Tune Server v0.9.121 (Rust) installed!

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
