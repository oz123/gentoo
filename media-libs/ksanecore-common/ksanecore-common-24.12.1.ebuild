# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_HANDBOOK="false"
KDE_ORG_NAME="${PN/-common/}"
inherit ecm-common gear.kde.org

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND="
	!<media-libs/ksanecore-23.08.5-r2:5
	!<media-libs/ksanecore-24.05.2-r1:6
"
