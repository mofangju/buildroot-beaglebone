LDD_SCULL_MODULE_VERSION = 1.0
LDD_SCULL_SITE = $(TOPDIR)/../custom-app/ldd/scull
LDD_SCULL_SITE_METHOD = local
LDD_SCULL_LICENSE = GPLv2
LDD_SCULL_LICENSE_FILES = COPYING

define LDD_SCULL_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/scull_load $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/scull_load
	$(INSTALL) -m 0755 -D $(@D)/scull_unload $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/scull_unload
endef

$(eval $(kernel-module))
$(eval $(generic-package))
