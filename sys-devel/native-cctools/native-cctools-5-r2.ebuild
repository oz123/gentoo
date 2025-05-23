# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="Host OS native assembler as and static linker ld"
HOMEPAGE="https://prefix.gentoo.org/"

LICENSE="GPL-2" # actually, we don't know, the wrapper is
SLOT="0"
KEYWORDS="~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"

DEPEND="sys-devel/binutils-config"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir -p "${S}"
}

src_install() {
	LIBPATH=/usr/$(get_libdir)/binutils/${CHOST}/native-${PV}
	BINPATH=/usr/${CHOST}/binutils-bin/native-${PV}

	keepdir ${LIBPATH} || die
	dodir ${BINPATH}

	# allow for future hosts with different paths
	nativepath=""
	case ${CHOST} in
		*-solaris*)
			nativepath=/usr/sfw/bin
		;;
		*-apple-darwin*)
			nativepath=/usr/bin
		;;
		*)
			die "Don't know where the native linker for your platform is"
		;;
	esac

	what="addr2line as ar c++filt gprof ld nm objcopy objdump \
		ranlib readelf elfdump size strings strip"
	# Darwin things
	what="${what} install_name_tool ld64 libtool lipo nmedit \
		otool otool64 pagestuff redo_prebinding segedit"

	# copy from the host os
	cd "${ED}${BINPATH}"
	for b in ${what} ; do
		if [[ ${CHOST} == *-darwin* && ${b} == libtool ]] ; then
			echo "linking darwin libtool ${nativepath}/${b}"
			ln -s "${nativepath}/${b}" "${b}"
		elif [[ -x ${nativepath}/g${b} ]] ; then
			einfo "linking ${nativepath}/g${b}"
			ln -s "${nativepath}/g${b}" "${b}"
		elif [[ -x ${nativepath}/${b} ]] ; then
			einfo "linking ${nativepath}/${b}"
			ln -s "${nativepath}/${b}" "${b}"
		else
			ewarn "skipping ${b} (not in ${nativepath})"
		fi
	done

	if [[ ${CHOST} == *-darwin* ]] ; then
		# on macOS Big Sur, all tools except ld require to be called
		# by their name, so just wrap everything from that point
		# before Big Sur, only ranlib doesn't like it when its called
		# other than that, as libtool and ranlib are one tool
		[[ ${CHOST##*-darwin} -lt 20 ]] && what="ranlib"
		for b in ${what} ; do
			[[ -L ${b} ]] || continue  # skip tools that don't exist
			rm -f ${b}
			cat <<-EOF > ${b}
				#!/usr/bin/env bash
				exec ${nativepath}/${b} "\$@"
			EOF
			chmod 755 ${b}
		done
	fi

	# Generate an env.d entry for this binutils
	insinto /etc/env.d/binutils
	cat <<-EOF > "${T}"/env.d
		TARGET="${CHOST}"
		VER="native-${PV}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${CHOST}"
	EOF
	newins "${T}"/env.d ${CHOST}-native-${PV}
}

pkg_postinst() {
	binutils-config ${CHOST}-native-${PV}
}
