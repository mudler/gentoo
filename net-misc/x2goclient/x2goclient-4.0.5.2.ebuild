# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit nsplugins qmake-utils

DESCRIPTION="The X2Go Qt client"
HOMEPAGE="http://www.x2go.org"
SRC_URI="http://code.x2go.org/releases/source/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ldap nsplugin +qt4 qt5"

REQUIRED_USE="^^ ( qt4 qt5 )"

DEPEND=">=net-libs/libssh-0.6.0_rc1
	net-print/cups
	x11-libs/libXpm
	ldap? ( net-nds/openldap )
	qt4? (
		dev-qt/qtcore:4[ssl]
		dev-qt/qtgui:4
		dev-qt/qtsvg:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5[ssl]
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
	)"

RDEPEND="${DEPEND}
	net-misc/nx"

CLIENT_BUILD=${WORKDIR}/${P}.client_build
PLUGIN_BUILD=${WORKDIR}/${P}.plugin_build

PATCHES=( "${FILESDIR}"/${P}-rcc_to_qrc.patch )

src_prepare() {
	if ! use ldap; then
		sed -e "s/-lldap//" -i x2goclient.pro || die
		sed -e "s/#define USELDAP//" -i src/x2goclientconfig.h || die
	fi

	mkdir -p "${CLIENT_BUILD}"
	use nsplugin && mkdir -p "${PLUGIN_BUILD}"

	default
}

src_configure() {
	local EQMAKE
	use qt4 && EQMAKE=eqmake4
	use qt5 && EQMAKE=eqmake5

	cd "${CLIENT_BUILD}"
	${EQMAKE} "${S}"/x2goclient.pro

	if use nsplugin;
	then
		cd "${PLUGIN_BUILD}"
		X2GO_CLIENT_TARGET=plugin ${EQMAKE} "${S}"/x2goclient.pro
	fi
}

src_compile() {
	cd "${CLIENT_BUILD}"
	emake

	if use nsplugin;
	then
		cd "${PLUGIN_BUILD}"
		emake
	fi
}

src_install() {
	dobin "${CLIENT_BUILD}"/${PN}

	insinto /usr/share/pixmaps/x2goclient
	doins res/img/icons/${PN}.xpm

	domenu desktop/${PN}.desktop
	doman man/man?/*

	if use nsplugin;
	then
		# PLUGINS_DIR comes from nsplugins.eclass
		exeinto /usr/$(get_libdir)/${PLUGINS_DIR}
		doexe "${PLUGIN_BUILD}"/libx2goplugin.so
	fi

	emake DESTDIR="${D}" PREFIX=/usr install_pluginprovider
}
