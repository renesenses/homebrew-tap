class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.133"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.133/tune-server-v0.9.133-macos-aarch64.tar.gz"
      sha256 "273387b299a7c0efb3a873e423d7b3fcca521b3d270981993ab1dc8f45fbbafe"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.133/tune-server-v0.9.133-macos-x86_64.tar.gz"
      sha256 "b82660c9c1f9de3e72cb6b91a276b6b29ef497f56924f454731f81a868827096"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.133/tune-server-v0.9.133-linux-aarch64.tar.gz"
      sha256 "2ada2f6ae42f5cb244cdc42a85bffd0b7d4f0b40e75bf8647a0727c678f0441d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.133/tune-server-v0.9.133-linux-x86_64.tar.gz"
      sha256 "4b6484e64b977b759820cae506ab2220959835aea0d9cd4cec5bd2de329536d0"
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
      Tune Server v0.9.133 (Rust) installed!

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
