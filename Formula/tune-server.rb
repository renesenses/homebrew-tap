class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.109"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.109/tune-server-v0.9.109-macos-aarch64.tar.gz"
      sha256 "0800b93fa919cf5d5599cef5162655f86b44c8566028f3b2658db603cd5334b1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.109/tune-server-v0.9.109-macos-x86_64.tar.gz"
      sha256 "fe2f274216a9c56a53ec42062f8bf45710b0c8772bef23393da49f17be38cd8f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.109/tune-server-v0.9.109-linux-aarch64.tar.gz"
      sha256 "924d5b5818f11b0913e905c615b8ed6e7f953d5b23ef1940aae9e257929f4502"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.109/tune-server-v0.9.109-linux-x86_64.tar.gz"
      sha256 "e85af0b1c78eff856e61d03c37fbda6a1ac60422df6224bfbe4869027966077e"
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
      Tune Server v0.9.109 (Rust) installed!

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
