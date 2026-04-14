class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.15/Notchify-v1.0.15.zip"
  sha256 "42c8f65a0d6fdabe0398ffb1c1e9927c5276a0db0883c755e0d8b818f9593bc6"
  version "1.0.15"

  depends_on :macos => :monterey

  def install
    prefix.install "Notchify.app"
    bin.install_symlink "#{prefix}/Notchify.app/Contents/MacOS/notchify-cli" => "notchify"
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
      Launch the app:
        notchify launch

      Then configure hooks, sounds, startup animation and login item:
        notchify config
    EOS
  end

  test do
    assert_predicate prefix/"Notchify.app", :exist?
    assert_predicate bin/"notchify", :exist?
  end
end
