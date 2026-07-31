class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.32"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.32/tune-server-v0.9.32-macos-aarch64.tar.gz"
      sha256 "9cc220646dfba7f66784bcb7cb024eeba1e082ee90bf98ed0c182636018f055e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.32/tune-server-v0.9.32-macos-x86_64.tar.gz"
      sha256 "b910055eddfba2a16c2748bc26c2d70e6981013bb536122816a2fcee16aa1c0d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.32/tune-server-v0.9.32-linux-aarch64.tar.gz"
      sha256 "174ad9030883739c538432534e59d3cd69545255a7a769b69260d75315429190"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.32/tune-server-v0.9.32-linux-x86_64.tar.gz"
      sha256 "9829f84f70f042d0b634514f6c15418fc4d8d3cc0c1d9c9e406ea80010d20fd6"
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
      Tune Server v0.9.32 (Rust) installed!

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
