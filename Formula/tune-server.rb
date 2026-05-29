class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.4/tune-server-v0.8.4-macos-aarch64.tar.gz"
      sha256 "434442dca20fc3220646f4b49c10de7b40814416be5c313e880816f2d79ebcb9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.4/tune-server-v0.8.4-macos-x86_64.tar.gz"
      sha256 "acd6384b597201ce32b012a40636a3c047b05045102aeab952b7ca2a8c5dec1c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.4/tune-server-v0.8.4-linux-aarch64.tar.gz"
      sha256 "4ad2d71e09642d122f48fd429590ea4c26c92799934617d49c80f5128f1be733"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.4/tune-server-v0.8.4-linux-x86_64.tar.gz"
      sha256 "dd7cf12ccfddce155a66fae4f114ec52049c8a5160b13bdf22cfc776c93e8be9"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.4 (Rust) installed!

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
