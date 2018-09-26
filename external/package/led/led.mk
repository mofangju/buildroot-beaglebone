LED_MODULE_VERSION = 1.0
LED_SITE = $(TOPDIR)/../custom-app/led/button
LED_SITE_METHOD = local
LED_LICENSE = GPLv2
LED_LICENSE_FILES = COPYING

$(eval $(kernel-module))
$(eval $(generic-package))
