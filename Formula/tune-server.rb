class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.23"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.23/tune-server-v0.9.23-macos-aarch64.tar.gz"
      sha256 "93b2d6f95a9c29fbd2b8eefc9f754696e73eafe29f87cacb937fc67a07dba9d1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.23/tune-server-v0.9.23-macos-x86_64.tar.gz"
      sha256 "9eca2e5da0df8a4c86187d63df23f71e89b57bf68006e4cb092a3f70fd81c668"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.23/tune-server-v0.9.23-linux-aarch64.tar.gz"
      sha256 "dbeb1c777d7da32848e99ac205c000893e09398fc78a8efa20e72233c4e811d1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.23/tune-server-v0.9.23-linux-x86_64.tar.gz"
      sha256 "eb2548b525fd9344aea139b3673c690dd1017c199c959727f866d80d966f463c"
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
      Tune Server v0.9.23 (Rust) installed!

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
