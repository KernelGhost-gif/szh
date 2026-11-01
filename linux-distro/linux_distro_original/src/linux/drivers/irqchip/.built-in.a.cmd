savedcmd_drivers/irqchip/built-in.a := rm -f drivers/irqchip/built-in.a;  printf "drivers/irqchip/%s " irq-msi-lib.o | xargs ar cDPrST drivers/irqchip/built-in.a
