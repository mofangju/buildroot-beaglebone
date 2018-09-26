include $(sort $(wildcard $(BR2_EXTERNAL_LABS_PATH)/package/*/*.mk))

update-servers:
	sudo cp $(BINARIES_DIR)/am335x-boneblack.dtb /tftpboot/
	sudo cp $(BINARIES_DIR)/zImage /tftpboot/
	sudo rm -rf /rootfs/*
	sudo tar -C /rootfs -xf $(BINARIES_DIR)/rootfs.tar
