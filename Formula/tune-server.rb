class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "1.0.0-rc3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc3/tune-server-v1.0.0-rc3-macos-aarch64.tar.gz"
      sha256 "d1b8f12ccd1c7d18e3002625771198a4bd2a9b36aa3fcbea4c46345d637aecc1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc3/tune-server-v1.0.0-rc3-macos-x86_64.tar.gz"
      sha256 "3080e4a974ead0a4c34a5dc57ca64d239d68bfaec6ff17a44c598f17cd9407ba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc3/tune-server-v1.0.0-rc3-linux-aarch64.tar.gz"
      sha256 "70a9862d6f3185bf8165017525a806652ab2b2417f965fd008a3694c0bbb5163"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v1.0.0-rc3/tune-server-v1.0.0-rc3-linux-x86_64.tar.gz"
      sha256 "73f1b7fe6ea4827121865568980fe0ad20f1eb4e3d7b988556f6ee3f4fb97dc2"
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
      Tune Server v1.0.0-rc3 (Rust) installed!

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
