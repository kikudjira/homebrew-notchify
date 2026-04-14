class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.1/Notchify-v1.0.1.zip"
  sha256 "0215a402e045bc3e74590899c306ac908b19211c015043b0b041b7c8aa24e8d0"
  version "1.0.1"

  depends_on :macos => :monterey

  def install
    prefix.install "Notchify.app"
    bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"
  end

  def post_install
    # Write app path so 'notchify launch' and 'notchify config' can find the app
    config_dir = Pathname.new(Dir.home)/".config/notchify"
    config_dir.mkpath
    (config_dir/"app_path").write "#{prefix}/Notchify.app\n"
  end

  def caveats
    <<~EOS
      Notchify is not notarized. On first launch macOS may block it.
      To allow it, run:
        xattr -dr com.apple.quarantine #{prefix}/Notchify.app

      Then launch the app and configure hooks:
        notchify launch
        notchify config
    EOS
  end

  test do
    assert_predicate prefix/"Notchify.app", :exist?
    assert_predicate bin/"notchify", :exist?
  end
end
