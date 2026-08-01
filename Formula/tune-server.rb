class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.38"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.38/tune-server-v0.9.38-macos-aarch64.tar.gz"
      sha256 "7a4747c8aabb0758ffd20ec90346f519feab2a671d5bbb98a9beb137de9efae6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.38/tune-server-v0.9.38-macos-x86_64.tar.gz"
      sha256 "01bfd157060b604ef7eb737761e9a747833e9f7067a7bcc57e0df6ec0c0987b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.38/tune-server-v0.9.38-linux-aarch64.tar.gz"
      sha256 "b1e5754f85c3f9e828cd9b2bc84d4fa050f2c8fbb7c16d249deb05e746b1a080"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.38/tune-server-v0.9.38-linux-x86_64.tar.gz"
      sha256 "7899d9ef06f05e696d896d9aafe116390a36afea9340e017f3b0812d14454e21"
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
      Tune Server v0.9.38 (Rust) installed!

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
