class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-aarch64.tar.gz"
      sha256 "4b589a57eced4e2ce191e50a83c19870de4a966e4d5d5c405970e93e60685f50"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-x86_64.tar.gz"
      sha256 "e177aeb6706fa34512d910c6c595c45d33b9c96c3070caeaea4853dfba058b5e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-aarch64.tar.gz"
      sha256 "9c3981dd9d38e85c58ac612d7330621ba3f895a0f1221e0330aecb3ecf50c549"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-x86_64.tar.gz"
      sha256 "b2b9fbfbae7c228e20fc9cf6a7626b9fdd978439e78eb691f2cfdee8a1314659"
    end
  end

  depends_on "ffmpeg"

  def install
    bin.install "tune-server"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
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
