// Requires passing psg_win_x64.dll to gcc and placing it in the same dir
#include "../mmltest/psg.h"

#include <windows.h>

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


const int BUF_SIZE = 3030; // len of frame plus cnt of \n (they're ignored)
const int FRAME_LEN = 3000;
const int BEGIN_VID = 2000;
const int NUM_FRAMES = 360;

const int frame_time = 100;


int main () {
    // this file was taken from https://github.com/Chion82/ASCII_bad_apple with small changes
    FILE *f_in = fopen ("play.txt", "r");

    // algorithm relies on zeroes at the end, so don't change to malloc
    char *buffer = (char*) calloc (BUF_SIZE + 100, sizeof (char));

    
    PSG_SetMasterVolume (1);

    for (int frame = 0; frame < NUM_FRAMES; frame++) {
        fread (buffer, 1, BUF_SIZE, f_in);

        puts(buffer);

        Sleep(frame_time);

        
        if (!PSG_IsPlayingMML ())
            PSG_PlayMML(
                "V110 bargf+gf+<b r1 > bargf+gf+<b r1 > bargf+gf+<b > r1 r1 r1",
                "grgrf+rf+ererere16r16er	grgrf+rf+erergrg 16r16gr" "grgrf+rf+ererere16r16er	l16 grgrg8r8grg8r8g8 > d+rd+rd+8r8d+rd+8r8d+8 < ",
                "bab>ef+r<b>ef+r<b>f+greb a16r16r g16r16r f+re>drd16r16d16r16dr<b16r16b&b16r16< G	bab>ef+r<b>ef+<b16r16b>>d16r16drd<b  rbargf+re l16 f+rf+rf+rerf+rrrg8er",
                "");
    }

    free (buffer);

    fclose (f_in);

    while (PSG_IsPlayingMML ())
        Sleep (500); // sleep and wait
    PSG_Terminate ();
}

