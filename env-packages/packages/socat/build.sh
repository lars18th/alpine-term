TERMUX_PKG_VERSION=1.7.3.3
TERMUX_PKG_SRCURL=http://www.dest-unreach.org/socat/download/socat-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=8cc0eaee73e646001c64adaab3e496ed20d4d729aaaf939df2a761e99c674372
TERMUX_PKG_BUILD_IN_SRC=yes

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-exec
--disable-openssl
--disable-system
ac_header_resolv_h=no
ac_cv_c_compiler_gnu=yes
ac_compiler_gnu=yes
"

termux_step_post_make_install() {
	local bindir

	case "$TERMUX_ARCH" in
		aarch64) bindir="arm64-v8a";;
		arm) bindir="armeabi-v7a";;
		i686) bindir="x86";;
		x86_64) bindir="x86_64";;
		*) echo "Invalid architecture '$TERMUX_ARCH'" && return 1;;
	esac

	install -Dm700 "$TERMUX_PREFIX"/bin/socat \
		"${TERMUX_SCRIPTDIR}/jniLibs/${bindir}/libsocat.so"
	"$STRIP" -s "${TERMUX_SCRIPTDIR}/jniLibs/${bindir}/libsocat.so"
}
