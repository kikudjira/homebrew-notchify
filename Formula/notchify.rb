class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.24/Notchify-v1.0.24.zip"
  sha256 "1925fc04028e0964181eb3ef375a4744f5dc1cd9a7282be851a787527886c3a3"
  version "1.0.24"

  head "https://github.com/kikudjira/notchify.git", branch: "beta"

  depends_on :macos => :monterey
  depends_on xcode: ["14.0", :build] if build.head?

  # Swift Package Manager sandbox conflicts with Homebrew sandbox
  sandbox false if build.head?

  def install
    if build.head?
      ENV["SWIFT_BUILD_FLAGS"] = "--disable-sandbox"
      system "./scripts/build.sh"
      rm_rf prefix/"Notchify.app"
      prefix.install "Notchify.app"
      bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"
    else
      rm_rf prefix/"Notchify.app"
      prefix.install "Notchify.app"
      bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"
    end
  end

  def post_install
    # Save app path so 'notchify launch' can find the app
    config_dir = Pathname.new(Dir.home)/".config/notchify"
    config_dir.mkpath
    (config_dir/"app_path").write "#{prefix}/Notchify.app\n"
  rescue StandardError
    # Sandbox may block home directory writes — CLI falls back to argv[0] detection
  end

  def caveats
    <<~EOS
      Launch the app (also enables hooks and startup animation automatically):
        notchify launch

      Then reload your shell so the startup animation takes effect:
        source ~/.zshrc

      To adjust sounds, login item, or display:
        notchify config
    EOS
  end

  test do
    assert_predicate prefix/"Notchify.app", :exist?
    assert_predicate bin/"notchify", :exist?
  end
end
