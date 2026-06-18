class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.135"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.135/tune-server-v0.8.135-macos-aarch64.tar.gz"
      sha256 "b863d2daa5680e281c35e3de6620f5fbeb8176fa6d5d7cc80346f293e7a7a61a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.135/tune-server-v0.8.135-macos-x86_64.tar.gz"
      sha256 "d97b8c858d57cbb02300414b07c616b9fdd39b48688408d4c3906e0b230b93ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.135/tune-server-v0.8.135-linux-aarch64.tar.gz"
      sha256 "97883d1e3677bd3f91055ef03902d6bedb9504c24f8efe188074263641e28cf9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.135/tune-server-v0.8.135-linux-x86_64.tar.gz"
      sha256 "a493546d340f424426b08a6fb3fa590055ba58efc2c7cbbecf1c3fabd143a85b"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
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
      Tune Server v0.8.135 (Rust) installed!

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
