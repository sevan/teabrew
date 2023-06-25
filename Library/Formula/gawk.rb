class Gawk < Formula
  desc "GNU awk utility"
  homepage "https://www.gnu.org/software/gawk/"
  url "http://ftpmirror.gnu.org/gawk/gawk-5.2.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gawk/gawk-5.2.2.tar.xz"
  sha256 "3c1fce1446b4cbee1cd273bd7ec64bc87d89f61537471cd3e05e33a965a250e9"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-readline",
                          "--without-mpfr",
                          "--without-libsigsegv-prefix"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/gawk '{ gsub(/Macro/, \"Home\"); print }' -", "Macrobrew")
    assert_equal "Homebrew", output.strip
  end
end
