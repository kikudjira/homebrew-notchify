class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.0/Notchify-v1.0.0.zip"
  sha256 "70dfedb377896beba5c3524dfe52f931080e6d2c819289a67c8d8f67b5c6c7df"
  version "1.0.0"

  depends_on :macos => :monterey

  def install
    # Install the app bundle to the Homebrew prefix
    prefix.install "Notchify.app"

    # Symlink the CLI into PATH
    bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"

    # Save app path for 'notchify launch' and 'notchify config'
    (etc/"notchify").mkpath
    (etc/"notchify/app_path").write "#{prefix}/Notchify.app\n"
  end

  def caveats
    <<~EOS
      Notchify is not notarized. On first launch macOS may block it.
      To allow it, run:
        xattr -dr com.apple.quarantine #{prefix}/Notchify.app

      Then set up hooks, sounds, and login item:
        notchify config

      To launch the app:
        notchify launch
    EOS
  end

  test do
    assert_predicate prefix/"Notchify.app", :exist?
    assert_predicate bin/"notchify", :exist?
  end
end
