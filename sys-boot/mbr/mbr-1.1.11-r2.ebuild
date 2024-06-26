# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A replacement master boot record for IBM-PC compatible computers"
HOMEPAGE="https://www.chiark.greenend.org.uk/~neilt/mbr/"
SRC_URI="https://www.chiark.greenend.org.uk/~neilt/mbr/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="sys-devel/bin86"
BDEPEND="test? ( dev-vcs/rcs )"

src_prepare() {
	# do not treat warnings as errors
	sed -i -e "s: -Werror::" {,harness/}Makefile.{in,am} || die
	default
}

src_install() {
	dosbin install-mbr
	doman install-mbr.8
	dodoc AUTHORS ChangeLog install-mbr.8 NEWS README TODO
}

pkg_postinst() {
	elog "To install the MBR, run /sbin/install-mbr"
}
