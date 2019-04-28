TERMUX_PKG_VERSION=24
TERMUX_PKG_SKIP_SRC_EXTRACT=true

termux_step_make_install() {
	local sources="$TERMUX_PKG_BUILDER_DIR/sources/src/musl-*/*.c"

	"$CC" $CFLAGS -std=c99 -DNULL=0 $CPPFLAGS \
		-I"$TERMUX_PKG_BUILDER_DIR/sources/src/include" \
		-c $sources
	"$AR" rcs libandroid-support.a *.o

	install -Dm600 libandroid-support.a $TERMUX_PREFIX/lib/libandroid-support.a
	ln -sfr $TERMUX_PREFIX/lib/libandroid-support.a $TERMUX_PREFIX/lib/libiconv.a
}
