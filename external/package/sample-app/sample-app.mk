SAMPLE_APP_VERSION = 1.0
SAMPLE_APP_SITE = $(TOPDIR)/../custom-app/sample-app
SAMPLE_APP_SITE_METHOD = local
SAMPLE_APP_LICENSE = GPLv2
SAMPLE_APP_LICENSE_FILES = COPYING

define SAMPLE_APP_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(@D) 
endef
 
define SAMPLE_APP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/sample-app $(TARGET_DIR)/usr/bin/sample-app
endef
 
$(eval $(generic-package))
