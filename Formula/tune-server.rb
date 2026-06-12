class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.92"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.92/tune-server-v0.8.92-macos-aarch64.tar.gz"
      sha256 "e2dbe328577f26bfee7d3a6ee74ee8b98eff91efd92e1325c307f7a66ef7a790"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.92/tune-server-v0.8.92-macos-x86_64.tar.gz"
      sha256 "af71557997d22425f177418af52c1acca7d7af1e08e73d0da51eac4e10f39721"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.92/tune-server-v0.8.92-linux-aarch64.tar.gz"
      sha256 "4a00ad01feb0f95d3ac9fb665db6c1bc7c7819ded72c31d33a28f786b67af8eb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.92/tune-server-v0.8.92-linux-x86_64.tar.gz"
      sha256 "68aa7c12f20bf3f94691734de74f213f379cd4f6792ac326942004791dace450"
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
      Tune Server v0.8.92 (Rust) installed!

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
