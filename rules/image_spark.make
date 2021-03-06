# -*-makefile-*-
#
# Copyright (C) 2003-2010 by the ptxdist project <ptxdist@pengutronix.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

SEL_ROOTFS-$(PTXCONF_IMAGE_SPARK)	+= $(IMAGEDIR)/e2jffs2.img

ifdef PTXCONF_IMAGE_SPARK

$(STATEDIR)/image_working_dir_prepared:
	@echo -n "Preparing... "
	@cd $(IMAGEDIR);	\
	((			\
		echo ""		\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) -s $(STATEDIR)/image_working_dir_prepared --
	
	@echo "done."

# $MKFSJFFS2 -qUfv -e0x20000 -r $TMPROOTDIR -o $CURDIR/mtd_root.bin
$(IMAGEDIR)/mtd_root.bin: $(STATEDIR)/image_working_dir_prepared $(STATEDIR)/host-mtd-utils.install.post
	@echo -n "Creating mtd_root.bin from working dir... "
	@cd $(image/work_dir);									\
	(awk -F: $(DOPERMISSIONS) $(image/permissions) &&		\
	(														\
		echo -n "$(PTXCONF_SYSROOT_HOST)/sbin/mkfs.jffs2 ";	\
		echo -n "-qnUf -e0x20000 ";							\
		echo  "-o $@";										\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) -i $(STATEDIR)/image_working_dir_prepared --
	@echo "done."

#$SUMTOOL -v -p -e 0x20000 -i $CURDIR/mtd_root.bin -o $CURDIR/mtd_root.sum.bin
$(IMAGEDIR)/mtd_root.sum.bin: $(IMAGEDIR)/mtd_root.bin
	@echo -n "Creating mtd_root.sum.jffs2 with summary... "
	@cd $(image/work_dir);									\
	((														\
		echo -n "$(PTXCONF_SYSROOT_HOST)/sbin/sumtool ";	\
		echo -n "-i $< ";									\
		echo -n "-p -e 0x20000 ";							\
		echo "-o $@";										\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) -i $(STATEDIR)/image_working_dir_prepared --
	@echo "done."

$(IMAGEDIR)/uImage: $(IMAGEDIR)/linuximage
	@echo -n "Creating uImage.bin... "
	@cd $(IMAGEDIR);											\
	((															\
		echo "mv -f $(IMAGEDIR)/linuximage $(IMAGEDIR)/uImage";	\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) --
	@echo "done."


#$(IMAGEDIR)
$(IMAGEDIR)/e2jffs2.img: $(STATEDIR)/image_working_dir \
                         $(IMAGEDIR)/mtd_root.sum.bin  \
                         $(IMAGEDIR)/mtd_root.bin \
                         $(IMAGEDIR)/uImage
	@echo -n "Creating e2jffs2.img... "
	@cd $(IMAGEDIR);														\
	((																		\
		echo "mv -f $(IMAGEDIR)/mtd_root.sum.bin $(IMAGEDIR)/e2jffs2.img";	\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) --
	@echo "done."
	
	@echo -n "Cleaning image work_dir and files... "
	@cd $(IMAGEDIR);												\
	((																\
		echo -n "rm -rf  ";											\
		echo -n "       $(IMAGEDIR)/linuximage ";					\
		echo -n "       $(IMAGEDIR)/mtd_root.bin ";					\
		echo -n "       $(STATEDIR)/image_working_dir ";			\
		echo -n "       $(STATEDIR)/image_working_dir_prepared ";	\
		echo "          $@.cfg";									\
	) | tee -a "$(PTX_LOGFILE)") | $(FAKEROOT) --
	@echo "done."
	
	@echo "-----------------------------------------------------------------------"
	@echo "To flash the created image copy the "
	@echo "`basename $@` "
	@echo "file to your usb drive in the subfolder /$(PTXCONF_PLATFORM)/"

endif

# vim600:set foldmethod=marker:
# vim600:set syntax=make:
