class Notchify < Formula
  desc "Pixel mascot for Claude Code that lives in your MacBook notch"
  homepage "https://github.com/kikudjira/notchify"
  url "https://github.com/kikudjira/notchify/releases/download/v1.0.21/Notchify-v1.0.21.zip"
  sha256 "0f2e43e533569088139c3b8792bc5f0fb7b84b3bccc845550ee86b3e3330de28"
  version "1.0.21"

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
