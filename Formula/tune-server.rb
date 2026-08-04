class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.47"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.47/tune-server-v0.9.47-macos-aarch64.tar.gz"
      sha256 "00fd2ab867c6d5a8559cb3e58403d86574671e1d28056dee02885b8a08aa5b8a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.47/tune-server-v0.9.47-macos-x86_64.tar.gz"
      sha256 "28a0543d4f1a7254a7dd475193abedd178f4fd74fd4f2295a0cc4bbfb57a4a89"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.47/tune-server-v0.9.47-linux-aarch64.tar.gz"
      sha256 "4dc43aa61307f9042349d3b7f86e0a579ed4f4fe2a071af23578a70319f8ba3c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.47/tune-server-v0.9.47-linux-x86_64.tar.gz"
      sha256 "96f2ca3a6aed954270712de6529615e8e6b37d72ad979f4e3a4395429533ca60"
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
      Tune Server v0.9.47 (Rust) installed!

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
