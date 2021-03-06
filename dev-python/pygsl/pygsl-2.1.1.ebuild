# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

inherit distutils-r1

DESCRIPTION="Python interface for the GNU scientific library (gsl)"
HOMEPAGE="http://pygsl.sourceforge.net/"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${P}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="examples"

DEPEND="
	<sci-libs/gsl-2
	dev-python/numpy[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
# Testsuite written to be run post install

python_install_all() {
	use examples && dodoc -r examples
	distutils-r1_python_install_all
}
