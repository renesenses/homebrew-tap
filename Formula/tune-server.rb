class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.18"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-macos-aarch64.tar.gz"
      sha256 "feac3d647f402351b3e27234d2bf216f05ff651b15ce40b64677ff988e0c622b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-macos-x86_64.tar.gz"
      sha256 "31beb7c9daf84895edd5bc1d68cbf84d8978e526f92cf1ded7519d0125700cbd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-linux-aarch64.tar.gz"
      sha256 "266c1a34dca3c59f8848863c460572f42ac30e5c6e1ed7f0685cd5b71ab55943"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-linux-x86_64.tar.gz"
      sha256 "e1718209596f4737872774d978bc8bba57a706ebc5bb65c3d71b4946436ef57c"
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
      Tune Server v0.9.18 (Rust) installed!

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
