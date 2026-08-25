class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.106"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.106/tune-server-v0.9.106-macos-aarch64.tar.gz"
      sha256 "ba6679cdb2bed26d76caf20add12bcede74111d26bee9875cb87ba4f17aa937d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.106/tune-server-v0.9.106-macos-x86_64.tar.gz"
      sha256 "7ef6f209e4beaeffbfcffa28a6c64ed8efad355a90f36a344b3b79c1c2b4c4a7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.106/tune-server-v0.9.106-linux-aarch64.tar.gz"
      sha256 "5bea82d23e050a4fa6ccd636c6b1328900b8104c819e05bd280dd1d4b48c1721"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.106/tune-server-v0.9.106-linux-x86_64.tar.gz"
      sha256 "92fce85f2cbcc4dc928e12bd1e866cacb1ef19b3979d7afd4626d9eea353336b"
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
      Tune Server v0.9.106 (Rust) installed!

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
