class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.165"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.165/tune-server-v0.9.165-macos-aarch64.tar.gz"
      sha256 "6d7b1558810a412a48604ced7321337d478a156955229665956b090f3faf77d3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.165/tune-server-v0.9.165-macos-x86_64.tar.gz"
      sha256 "72e5601ae5a4f51da85943e8d1b3b0e1499ce819bf55dfe805f6781b5768c154"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.165/tune-server-v0.9.165-linux-aarch64.tar.gz"
      sha256 "23fa5ef9668ea0e2693286d7917301b15193afed178237a164f1a3b279cc8783"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.165/tune-server-v0.9.165-linux-x86_64.tar.gz"
      sha256 "392e8c4ea9d088044287c229671e99c57d2526cdb3d3631ee41c53e954fb1b85"
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
      Tune Server v0.9.165 (Rust) installed!

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
