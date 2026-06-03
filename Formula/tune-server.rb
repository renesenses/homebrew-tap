class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.36"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.36/tune-server-v0.8.36-macos-aarch64.tar.gz"
      sha256 "bb1911039e8cbc43f355ce4663ad05718bd7fb2351d661bbe80ad7aeec9709a4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.36/tune-server-v0.8.36-macos-x86_64.tar.gz"
      sha256 "d6e14cac48332fab0ec67f83775e8cf763742020e5a82fb60cf3deb48ea572c9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.36/tune-server-v0.8.36-linux-aarch64.tar.gz"
      sha256 "625fd8f606f8123e4e7aba8ce128ebf78459c1a15151505ce894292a3ff68094"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.36/tune-server-v0.8.36-linux-x86_64.tar.gz"
      sha256 "9ade0e8ebb2c8ae1f150dec615006df5f569066e0a115ba33be209dd05854f6e"
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
      Tune Server v0.8.36 (Rust) installed!

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
