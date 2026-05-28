class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-aarch64.tar.gz"
      sha256 "34a2f62b713e4ac12ca5a7fd323b75846e26fcaffbe3e7305204e1d46b7f0553"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-x86_64.tar.gz"
      sha256 "5e8a7ec82a620a44989d68b3cea38513d166e410a8cb6e5bae6cc4ec312d5851"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-aarch64.tar.gz"
      sha256 "46429643128da383640cf5d448a6fa661a0076bb40a32f39b1a768751140c609"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-x86_64.tar.gz"
      sha256 "1d6d4aefb453a9ada6f912e75042e3ed45d35059513caf87ccad372729db3ba2"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.2 (Rust) installed!

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
