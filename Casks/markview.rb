cask "markview" do
  version "0.6.0"
  sha256 "be8d1de5be146ae77bc723b8af12c0756125975d2075835dd07b6e72c587f8aa"

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
