TERMUX_PKG_VERSION=8.43
TERMUX_PKG_SRCURL=https://ftp.pcre.org/pub/pcre/pcre-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=91e762520003013834ac1adb4a938d53b22a216341c061b0cf05603b290faf6b

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-cpp
--enable-jit
--enable-utf8
--enable-unicode-properties
"
