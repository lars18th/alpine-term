PACKAGE_VERSION="4.1.1"
#PACKAGE_VERSION="4.2.0"
PACKAGE_SRCURL="https://download.qemu.org/qemu-${PACKAGE_VERSION}.tar.xz"
PACKAGE_SHA256="ed6fdbbdd272611446ff8036991e9b9f04a2ab2e3ffa9e79f3bab0eb9a95a1d2"
#PACKAGE_SHA256="d3481d4108ce211a053ef15be69af1bdd9dde1510fda80d92be0f6c3e98768f0"
PACKAGE_DEPENDS="curl, glib, libjpeg-turbo, libpng, lzo, pixman, snappy, zlib"
PACKAGE_BUILD_IN_SRC="true"

builder_step_configure() {
	CFLAGS+=" $CPPFLAGS"
	CXXFLAGS+=" $CPPFLAGS"

	./configure \
		--prefix="$PACKAGE_INSTALL_PREFIX" \
		--cross-prefix="${PACKAGE_TARGET_PLATFORM}-" \
		--host-cc="gcc" \
		--cc="$CC" \
		--cxx="$CXX" \
		--objcc="$CC" \
		--disable-curses \
		--disable-iconv \
		--enable-vnc \
		--enable-vnc-jpeg \
		--enable-vnc-png \
		--enable-lzo \
		--enable-snappy \
		--enable-curl \
		--enable-coroutine-pool \
		--enable-virtfs \
		--enable-trace-backends=nop \
		--disable-hax \
		--disable-kvm \
		--disable-xen \
		--disable-fdt \
		--disable-guest-agent \
		--disable-stack-protector \
		--disable-bochs \
		--disable-cloop \
		--disable-dmg \
		--disable-parallels \
		--disable-qed \
		--disable-sheepdog \
		--target-list=x86_64-softmmu
}

builder_step_post_make_install() {
	local bindir

	case "$PACKAGE_TARGET_ARCH" in
		aarch64) bindir="arm64-v8a";;
		arm) bindir="armeabi-v7a";;
		i686) bindir="x86";;
		x86_64) bindir="x86_64";;
		*) echo "Invalid architecture '$PACKAGE_TARGET_ARCH'" && return 1;;
	esac

	install -Dm700 "$PACKAGE_INSTALL_PREFIX"/bin/qemu-system-x86_64 \
		"${BUILDER_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
	"$STRIP" -s "${BUILDER_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
}
