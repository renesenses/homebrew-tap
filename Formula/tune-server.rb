class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.64"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.64/tune-server-v0.9.64-macos-aarch64.tar.gz"
      sha256 "af54766f49d2f25b075f2c4261175739a67166ccffd4b4a4103e267123996094"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.64/tune-server-v0.9.64-macos-x86_64.tar.gz"
      sha256 "131f0ca02070c038b618fb50e65a3582b69fb1dd77b10195f71be9a05b736b0d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.64/tune-server-v0.9.64-linux-aarch64.tar.gz"
      sha256 "a99fab585bfa6eae006be3fecd564e714c80823112f13eb805ba7b8457f6d8b8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.64/tune-server-v0.9.64-linux-x86_64.tar.gz"
      sha256 "b1638ff578c97a2ae406a47e8eb3451b15cde9f7b4e36dd015bc94a296cfc3a9"
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
      Tune Server v0.9.64 (Rust) installed!

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
