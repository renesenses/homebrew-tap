class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.73"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.73/tune-server-v0.8.73-macos-aarch64.tar.gz"
      sha256 "f94b994d5a93908127d5fa4d4162296aa5d0b47085a42d8950e7ec9fd7214bb7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.73/tune-server-v0.8.73-macos-x86_64.tar.gz"
      sha256 "8106ef6df213f9d7282feb645117e51b40c91d30e2788eb080450f29bbf9563e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.73/tune-server-v0.8.73-linux-aarch64.tar.gz"
      sha256 "81cdd882218a6b30530dfe953914504ea94cadabbe08a39fbeabc027a55bce09"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.73/tune-server-v0.8.73-linux-x86_64.tar.gz"
      sha256 "b7e1ea4d06133398bc426ffce5f4c76072a66b939ff6b76ea17e9750d943cf30"
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
      Tune Server v0.8.73 (Rust) installed!

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
