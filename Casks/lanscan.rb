cask "lanscan" do
  version "1.0.0"
  sha256 "488d514fd92eedb5f3ecfcff2031e0d686e1bc49c20704b5a640ef9e6e707af4"

  url "https://github.com/renesenses/lanscan/releases/download/v#{version}/LanScan-#{version}.dmg"
  name "LanScan"
  desc "Fast, native macOS LAN scanner built with SwiftUI"
  homepage "https://github.com/renesenses/lanscan"

  depends_on macos: ">= :sonoma"

  app "LanScan.app"

  zap trash: [
    "~/Library/Application Support/LanScan",
  ]
end
