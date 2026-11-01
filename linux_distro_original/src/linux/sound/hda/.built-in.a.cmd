savedcmd_sound/hda/built-in.a := rm -f sound/hda/built-in.a;  printf "sound/hda/%s " core/built-in.a common/built-in.a codecs/built-in.a controllers/built-in.a | xargs ar cDPrST sound/hda/built-in.a
