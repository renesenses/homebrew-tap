class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.33"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.33/tune-server-v0.9.33-macos-aarch64.tar.gz"
      sha256 "711cc9de764138bdbbd5f9454c99a45003c95e0801f2b25aeb9d420bece0225a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.33/tune-server-v0.9.33-macos-x86_64.tar.gz"
      sha256 "c49428aaee9666ae2cfd0f6a9a426b156f7730d6461f4f9e3aac6817cd1639dd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.33/tune-server-v0.9.33-linux-aarch64.tar.gz"
      sha256 "c7a82c46eb25bf55e438a76e128aa40e08ff4e9b8c35c6be4e2c5cde85b08897"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.33/tune-server-v0.9.33-linux-x86_64.tar.gz"
      sha256 "5befd7b6450fdc7ec35f01c3d85702b91d7ab652732f09de72db64ac48b66929"
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
      Tune Server v0.9.33 (Rust) installed!

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
