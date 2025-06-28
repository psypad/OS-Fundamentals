run after make using 
qemu-system-x86_64 -hda ./boot.bin 


to debug:

open gdb,
target remote | qemu-system-x86_64 -hda ./boot.bin -s -gdb stdio