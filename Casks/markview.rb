cask "markview" do
  version "0.5.0"
  sha256 "8b9bd4ad1f0f4f1eba215aff72c121281fded033bbeb3a9866cf6cd9af72434a"

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
