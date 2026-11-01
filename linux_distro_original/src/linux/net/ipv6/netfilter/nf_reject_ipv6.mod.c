#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.arch = MODULE_ARCH_INIT,
};

MODULE_INFO(intree, "Y");

KSYMTAB_FUNC(nf_reject_skb_v6_tcp_reset, "_gpl", "");
KSYMTAB_FUNC(nf_reject_skb_v6_unreach, "_gpl", "");
KSYMTAB_FUNC(nf_send_reset6, "_gpl", "");
KSYMTAB_FUNC(nf_send_unreach6, "_gpl", "");

MODULE_INFO(depends, "");

