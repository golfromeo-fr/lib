# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

# default values

setenv rootdev "/dev/mmcblk0p1"
setenv verbosity "1"
setenv console "both"
setenv disp_mem_reserves "off"
setenv disp_mode "720p60"
setenv rootfstype "ext4"
setenv camera_type "none"

if ext4load mmc 0 ${load_addr} /boot/armbianEnv.txt || fatload mmc 0 ${load_addr} armbianEnv.txt || ext4load mmc 0 ${load_addr} armbianEnv.txt; then
	env import -t ${load_addr} ${filesize}
fi

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "${consoleargs} console=ttyS0,115200n8"; fi

setenv bootargs "root=${rootdev} rootfstype=${rootfstype} rootwait ${consoleargs} no_console_suspend earlycon=uart,mmio32,0x01c28000 mac_addr=${ethaddr} panic=10 consoleblank=0 enforcing=0 loglevel=${verbosity} ${extraargs} ${extraboardargs}"

ext4load mmc 0 ${fdt_addr} /boot/${pine64_model}.dtb || fatload mmc 0 ${fdt_addr} ${pine64_model}.dtb || ext4load mmc 0 ${fdt_addr} ${pine64_model}.dtb
ext4load mmc 0 ${initrd_addr} /boot/uInitrd || fatload mmc 0 ${initrd_addr} uInitrd || ext4load mmc 0 ${initrd_addr} uInitrd
ext4load mmc 0 ${kernel_addr} /boot/Image || fatload mmc 0 ${kernel_addr} Image || ext4load mmc 0 ${kernel_addr} Image

# set display resolution from uEnv.txt or other environment file
# default to 720p60
if test "${disp_mode}" = "480i"; then setenv fdt_disp_mode "<0x00000000>"
elif test "${disp_mode}" = "576i"; then setenv fdt_disp_mode "<0x00000001>"
elif test "${disp_mode}" = "480p"; then setenv fdt_disp_mode "<0x00000002>"
elif test "${disp_mode}" = "576p"; then setenv fdt_disp_mode "<0x00000003>"
elif test "${disp_mode}" = "720p50"; then setenv fdt_disp_mode "<0x00000004>"
elif test "${disp_mode}" = "720p60"; then setenv fdt_disp_mode "<0x00000005>"
elif test "${disp_mode}" = "1080i50"; then setenv fdt_disp_mode "<0x00000006>"
elif test "${disp_mode}" = "1080i60"; then setenv fdt_disp_mode "<0x00000007>"
elif test "${disp_mode}" = "1080p24"; then setenv fdt_disp_mode "<0x00000008>"
elif test "${disp_mode}" = "1080p50"; then setenv fdt_disp_mode "<0x00000009>"
elif test "${disp_mode}" = "1080p60"; then setenv fdt_disp_mode "<0x0000000a>"
elif test "${disp_mode}" = "2160p30"; then setenv fdt_disp_mode "<0x0000001c>"
elif test "${disp_mode}" = "2160p25"; then setenv fdt_disp_mode "<0x0000001d>"
elif test "${disp_mode}" = "2160p24"; then setenv fdt_disp_mode "<0x0000001e>"
else setenv fdt_disp_mode "<0x00000005>"
fi

fdt addr ${fdt_addr}
fdt resize
fdt set /soc@01c00000/disp@01000000 screen0_output_mode ${fdt_disp_mode}
#fdt set /soc@01c00000/disp@01000000 screen1_output_mode ${fdt_disp_mode}

# DVI compatibility
if test ${disp_dvi_compat} = 1 || test ${disp_dvi_compat} = on; then
	fdt set /soc@01c00000/hdmi@01ee0000 hdmi_hdcp_enable "<0x00000000>"
	fdt set /soc@01c00000/hdmi@01ee0000 hdmi_cts_compatibility "<0x00000001>"
fi

if test "${disp_mem_reserves}" = "off"; then
	# TODO: Remove reserved memory from DT or disable devices?
fi

# default, only set status
if test "${camera_type}" = "s5k4ec"; then
	fdt set /soc@01c00000/vfe@0/ status "okay"
	fdt set /soc@01c00000/vfe@0/dev@0/ status "okay"
fi

# change name, i2c address and vdd voltage
if test "${camera_type}" = "ov5640"; then
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_mname "ov5640"
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_twi_addr "<0x00000078>"
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_iovdd_vol "<0x001b7740>"
	fdt set /soc@01c00000/vfe@0/ status "okay"
	fdt set /soc@01c00000/vfe@0/dev@0/ status "okay"
fi

booti ${kernel_addr} ${initrd_addr} ${fdt_addr}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
