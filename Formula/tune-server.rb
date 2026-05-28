class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-aarch64.tar.gz"
      sha256 "7221103b0367c92417df3a5f41de105cbc274e2ad5f392326beb60ef0427f497"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-macos-x86_64.tar.gz"
      sha256 "68145e25267ec4ecb8c863c03b0f5bf4240237c8e050972c1164e5bd740154ea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-aarch64.tar.gz"
      sha256 "15782a96860141fc169fc34364e6616d38dcfb7708b75231c3181634cf95d5f7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.2/tune-server-linux-x86_64.tar.gz"
      sha256 "a40fd3b5c471ea3a1174f2697f7ecaad448497be8a7f6b05d875abd16465b8d1"
    end
  end

  depends_on "ffmpeg"

  def install
    bin.install "tune-server"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
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
      Tune Server v0.8.2 (Rust) installed!

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
