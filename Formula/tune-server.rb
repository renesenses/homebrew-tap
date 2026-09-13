class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.148"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.148/tune-server-v0.9.148-macos-aarch64.tar.gz"
      sha256 "cf43f0502314508312e0aa79ae37ce1dc500ca0f958713339cac76cb31508327"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.148/tune-server-v0.9.148-macos-x86_64.tar.gz"
      sha256 "ae58bd53ee908bd1a392623ca9cfbc11030a36287552eeccfdf0136b32dc2e82"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.148/tune-server-v0.9.148-linux-aarch64.tar.gz"
      sha256 "95534dc091f94a9ae2b8c9c33ea8e293415e30e8ee3684d330d3e4109a2907ee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.148/tune-server-v0.9.148-linux-x86_64.tar.gz"
      sha256 "aed63a6449eb7105f37fa07fff579744d6026de4fcc442d777fef57a92db2435"
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
      Tune Server v0.9.148 (Rust) installed!

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
