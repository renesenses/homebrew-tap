class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.78"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.78/tune-server-v0.9.78-macos-aarch64.tar.gz"
      sha256 "d500065223278972f1705c2995cd3b3e50209db6f4ccb377d07324274b4d3c63"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.78/tune-server-v0.9.78-macos-x86_64.tar.gz"
      sha256 "6197540c9fbda88bcdc7faf92cc6e485e75f33249a884774c751d870dd437149"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.78/tune-server-v0.9.78-linux-aarch64.tar.gz"
      sha256 "ec30c365aa8182bd257b54eb977889c3c5561d445bcb8c2a68af5adeb0babd69"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.78/tune-server-v0.9.78-linux-x86_64.tar.gz"
      sha256 "307ab52c03bd4689d77670ba84d546726090dc8583ccc2edeb4dd09ab994e49d"
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
      Tune Server v0.9.78 (Rust) installed!

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
