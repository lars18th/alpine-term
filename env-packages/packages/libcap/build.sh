TERMUX_PKG_VERSION=2.27
TERMUX_PKG_SRCURL=https://kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=dac1792d0118bee6aae6ba7fb93ff1602c6a9bda812fd63916eee1435b9c486a
TERMUX_PKG_DEPENDS="attr"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_make() {
	make BUILD_CC=gcc CC="$CC" PREFIX="$TERMUX_PREFIX"
}

termux_step_make_install() {
	make BUILD_CC=gcc CC="$CC" prefix="$TERMUX_PREFIX" RAISE_SETFCAP=no lib=/lib install
}
