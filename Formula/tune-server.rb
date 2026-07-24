class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.1/tune-server-v0.9.1-macos-aarch64.tar.gz"
      sha256 "43f1e9b244007e8f8bffdcf378cea66af781868c90eab4e1960ad27c8cc07631"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.1/tune-server-v0.9.1-macos-x86_64.tar.gz"
      sha256 "1b732a73957124021656d4771dfe5eacbe2cd287da38f5616665e9d734436955"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.1/tune-server-v0.9.1-linux-aarch64.tar.gz"
      sha256 "83c0c8490582e15e7c492db36dd3a7e23d4e87081e54a855a99743ab4d2a103a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.1/tune-server-v0.9.1-linux-x86_64.tar.gz"
      sha256 "ae3d54ff4ba6295d1adfad9675e54820ab03a5f35a5bc558303cc13eb3d9a113"
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
      Tune Server v0.9.1 (Rust) installed!

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
