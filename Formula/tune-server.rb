class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.81"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.81/tune-server-v0.8.81-macos-aarch64.tar.gz"
      sha256 "dfe3893ed9264bf8d5ea0193888d2470a27f064ad0e1e88a3d08e14df32a4f59"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.81/tune-server-v0.8.81-macos-x86_64.tar.gz"
      sha256 "079b060388d1585b474dacb09ebbd187792ce1e076dce0748736ea4104c7f243"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.81/tune-server-v0.8.81-linux-aarch64.tar.gz"
      sha256 "b1b93a88ac24aa145e79cb681df82d40accbe8f0cabcadb74a27cb0ebb381439"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.81/tune-server-v0.8.81-linux-x86_64.tar.gz"
      sha256 "cd00fa5ea1bae188280b7cb6650a679b3dc35362fcdbd77b84c80194e3a2647e"
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
      Tune Server v0.8.81 (Rust) installed!

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
