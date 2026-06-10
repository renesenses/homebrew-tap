class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.71"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.71/tune-server-v0.8.71-macos-aarch64.tar.gz"
      sha256 "2cefd294de8e3f483dfac17eacbf56e74bea01ec1abe762254fe7274eca9e5cb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.71/tune-server-v0.8.71-macos-x86_64.tar.gz"
      sha256 "7affee322ffa170c4f4b6839462dc24185e33428172d35ba87ca33cbbb1eb33e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.71/tune-server-v0.8.71-linux-aarch64.tar.gz"
      sha256 "6cac0c630f343157fdf44ee18b6fbe88367002bf68b6c904b352122d34b3455e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.71/tune-server-v0.8.71-linux-x86_64.tar.gz"
      sha256 "7c30eecc353346b15f58a34f2892384a463f474130407e42c406d5775c036aa7"
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
      Tune Server v0.8.71 (Rust) installed!

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
