cask "markview" do
  version "0.5.1"
  sha256 "dedac15c3e17521c9f567d4473135b4db6751ed77d7be6284c0be587fc10c87e"

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
