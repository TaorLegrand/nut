dnl Check for LIBUSB 1.0 or 0.1 compiler flags. On success, set
dnl nut_have_libusb="yes" and set LIBUSB_CFLAGS and LIBUSB_LIBS. On failure, set
dnl nut_have_libusb="no". This macro can be run multiple times, but will
dnl do the checking only once.

AC_DEFUN([NUT_CHECK_LIBUSB],
[
if test -z "${nut_have_libusb_seen}"; then
	nut_have_libusb_seen=yes

	dnl save CFLAGS and LIBS
	CFLAGS_ORIG="${CFLAGS}"
	LIBS_ORIG="${LIBS}"

	AC_MSG_CHECKING(for libusb version via pkg-config)
	LIBUSB_VERSION="`pkg-config --silence-errors --modversion libusb-1.0 2>/dev/null`"
	if test "$?" = "0" -a -n "${LIBUSB_VERSION}"; then
		CFLAGS="`pkg-config --silence-errors --cflags libusb-1.0 2>/dev/null`"
		LIBS="`pkg-config --silence-errors --libs libusb-1.0 2>/dev/null`"
		AC_DEFINE(WITH_LIBUSB_1_0, 1, [Define to 1 for version 1.0 of the libusb.])
		nut_usb_lib="(libusb-1.0)"
	else
		LIBUSB_VERSION="`pkg-config --silence-errors --modversion libusb 2>/dev/null`"
		if test "$?" = "0" -a -n "${LIBUSB_VERSION}"; then
			CFLAGS="`pkg-config --silence-errors --cflags libusb 2>/dev/null`"
			LIBS="`pkg-config --silence-errors --libs libusb 2>/dev/null`"
			AC_DEFINE(WITH_LIBUSB_0_1, 1, [Define to 1 for version 0.1 of the libusb.])
			nut_usb_lib="(libusb-0.1)"
		else
			AC_MSG_CHECKING(via libusb-config)
			LIBUSB_VERSION="`libusb-config --version 2>/dev/null`"
			if test "$?" = "0" -a -n "${LIBUSB_VERSION}"; then
				CFLAGS="`libusb-config --cflags 2>/dev/null`"
				LIBS="`libusb-config --libs 2>/dev/null`"
				AC_DEFINE(HAVE_LIBUSB_0_1, 1, [Define to 1 for version 0.1 of the libusb.])
				nut_usb_lib="(libusb-0.1)"
			else
				LIBUSB_VERSION="none"
				CFLAGS=""
				LIBS="-lusb"
			fi
		fi
	fi
	AC_MSG_RESULT(${LIBUSB_VERSION} found)

	AC_MSG_CHECKING(for libusb cflags)
	AC_ARG_WITH(usb-includes,
		AS_HELP_STRING([@<:@--with-usb-includes=CFLAGS@:>@], [include flags for the libusb library]),
	[
		case "${withval}" in
		yes|no)
			AC_MSG_ERROR(invalid option --with(out)-usb-includes - see docs/configure.txt)
			;;
		*)
			CFLAGS="${withval}"
			;;
		esac
	], [])
	AC_MSG_RESULT([${CFLAGS}])

	AC_MSG_CHECKING(for libusb ldflags)
	AC_ARG_WITH(usb-libs,
		AS_HELP_STRING([@<:@--with-usb-libs=LIBS@:>@], [linker flags for the libusb library]),
	[
		case "${withval}" in
		yes|no)
			AC_MSG_ERROR(invalid option --with(out)-usb-libs - see docs/configure.txt)
			;;
		*)
			LIBS="${withval}"
			;;
		esac
	], [])
	AC_MSG_RESULT([${LIBS}])

	dnl check if libusb is usable
	if test -n "${LIBUSB_VERSION}"; then
		pkg-config --silence-errors --atleast-version=1.0 libusb-1.0 2>/dev/null
		if test "$?" = "0"; then
			AC_CHECK_HEADERS(libusb.h, [nut_have_libusb=yes], [nut_have_libusb=no], [AC_INCLUDES_DEFAULT])
			AC_CHECK_FUNCS(libusb_init, [], [nut_have_libusb=no])
			dnl Check for libusb "force driver unbind" availability
			AC_CHECK_FUNCS(libusb_detach_kernel_driver)
		else
			AC_CHECK_HEADERS(usb.h, [nut_have_libusb=yes], [nut_have_libusb=no], [AC_INCLUDES_DEFAULT])
			AC_CHECK_FUNCS(usb_init, [], [nut_have_libusb=no])
			dnl Check for libusb "force driver unbind" availability
			AC_CHECK_FUNCS(usb_detach_kernel_driver_np)
		fi
	else
		nut_have_libusb=no
	fi

	if test "${nut_have_libusb}" = "yes"; then
		LIBUSB_CFLAGS="${CFLAGS}"
		LIBUSB_LIBS="${LIBS}"
	fi

	dnl restore original CFLAGS and LIBS
	CFLAGS="${CFLAGS_ORIG}"
	LIBS="${LIBS_ORIG}"
fi
])
