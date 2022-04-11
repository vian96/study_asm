#include <windows.h>
#include "psg.h"
#include "song.h"

int main() {
    PSG_SetMasterVolume (1);
    PSG_PlayMML(
                "V110 bargf+gf+<b r1 > bargf+gf+<b r1 > bargf+gf+<b > r1 r1 r1",
                "grgrf+rf+ererere16r16er	grgrf+rf+erergrg 16r16gr" "grgrf+rf+ererere16r16er	l16 grgrg8r8grg8r8g8 > d+rd+rd+8r8d+rd+8r8d+8 < ",
                "bab>ef+r<b>ef+r<b>f+greb a16r16r g16r16r f+re>drd16r16d16r16dr<b16r16b&b16r16< G	bab>ef+r<b>ef+<b16r16b>>d16r16drd<b  rbargf+re l16 f+rf+rf+rerf+rrrg8er",
                "");
    while (PSG_IsPlayingMML ())
        Sleep (500); // sleep and wait
    PSG_Terminate ();
}
