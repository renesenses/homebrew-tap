class TuneServer < Formula
  desc "Multi-room music server with DLNA/UPnP, AirPlay, and streaming services"
  homepage "https://github.com/renesenses/tune-server-linux"
  version "0.1.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-linux/releases/download/v0.1.6/tune-server-0.1.6-macos.tar.gz"
      sha256 "e210f127c50fb1932bd4c9b63d21d92439f38a7893bc5b9fc5e5bd340c53ff6b"
    else
      url "https://github.com/renesenses/tune-server-linux/releases/download/v0.1.6/tune-server-0.1.6-macos-intel.tar.gz"
      sha256 "eeb6079f118af97d5670fb1d8babd891611dea887b6293f567f656e64a443195"
    end
  end

  on_linux do
    url "https://github.com/renesenses/tune-server-linux/releases/download/v0.1.6/tune-server-0.1.6-linux.tar.gz"
    sha256 "5b55d577162a07c316272881c1fc9eb928fedeabf5011791b70cebc7e55049cd"
  end

  depends_on "python@3.12"
  depends_on "ffmpeg"
  depends_on "portaudio"

  def install
    # Create a virtualenv using the Homebrew Python
    venv = libexec/"venv"
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", venv

    # Install the package and its dependencies into the venv
    system venv/"bin/pip", "install", "--no-cache-dir", "."

    # Create a wrapper script in Homebrew's bin
    (bin/"tune-server").write <<~EOS
      #!/bin/bash
      exec "#{venv}/bin/tune-server" "$@"
    EOS

    # Install example configuration
    etc.install ".env.example" => "tune-server.env.example" if File.exist?(".env.example")
  end

  def post_install
    (var/"tune-server").mkpath
  end

  def caveats
    <<~EOS
      To configure tune-server, copy the example config:
        cp #{etc}/tune-server.env.example ~/.config/tune-server/.env

      Then edit ~/.config/tune-server/.env with your settings.

      To start tune-server:
        tune-server

      To start as a background service:
        brew services start tune-server

      Release notes: https://github.com/renesenses/tune-server-linux/releases/tag/v0.1.6
    EOS
  end

  service do
    run [opt_bin/"tune-server"]
    working_dir var/"tune-server"
    keep_alive true
    log_path var/"log/tune-server.log"
    error_log_path var/"log/tune-server.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    system bin/"tune-server", "--help" rescue nil
  end
end
