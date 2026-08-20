class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.92"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.92/tune-server-v0.9.92-macos-aarch64.tar.gz"
      sha256 "98fc8a2d5719c53a299b896a3a8924a9088b7ce25984f1482fbfd1b479116080"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.92/tune-server-v0.9.92-macos-x86_64.tar.gz"
      sha256 "89251f30f08dd96128efa23d7a908c3cf8a8398a4179e7677044ad597aacd784"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.92/tune-server-v0.9.92-linux-aarch64.tar.gz"
      sha256 "cb63f603f059c2904ad84504b69b7e731177c7267ae7f2da1e77002f60f4d4f0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.92/tune-server-v0.9.92-linux-x86_64.tar.gz"
      sha256 "3c5f799d07d9a4137623f36aa75f8af98f6551aae5579f81b8ae7999de6ef21d"
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
      Tune Server v0.9.92 (Rust) installed!

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
