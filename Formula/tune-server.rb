class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.73"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.73/tune-server-v0.9.73-macos-aarch64.tar.gz"
      sha256 "1ff51f244dc8685c76cacd797c4661a2cbee1cf484843bf98d7a7c9706400347"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.73/tune-server-v0.9.73-macos-x86_64.tar.gz"
      sha256 "e293458a7a59682e1a9104ca249b3617806657a82543627a90f1039d80b8ac5f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.73/tune-server-v0.9.73-linux-aarch64.tar.gz"
      sha256 "c939674300911a965a9fc93fb0c4137abb62452f7c1e8acb75b39908a18708c3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.73/tune-server-v0.9.73-linux-x86_64.tar.gz"
      sha256 "5141055e1035a2b9dfc8ab5a20d8fbdc21995a8b61f65a9a5aa9a86149687c1e"
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
      Tune Server v0.9.73 (Rust) installed!

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
