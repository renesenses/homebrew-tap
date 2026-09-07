class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.140"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.140/tune-server-v0.9.140-macos-aarch64.tar.gz"
      sha256 "99288b7edd65927f6558fb109b43e65afa7063ac175f2d5896673aebae4cf65f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.140/tune-server-v0.9.140-macos-x86_64.tar.gz"
      sha256 "9aecfb34f1b64ddb4feac90ce379182e19bcc9d1e44c336c2682cddb54a8432d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.140/tune-server-v0.9.140-linux-aarch64.tar.gz"
      sha256 "a6c4825b9e6e903041c88b2d9446286ded4ce7a27cf9756a97ef26ba91094786"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.140/tune-server-v0.9.140-linux-x86_64.tar.gz"
      sha256 "ca6e5035e04ffd068f4b0b96ad49254170a48e82bad87d985aa2abbc17a9c2e9"
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
      Tune Server v0.9.140 (Rust) installed!

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
