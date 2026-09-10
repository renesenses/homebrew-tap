class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.145"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.145/tune-server-v0.9.145-macos-aarch64.tar.gz"
      sha256 "3f5e87ac739482c414f1b8c0095b1397b25e45060adbaacd9d50eb686b0439a4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.145/tune-server-v0.9.145-macos-x86_64.tar.gz"
      sha256 "2d3b9170ab9e111adeda708473d3dcb6f6dcdf43831ff8d6e08cb17676be2928"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.145/tune-server-v0.9.145-linux-aarch64.tar.gz"
      sha256 "87aaa3718ba8d54934aa1605d75218700727c694be7387e555daddebbb115fa2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.145/tune-server-v0.9.145-linux-x86_64.tar.gz"
      sha256 "b5baab070595fab3600404cc2b22deb49146ad986803f824fb89ff87684302e6"
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
      Tune Server v0.9.145 (Rust) installed!

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
