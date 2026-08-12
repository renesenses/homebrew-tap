class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.69"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.69/tune-server-v0.9.69-macos-aarch64.tar.gz"
      sha256 "74da1cc7ef9c00595ed832088c30ee3d8c41cab08c67ea3415dae9f5e9ada653"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.69/tune-server-v0.9.69-macos-x86_64.tar.gz"
      sha256 "1e3c3048d4a8bb4e1a11195b50137ed2ce9dbb92580bd70441fd821f35fc317b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.69/tune-server-v0.9.69-linux-aarch64.tar.gz"
      sha256 "fd51d05ac041521866e9dda5d0874ba4a98c8968e267197e62eb0217a1f091b7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.69/tune-server-v0.9.69-linux-x86_64.tar.gz"
      sha256 "3f06f9f4b466cc36f6952ccf067823514a8b6eab8d5e342de398acf70a9de643"
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
      Tune Server v0.9.69 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

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
