class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.50"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.50/tune-server-v0.8.50-macos-aarch64.tar.gz"
      sha256 "fa448ee627aad72345c3a6663dc1032238f57053ec1851b2856d21b5033b9c95"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.50/tune-server-v0.8.50-macos-x86_64.tar.gz"
      sha256 "1c770cb9273673500994240e653540ff72144fa9dfd19db65032ebc12e185e00"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.50/tune-server-v0.8.50-linux-aarch64.tar.gz"
      sha256 "2f5eb0f131cc66d3ab7fbb3f1e94fe845d21f562b4f1401e6dd18ba94f3fbcd3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.50/tune-server-v0.8.50-linux-x86_64.tar.gz"
      sha256 "7f30aa58eb83f6c1ec9f8e1c6a3f4b6a4d16f4e73d3aad052d3d0dc12b5da9d9"
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
      Tune Server v0.8.50 (Rust) installed!

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
