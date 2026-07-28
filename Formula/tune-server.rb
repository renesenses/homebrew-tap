class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.25"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.25/tune-server-v0.9.25-macos-aarch64.tar.gz"
      sha256 "8246fee83479ed23e9b10e0bce0535984acfe232bc335029eff173d771a15fa1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.25/tune-server-v0.9.25-macos-x86_64.tar.gz"
      sha256 "71222f2a36ce807d9501f12a020ac7ac1c2397f3278c0afe09f24cb8c30c4b2e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.25/tune-server-v0.9.25-linux-aarch64.tar.gz"
      sha256 "a5f4ccf8759498af8d866becab44a056a14e61a1996a02285b634d8855ae3855"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.25/tune-server-v0.9.25-linux-x86_64.tar.gz"
      sha256 "fa7463be52838f9b34439cef5bf121dc7136f5f628ba2f6aca26cc425b07bc72"
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
      Tune Server v0.9.25 (Rust) installed!

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
