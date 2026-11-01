savedcmd_net/ipv4/netfilter/built-in.a := rm -f net/ipv4/netfilter/built-in.a;  printf "net/ipv4/netfilter/%s " nf_defrag_ipv4.o | xargs ar cDPrST net/ipv4/netfilter/built-in.a
