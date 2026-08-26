class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.113"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.113/tune-server-v0.9.113-macos-aarch64.tar.gz"
      sha256 "fc5a3a1018a794cc774ca048e7346705857627688fd9455749635ff91b5443a1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.113/tune-server-v0.9.113-macos-x86_64.tar.gz"
      sha256 "0eccc973b4f84f14578667982648a123e57f90625b888ab610f64471216243c9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.113/tune-server-v0.9.113-linux-aarch64.tar.gz"
      sha256 "85d120f1eba22c40321959f9146f9d6e42ffe6807a9f2cdd278816e8d4a85479"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.113/tune-server-v0.9.113-linux-x86_64.tar.gz"
      sha256 "b1fabc34b5043ebcfb910f379ba7448acf27ec8658b39b2841f50b0be6a79b18"
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
      Tune Server v0.9.113 (Rust) installed!

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
