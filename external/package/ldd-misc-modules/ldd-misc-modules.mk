LDD_MISC_MODULES_MODULE_VERSION = 1.0
LDD_MISC_MODULES_SITE = $(TOPDIR)/../custom-app/ldd/misc-modules
LDD_MISC_MODULES_SITE_METHOD = local
LDD_MISC_MODULES_LICENSE = GPLv2
LDD_MISC_MODULES_LICENSE_FILES = COPYING

$(eval $(kernel-module))
$(eval $(generic-package))
