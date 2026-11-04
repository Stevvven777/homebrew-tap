cask "markview" do
  version "0.4.5"
  sha256 "de379a7ce46cb70d88cea2d9e31d67400591f7cd75ed034f54b2c79de83c56a2"

  url "https://github.com/szdytom/markview/releases/download/v#{version}/markview-#{version}-aarch64.app.zip"
  name "Markview"
  desc "Native Markdown reader with publication-quality typography"
  homepage "https://github.com/szdytom/markview"

  depends_on arch: :arm64
  depends_on :macos

  app "Markview.app"

  uninstall quit: "com.github.szdytom.markview"

  caveats <<~EOS
    Markview is ad-hoc signed and is not notarized by Apple.
    If macOS blocks it, review the app in System Settings > Privacy & Security
    and choose Open Anyway. An update may require approval again.
  EOS
end
