class Openssl3 < Formula
  desc "Cryptography and SSL/TLS Toolkit"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-3.1.1.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-3.1.1.tar.gz"
  sha256 "b3aa61334233b852b63ddb048df181177c2c659eb9d4376008118f9c08d07674"
  license "Apache-2.0"

  keg_only :provided_by_osx

  depends_on "curl-ca-bundle"
  depends_on "perl"

  # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
  # SSLv3 & zlib are off by default with 1.1.0 but this may not
  # be obvious to everyone, so explicitly state it for now to
  # help debug inevitable breakage.
  def configure_args
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      --libdir=#{lib}
      no-ssl3
      no-ssl3-method
      no-zlib
    ]
    args << "no-asm" if MacOS.version == :tiger
    # No {get,make,set}context support before Leopard
    args << "no-async" if MacOS.version == :tiger
    if Hardware::CPU.ppc?
      args << "darwin-ppc-cc"
    elsif Hardware::CPU.intel?
      args << (Hardware::CPU.is_64_bit? ? "darwin64-x86_64-cc enable-ec_nistp_64_gcc_128" : "darwin-i386-cc")
    end
    args
  end

  def install
    # Build breaks passing -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # Leopard and newer have the crypto framework
    ENV.append_to_cflags "-DOPENSSL_NO_APPLE_CRYPTO_RANDOM" if MacOS.version == :tiger

    # This could interfere with how we expect OpenSSL to build.
    ENV.delete("OPENSSL_LOCAL_CONFIG_DIR")

    # This ensures where Homebrew's Perl is needed the Cellar path isn't
    # hardcoded into OpenSSL's scripts, causing them to break every Perl update.
    # Whilst our env points to opt_bin, by default OpenSSL resolves the symlink.
    ENV["PERL"] = Formula["perl"].opt_bin/"perl" if which("perl") == Formula["perl"].opt_bin/"perl"

    openssldir.mkpath
    system "perl", "./Configure", *(configure_args)
    system "make"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
    system "make", "test"
  end

  def openssldir
    etc/"openssl@3"
  end

  def post_install
    rm_f openssldir/"cert.pem"
    openssldir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "cert.pem"
  end

  def caveats
    <<~EOS
      A CA file has been bootstrapped using certificates from the system
      keychain. To add additional certificates, place .pem files in
        #{openssldir}/certs

      and run
        #{opt_bin}/c_rehash
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate openssldir/"openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end