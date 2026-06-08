class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.65"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.65/tune-server-v0.8.65-macos-aarch64.tar.gz"
      sha256 "100b02f3aac52b9de873caf65b16e24b511469a845d6aaeccb44ff35b09aba9d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.65/tune-server-v0.8.65-macos-x86_64.tar.gz"
      sha256 "5784d89457d48808f6d92607340c776c1c5d86d29e58bbf3d50fcc6d00e505bc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.65/tune-server-v0.8.65-linux-aarch64.tar.gz"
      sha256 "97b8b33fa61df13f38026b6f0c88d26d6678ffb3e341c86cc63ae1cf401a1e09"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.65/tune-server-v0.8.65-linux-x86_64.tar.gz"
      sha256 "73b6b1df759936eb1b403f87b3b5af0932bb51fa4ba4b413b054e62553fa5ac2"
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
      Tune Server v0.8.65 (Rust) installed!

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
