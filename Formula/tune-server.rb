class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.52"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.52/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "91b6d27b1b08afec1633c983263b570e4dbb2a6da283e630e000594eb091c388"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.52/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "0ade0300b74aa5cd88dfd3693dc13c482226c6ce7d0e58d89b4eaffccfb3f948"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.52/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "b0c080eedb87f80d3fefe5da2dd6a9eb0b86638e5f5d371627a1e5eeedd502f8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.52/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "3ec01d1c5a4771a4f25fae5c22fac3ab47ce978ce9e05b27e940957cc256ded5"
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
      Tune Server v0.8.52 (Rust) installed!

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
