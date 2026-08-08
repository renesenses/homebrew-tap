class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.55"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.55/tune-server-v0.9.55-macos-aarch64.tar.gz"
      sha256 "2f4d7431202df7b9ed9a09bc3524416147fb31fd6bd4a6cc66a06285bd81a0c0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.55/tune-server-v0.9.55-macos-x86_64.tar.gz"
      sha256 "d8306f67241bce680aec6832513035f8e0c00b6adb3cbd6f86c7fc948ffdd9fd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.55/tune-server-v0.9.55-linux-aarch64.tar.gz"
      sha256 "00ebec751132a86835b2f3ff632adae834f5031b93515d21ea82c93dded8f58f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.55/tune-server-v0.9.55-linux-x86_64.tar.gz"
      sha256 "ec4f43502a73ad258c4f8a74911d7be0a7a1f3f54f259b3a77c6b453dd6ec863"
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
      Tune Server v0.9.55 (Rust) installed!

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
