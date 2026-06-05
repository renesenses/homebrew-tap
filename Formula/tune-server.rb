class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.49"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.49/tune-server-v0.8.49-macos-aarch64.tar.gz"
      sha256 "8c2e36b2e4c4fcee23c86e964033002f7451213e23b0e1ff53e2604762f3489d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.49/tune-server-v0.8.49-macos-x86_64.tar.gz"
      sha256 "a27cb94bad847167f0210b05c43af62da2aa9eaa8979b6e57a38208c6ed3653f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.49/tune-server-v0.8.49-linux-aarch64.tar.gz"
      sha256 "94ffd6ed1fb3dc7971a1caf85a75c453b3ad0e5d7a56ff58de993174e364cfb0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.49/tune-server-v0.8.49-linux-x86_64.tar.gz"
      sha256 "12fcb6922fb9fe926487f1f6c3d8b45d73b2a4b0f21dd2369bd27b55871bf673"
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
      Tune Server v0.8.49 (Rust) installed!

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
