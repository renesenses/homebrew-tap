class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.107"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.107/tune-server-v0.9.107-macos-aarch64.tar.gz"
      sha256 "d4b986ed269066648ace7fe3b9b1b0ee87cf2544533f35b5ced89dac78944c24"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.107/tune-server-v0.9.107-macos-x86_64.tar.gz"
      sha256 "259343a4ce1f0d63f8b8848157872a1b34c565ce71408fabb3c337453c494da2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.107/tune-server-v0.9.107-linux-aarch64.tar.gz"
      sha256 "d36adcdda0f810caee8e30d8e3e4028ea0c2a211139db4889a00f64a04070b5d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.107/tune-server-v0.9.107-linux-x86_64.tar.gz"
      sha256 "29260158f970c9d5a79fe4548c5a368a6197f73940b9c3f05f04ff41942a35b2"
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
      Tune Server v0.9.107 (Rust) installed!

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
