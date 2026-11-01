savedcmd_sound/hda/controllers/built-in.a := rm -f sound/hda/controllers/built-in.a;  printf "sound/hda/controllers/%s " intel.o | xargs ar cDPrST sound/hda/controllers/built-in.a
