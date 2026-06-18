class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.136"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.136/tune-server-v0.8.136-macos-aarch64.tar.gz"
      sha256 "dafcc10822e1df9d6dc61446ff4b0014d3443202d76ffb7e795617274b9bc62b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.136/tune-server-v0.8.136-macos-x86_64.tar.gz"
      sha256 "b3d58337859e6cec7bbc121f75996c70521fb5dcfce19848b1a2b99b24b2f335"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.136/tune-server-v0.8.136-linux-aarch64.tar.gz"
      sha256 "d35cc76ead993c252bedb084a3d49865cc606d0a1ce3a5310e875d12834f1be3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.136/tune-server-v0.8.136-linux-x86_64.tar.gz"
      sha256 "753b4e997f2faca2d8f90d8423e5b1185c30982679473a8ba8f4ed765c162c1c"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export TUNE_PORT="${TUNE_PORT:-8888}"
      export TUNE_WEB_DIR="#{opt_pkgshare}/web"
      exec "#{opt_bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.8.136 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server
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
