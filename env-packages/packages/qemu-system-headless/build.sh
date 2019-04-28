TERMUX_PKG_VERSION=4.0.0
TERMUX_PKG_SRCURL=https://download.qemu.org/qemu-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=13a93dfe75b86734326f8d5b475fde82ec692d5b5a338b4262aeeb6b0fa4e469
TERMUX_PKG_DEPENDS="attr, glib, libcap, libpixman, zlib"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
	./configure \
		--prefix="${TERMUX_PREFIX}" \
		--cross-prefix="${TERMUX_HOST_PLATFORM}-" \
		--host-cc="gcc" \
		--cc="${CC}" \
		--cxx="${CXX}" \
		--objcc="${CC}" \
		--extra-ldflags="${LDFLAGS} -lm" \
		--disable-curses \
		--disable-iconv \
		--enable-vnc \
		--enable-coroutine-pool \
		--enable-virtfs \
		--enable-trace-backends=nop \
		--disable-hax \
		--disable-kvm \
		--disable-xen \
		--disable-fdt \
		--disable-guest-agent \
		--disable-stack-protector \
		--disable-cloop \
		--disable-dmg \
		--disable-parallels \
		--disable-qed \
		--disable-sheepdog \
		--target-list=x86_64-softmmu
}

termux_step_post_make_install() {
	local bindir

	case "$TERMUX_ARCH" in
		aarch64) bindir="arm64-v8a";;
		arm) bindir="armeabi-v7a";;
		i686) bindir="x86";;
		x86_64) bindir="x86_64";;
		*) echo "Invalid architecture '$TERMUX_ARCH'" && return 1;;
	esac

	install -Dm700 "$TERMUX_PREFIX"/bin/qemu-system-x86_64 \
		"${TERMUX_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
	"$STRIP" -s "${TERMUX_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
}
