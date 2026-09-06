class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.138"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.138/tune-server-v0.9.138-macos-aarch64.tar.gz"
      sha256 "807ee48a28c439eefc66cf68b4264a2dddc3be948aa0df74a7ec19d91c154547"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.138/tune-server-v0.9.138-macos-x86_64.tar.gz"
      sha256 "45cca248f396cd82d825c11db71079f2f3d710bf4e662168f565a400dd97920c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.138/tune-server-v0.9.138-linux-aarch64.tar.gz"
      sha256 "2963d5194cc28b74eca18587c813b570e0eecded62e2ce947d59a44727d768c6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.138/tune-server-v0.9.138-linux-x86_64.tar.gz"
      sha256 "a88e6bffcc1903e63f5337b261287e381de8f951f743fd9892767650d2837d8f"
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
      Tune Server v0.9.138 (Rust) installed!

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
