class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.52"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.52/tune-server-v0.9.52-macos-aarch64.tar.gz"
      sha256 "b620e4739dd5882b97d72bdc1f54e44bae51d8e15bd1303a240f26f1d63416bb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.52/tune-server-v0.9.52-macos-x86_64.tar.gz"
      sha256 "7707d6923e7fdf77c33ca041ad3c95e222c0fe3a7c1a80698d00cf6be6073c2b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.52/tune-server-v0.9.52-linux-aarch64.tar.gz"
      sha256 "23580772f5f333af36d09eb537a4c7df3a19f8f82c13885e0e67c0ec9e3a6e89"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.52/tune-server-v0.9.52-linux-x86_64.tar.gz"
      sha256 "fdfa37c10b2fe25ae1f1577fdcec9558c856909ce2a8d6dd08eced6f6ddeb187"
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
      Tune Server v0.9.52 (Rust) installed!

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
