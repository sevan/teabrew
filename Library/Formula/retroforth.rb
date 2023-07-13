class Retroforth < Formula
  desc "A modern, pragmatic Forth drawing influence from many sources"
  homepage "https://retroforth.org"
  url "https://retroforth.org/r/RETRO12-2023.3.tar.gz"
  version "2023.3"
  sha256 "5ee8c2416598d11edac331c7f3f81141e249cb1826ad740ac5c28a7c39860671"

  def install
    # Need a compiler with support for C11 typedef redefinitions e.g GCC 4.6 or newer
    system "make", "install", "PREFIX=#{prefix}", "CC=#{ENV.cc}"
  end

  test do
    system "#{bin}/retro < /dev/null"
  end
end
