
#include "E:\WindowsFolders\Desktop\prog\TX\TXLib.h"
#include <emmintrin.h>

#include <chrono>

//-------------------------------------------------------------------------------------------------

const char I = 255u, Z = 0x80u;
           
const __m128i   _0 =                    _mm_set_epi8 (0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);
const __m128i _255 = _mm_cvtepi8_epi16 (_mm_set_epi8 (I,I,I,I, I,I,I,I, I,I,I,I, I,I,I,I));

const char *FRONT_NAME = "racket.bmp";
const char *BACK_NAME = "Table.bmp";

const int WIDTH = 800;
const int HEIGHT = 600;

const int LOOP_CNT = 100;

typedef RGBQUAD (&scr_t) [HEIGHT][WIDTH];

//-------------------------------------------------------------------------------------------------

inline scr_t LoadImage (const char* filename, HDC *dc);

void blend_images (scr_t front, scr_t back, scr_t scr);

//-------------------------------------------------------------------------------------------------

int main() {
    txCreateWindow (WIDTH, HEIGHT);
    Win32::_fpreset();
    txBegin();

    HDC dcfr, dcbk;
    scr_t front = (scr_t) LoadImage (FRONT_NAME, &dcfr);
    scr_t back  = (scr_t) LoadImage (BACK_NAME, &dcbk);
    scr_t scr   = (scr_t) *txVideoMemory();

    while (1) {
        if (GetAsyncKeyState (VK_ESCAPE)) break;

        auto start = std::chrono::steady_clock::now();
        for (int i = 0; i < LOOP_CNT; i++)
            blend_images (front, back, scr);
        
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds> 
                            (std::chrono::steady_clock::now() - start);
        double fps = 1000. * LOOP_CNT / elapsed.count();
        
        //printf("time is %lld\n", elapsed.count());
        printf("fps is %.0f\n", fps);

        txUpdateWindow();
    }

    txDeleteDC (dcfr);
    txDeleteDC (dcbk);

    txDisableAutoPause();
}

void blend_images (scr_t front, scr_t back, scr_t scr) {
    for (int y = 0; y < HEIGHT; y++) 
    for (int x = 0; x < 800; x++) {
        RGBQUAD* fr = &front[y][x];
        RGBQUAD* bk = &back [y][x];
        
        uint16_t a  = fr->rgbReserved;

        scr[y][x]   = { (BYTE) ( (fr->rgbBlue  * (a) + bk->rgbBlue  * (255-a)) >> 8 ),
                        (BYTE) ( (fr->rgbGreen * (a) + bk->rgbGreen * (255-a)) >> 8 ),
                        (BYTE) ( (fr->rgbRed   * (a) + bk->rgbRed   * (255-a)) >> 8 ) };
    }
}

inline scr_t LoadImage (const char* filename, HDC *dc) {
    RGBQUAD* mem = NULL;
    *dc = txCreateDIBSection (WIDTH, HEIGHT, &mem);
    txBitBlt (*dc, 0, 0, 0, 0, *dc, 0, 0, BLACKNESS);

    HDC image = txLoadImage (filename);
    txBitBlt (*dc, (txGetExtentX (*dc) - txGetExtentX (image)) / 2, 
                  (txGetExtentY (*dc) - txGetExtentY (image)) / 2, 0, 0, image);
    txDeleteDC (image);

    return (scr_t) *mem;
}
    