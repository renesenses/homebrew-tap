class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.11/tune-server-v0.9.11-macos-aarch64.tar.gz"
      sha256 "ecb539049ba104cdeff1da2d80a2bcee096d44e837288ce03ab6e2c675782d67"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.11/tune-server-v0.9.11-macos-x86_64.tar.gz"
      sha256 "0165d7f9e38cc8b965724a80a8863618963b30271bc3c288ac54505499970c63"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.11/tune-server-v0.9.11-linux-aarch64.tar.gz"
      sha256 "e84cb048c46ac861fc700cd83035a0ecd08a036876dc709f5278937ea97c2295"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.11/tune-server-v0.9.11-linux-x86_64.tar.gz"
      sha256 "b08ce8577f97a3f3f020ec396b44fdb1976935b5a26199674f156f50248b5916"
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
      Tune Server v0.9.11 (Rust) installed!

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
