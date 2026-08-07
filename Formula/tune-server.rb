class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.53"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.53/tune-server-v0.9.53-macos-aarch64.tar.gz"
      sha256 "e0f39c678cda5221831db2af130fcd208bd22324ac484fa163e8c696eaba7d8e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.53/tune-server-v0.9.53-macos-x86_64.tar.gz"
      sha256 "573734fb6443ab284ee3586474e5ab613374e0df188a1b8b196b85da5ae95c70"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.53/tune-server-v0.9.53-linux-aarch64.tar.gz"
      sha256 "001b565f7c0e33a869cb6dcbc183cf5ea92735c8e9871f0809084f4d9041f250"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.53/tune-server-v0.9.53-linux-x86_64.tar.gz"
      sha256 "69ea7f8d75ac003d2ad075ad9de9828c9ec009e1981574395e8b62edff5df9c7"
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
      Tune Server v0.9.53 (Rust) installed!

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
