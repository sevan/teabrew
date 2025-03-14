class Libmpc08 < Formula
  desc "C library for high precision complex numbers"
  homepage "http://multiprecision.org"
  # Track gcc infrastructure releases.
  url "https://www.multiprecision.org/downloads/mpc-0.8.1.tar.gz"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz"
  sha256 "e664603757251fd8a352848276497a4c79b7f8b21fd8aedd5cc0598a38fee3e4"

  bottle do
    cellar :any
  end

  keg_only "Conflicts with libmpc in main repository."

  depends_on "gmp4"
  depends_on "mpfr2"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}",
    ]

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mpc.h>

      int main()
      {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_clear (x);
        return 0;
      }
    EOS
    gmp4 = Formula["gmp4"]
    mpfr2 = Formula["mpfr2"]
    system ENV.cc, "test.c",
      "-I#{gmp4.include}", "-L#{gmp4.lib}", "-lgmp",
      "-I#{mpfr2.include}", "-L#{mpfr2.lib}", "-lmpfr",
      "-I#{include}", "-L#{lib}", "-lmpc",
      "-o", "test"
    system "./test"
  end
end
