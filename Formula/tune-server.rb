class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.82"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.82/tune-server-v0.9.82-macos-aarch64.tar.gz"
      sha256 "98cf562ba67d7df3fa581141fba8870cefa878d38a8bd645f407d4b52c1dbf9e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.82/tune-server-v0.9.82-macos-x86_64.tar.gz"
      sha256 "28ecb77cfeb8e0a8dc343eb5b247be12b6f61656091234b6300553dc052b9687"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.82/tune-server-v0.9.82-linux-aarch64.tar.gz"
      sha256 "d6bca2bda5c73cfc6b2904553a96363432cd0f7ea85fc61bb32e19425b517336"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.82/tune-server-v0.9.82-linux-x86_64.tar.gz"
      sha256 "cebc4ee8abc8136156d6560364acfe346149d94e0683062ac0ab2a41896b6cd9"
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
      Tune Server v0.9.82 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

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
