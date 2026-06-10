class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.76"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.76/tune-server-v0.8.76-macos-aarch64.tar.gz"
      sha256 "d827dceb9e97ba14bece8a54f1e0bf31f2b673a85b2989e9e4df39b24734619c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.76/tune-server-v0.8.76-macos-x86_64.tar.gz"
      sha256 "786292620d94f38cc72d229d46eded5851503cec879bd8b3e60eba35fef18b7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.76/tune-server-v0.8.76-linux-aarch64.tar.gz"
      sha256 "b8a352224eada74989ad39ee597d55581fe1cadff41b8fd818441df6f8f7d9aa"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.76/tune-server-v0.8.76-linux-x86_64.tar.gz"
      sha256 "9c978433bb0cb1bd615a9f34eb8a446f3105566ed0c3a18bb686b37657a0f046"
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
      Tune Server v0.8.76 (Rust) installed!

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
