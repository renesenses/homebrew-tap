class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.67"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.67/tune-server-v0.8.67-macos-aarch64.tar.gz"
      sha256 "73f0a770e68593288995ee61068a681d2b3cacd4bf21e42934817ce91c72c5de"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.67/tune-server-v0.8.67-macos-x86_64.tar.gz"
      sha256 "abd1c019a0b09595300602739d4e60e6c1de13cb464de5dac1d7a7fb22fb903f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.67/tune-server-v0.8.67-linux-aarch64.tar.gz"
      sha256 "8938befa5bd06b5aded6a5a5dd1a2749e2b5ab4ca43e78776ffa9d86fe82d25b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.67/tune-server-v0.8.67-linux-x86_64.tar.gz"
      sha256 "e5796e45c50f86e446ed010a18c18b62eee6e851b8d28bbedfa8c59c49302845"
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
      Tune Server v0.8.67 (Rust) installed!

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
