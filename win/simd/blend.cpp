
#include "E:\WindowsFolders\Desktop\prog\TX\TXLib.h"
#include <emmintrin.h>

#include <chrono>

//-------------------------------------------------------------------------------------------------

const char I = 255u, Z = 0x80u;
           
const __m128i   _0 =                    _mm_set_epi8 (0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);
const __m128i _255 = _mm_cvtepu8_epi16 (_mm_set_epi8 (I,I,I,I, I,I,I,I, I,I,I,I, I,I,I,I));

const char *FRONT_NAME = "racket.bmp";
const char *BACK_NAME = "table.bmp";

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
    for (int x = 0; x < WIDTH; x += 4) {
        // load from memory to regs
        __m128i fr = _mm_lddqu_si128 ((__m128i*) &front[y][x]);                
        __m128i bk = _mm_lddqu_si128 ((__m128i*) &back [y][x]);

        //__m128i mov = _mm_set_epi8 (12,13,14,15, 8,9,10,11, 4,5,6,7, 0,1,2,3);
        //__m128i mov = _mm_set_epi8 (14,15,13,12, 10,11,9,8, 6,7,5,4, 2,3,1,0);

        //fr = _mm_shuffle_epi8 (fr, mov);
        //bk = _mm_shuffle_epi8 (bk, mov);


       /* __m128i fr = _mm_set_epi32 (*(int*)&front[y][x], *(int*)&front[y][x+1], 
                                    *(int*)&front[y][x+2], *(int*)&front[y][x+3]);

        __m128i bk = _mm_set_epi32 (*(int*)&back[y][x], *(int*)&back[y][x+1], 
                                    *(int*)&back[y][x+2], *(int*)&back[y][x+3]);
*/
        // choose only high bytes since we need free places
        __m128i FR = (__m128i) _mm_movehl_ps ((__m128) _0, (__m128) fr);       
        __m128i BK = (__m128i) _mm_movehl_ps ((__m128) _0, (__m128) bk);

        // space them so you we can freely calculate
        fr = _mm_cvtepi8_epi16 (fr);                                            
        FR = _mm_cvtepi8_epi16 (FR);

        bk = _mm_cvtepi8_epi16 (bk);
        BK = _mm_cvtepi8_epi16 (BK);

        // prepare multiplier for analog
        static const __m128i moveA = _mm_set_epi8 (Z, 14, Z, 14, Z, 14, Z, 14,
                                                    Z, 6, Z, 6, Z, 6, Z, 6);
        __m128i a = _mm_shuffle_epi8 (fr, moveA);                               
        __m128i A = _mm_shuffle_epi8 (FR, moveA);
        
        // calculate foreground picture
        fr = _mm_mullo_epi16 (fr, a);                                           
        FR = _mm_mullo_epi16 (FR, A);

        // calculate background picture
        bk = _mm_mullo_epi16 (bk, _mm_sub_epi16 (_255, a));                          
        BK = _mm_mullo_epi16 (BK, _mm_sub_epi16 (_255, A));

        // add them up
        __m128i sum = _mm_add_epi16 (fr, bk);                                       
        __m128i SUM = _mm_add_epi16 (FR, BK);

        // leave unused bytes
        static const __m128i moveSum = _mm_set_epi8 (Z, Z, Z, Z, Z, Z, Z, Z, 
                                                        15, 13, 11, 9, 7, 5, 3, 1);
        sum = _mm_shuffle_epi8 (sum, moveSum);                                      
        SUM = _mm_shuffle_epi8 (SUM, moveSum);
        
        // combine two pixels
        __m128i color = (__m128i) _mm_movelh_ps ((__m128) sum, (__m128) SUM);  

         _mm_storeu_si128 ((__m128i*) &scr[y][x], color);
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
    