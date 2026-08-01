class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.36"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.36/tune-server-v0.9.36-macos-aarch64.tar.gz"
      sha256 "23baf843ae4f86757ab456af9023c13b27d0a62910c5969747efc406b6cd1458"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.36/tune-server-v0.9.36-macos-x86_64.tar.gz"
      sha256 "f1ee6f30023cd532ca27c6d388bfad51437a0d1f6969515e6270ad5ca4d9c2e4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.36/tune-server-v0.9.36-linux-aarch64.tar.gz"
      sha256 "5b6f135b18268f6a9c72588f05bb3b881f3c28acfe668460374f220f80d5febd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.36/tune-server-v0.9.36-linux-x86_64.tar.gz"
      sha256 "0e2b918d7216fc0c068c52da10d1259ee841bb08e1a9879ab9ff27192c6f47e1"
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
      Tune Server v0.9.36 (Rust) installed!

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
