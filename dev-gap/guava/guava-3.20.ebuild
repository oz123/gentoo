# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gap-pkg flag-o-matic toolchain-funcs

DESCRIPTION="GAP package for computing with error-correcting codes"
SRC_URI="https://github.com/gap-packages/${PN}/releases/download/v${PV}/${P}.tar.gz"
LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~riscv"

DEPEND="sci-mathematics/gap"

PATCHES=(
	"${FILESDIR}/${PN}-3.15-makefile.patch"
	"${FILESDIR}/${P}-testfix.patch"
)

GAP_PKG_EXTRA_INSTALL=( tbl )
gap-pkg_enable_tests

src_prepare() {
	# remove temporary files in src/leon
	rm src/leon/src/stamp-h1 || die
	default
}

src_configure() {
	# "false" conflicts with c23 bool type
	append-cflags -std=c17

	# This will run the top-level fake ./configure...
	gap-pkg_src_configure

	# Now run the real one in src/leon
	cd src/leon || die
	econf
}

src_compile() {
	# COMPILE, COMPOPT, LINKOPT are needed to compile the code in src/leon.
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		COMPILE="$(tc-getCC)" \
		COMPOPT="${CFLAGS} -c" \
		LINKOPT="${LDFLAGS}"
}
