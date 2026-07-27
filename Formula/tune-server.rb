class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.19"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.19/tune-server-v0.9.19-macos-aarch64.tar.gz"
      sha256 "f4547e5dccc5727d0a879947df3802e69c8d1c8ad009f4bcc4282b94bedaefc4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.19/tune-server-v0.9.19-macos-x86_64.tar.gz"
      sha256 "c64681ef8a4d26c572aa0897e4a6fb3f058a02ba776e2b417d70b87538ecea8e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.19/tune-server-v0.9.19-linux-aarch64.tar.gz"
      sha256 "bce41341aa30eb7e8cc4eed7dd27bf20f949c0e88ea54bd53f2a64098484358f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.19/tune-server-v0.9.19-linux-x86_64.tar.gz"
      sha256 "0b62fe13c522bbb76c7834babc1590d765bc44c569880e027873de94962ff9d1"
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
      Tune Server v0.9.19 (Rust) installed!

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
