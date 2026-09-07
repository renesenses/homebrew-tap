class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.141"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.141/tune-server-v0.9.141-macos-aarch64.tar.gz"
      sha256 "9150346cdcf2808e8e9ddd364bb433c5a34a47cedb7aad2d6acdef846b63914b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.141/tune-server-v0.9.141-macos-x86_64.tar.gz"
      sha256 "a232c5501a5a581013b79a0d82630dd4e42803480b3884f21796365d2678375b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.141/tune-server-v0.9.141-linux-aarch64.tar.gz"
      sha256 "1805ffecb448b09b39e6c809c4e8815977874baaeed144e43dfe656720f89126"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.141/tune-server-v0.9.141-linux-x86_64.tar.gz"
      sha256 "f4fa3f59f269656bf04255056e1b19a668254e3248109a4941c0f276da226021"
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
      Tune Server v0.9.141 (Rust) installed!

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
