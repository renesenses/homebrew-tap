class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.94"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.94/tune-server-v0.8.94-macos-aarch64.tar.gz"
      sha256 "ae2dfbea2ea6841e4ab68f79bba361776e1358b4a47e1201a270d81b40a94a9f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.94/tune-server-v0.8.94-macos-x86_64.tar.gz"
      sha256 "973c076119094ba0f9daeef31e63d21c100248f66484d7ec1e0f980f691c2c3b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.94/tune-server-v0.8.94-linux-aarch64.tar.gz"
      sha256 "5519484402a0043198627b7806cf86ee300564786e73d51d8efc13c71fea910e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.94/tune-server-v0.8.94-linux-x86_64.tar.gz"
      sha256 "018d1ad521480c86b00e0730ac5a8df48d9fac82a028e725056f49d5185c937d"
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
      Tune Server v0.8.94 (Rust) installed!

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
