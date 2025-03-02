# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.sr.ht/~exec64/imv/"
else
	SRC_URI="https://git.sr.ht/~exec64/imv/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-v${PV}"
	KEYWORDS="amd64 x86"
fi

DESCRIPTION="Minimal image viewer designed for tiling window manager users"
HOMEPAGE="https://sr.ht/~exec64/imv/"

LICENSE="MIT-with-advertising"
SLOT="0"
IUSE="+X +freeimage gif heif jpeg png svg test tiff wayland"
REQUIRED_USE="|| ( X wayland )"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/glib:2
	dev-libs/icu:=
	dev-libs/inih
	virtual/opengl
	x11-libs/cairo
	x11-libs/libxkbcommon[X?]
	x11-libs/pango
	X? (
		x11-libs/libX11
		x11-libs/libxcb:=
	)
	freeimage? ( media-libs/freeimage )
	gif? ( media-libs/libnsgif )
	heif? ( media-libs/libheif:= )
	jpeg? ( media-libs/libjpeg-turbo:= )
	png? ( media-libs/libpng:= )
	svg? ( >=gnome-base/librsvg-2.44:2 )
	tiff? ( media-libs/tiff )
	wayland? ( dev-libs/wayland )
	!sys-apps/renameutils"
DEPEND="
	${RDEPEND}
	X? ( x11-base/xorg-proto )
	test? ( dev-util/cmocka )"
BDEPEND="
	app-text/asciidoc
	wayland? ( dev-util/wayland-scanner )"

src_prepare() {
	default

	# if wayland-only, don't automagic on libGL and force libOpenGL
	if ! use X; then
		sed -i "/dependency('gl'/{s/'gl'/'opengl'/;s/false/true/}" meson.build || die
	fi

	# glu isn't used by anything
	sed -i "/dependency('glu')/d" meson.build || die
}

src_configure() {
	local emesonargs=(
		$(meson_feature freeimage)
		$(meson_feature gif libnsgif)
		$(meson_feature heif libheif)
		$(meson_feature jpeg libjpeg)
		$(meson_feature png libpng)
		$(meson_feature svg librsvg)
		$(meson_feature test)
		$(meson_feature tiff libtiff)
		-Dwindows=$(usex X $(usex wayland all x11) wayland)
	)

	meson_src_configure
}
