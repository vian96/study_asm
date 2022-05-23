
#include "E:\WindowsFolders\Desktop\prog\TX\TXLib.h"
#include <emmintrin.h>
#include <chrono>

//=================================================================================================

typedef RGBQUAD (&scr_t) [600][800];

const float SCREEN_WIDTH  = 800;
const float SCREEN_HEIGHT = 600;

const int LOOP_CNT = 30;

void draw_mandelbrot (float shiftX, float shiftY, float scale, scr_t scr);

//=================================================================================================

int main()
    {
    txCreateWindow (800, 600);
    Win32::_fpreset();
    txBegin();

    scr_t scr = (scr_t) *txVideoMemory();
    
    const int    nMax  = 256;
    const float  dx    = 1/800.f, dy = 1/800.f;
    const __m128 r2Max = _mm_set_ps1 (100.f);
    const __m128 _255  = _mm_set_ps1 (255.f);
    const __m128 _3210 = _mm_set_ps  (3.f, 2.f, 1.f, 0.f);
    
    const __m128 nmax  = _mm_set_ps1 (nMax);

    float xC = -0.5*SCREEN_WIDTH, yC = -0.5*SCREEN_HEIGHT, scale = 20.f;

    for (;;)
        {
        if (GetAsyncKeyState (VK_ESCAPE)) break;
        
        if (txGetAsyncKeyState (VK_RIGHT)) xC    += 1000 * dx * (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (txGetAsyncKeyState (VK_LEFT))  xC    -= 1000 * dx * (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (txGetAsyncKeyState (VK_DOWN))  yC    -= 1000 * dy * (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (txGetAsyncKeyState (VK_UP))    yC    += 1000 * dy * (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (txGetAsyncKeyState ('A'))  
            scale *= 1.1;
            // scale += (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (txGetAsyncKeyState ('Z'))
            scale /= 1.1;
            // scale -= (txGetAsyncKeyState (VK_SHIFT)? 100.f : 10.f);
        if (GetAsyncKeyState (VK_ESCAPE)) break;

        auto start = std::chrono::steady_clock::now();
        for (int i = 0; i < LOOP_CNT; i++)
            draw_mandelbrot (xC, yC, scale, scr);
        
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds> 
                            (std::chrono::steady_clock::now() - start);
        double fps = 1000. * LOOP_CNT / elapsed.count();
        
        printf("fps is %.0f\n", fps);
        
        txUpdateWindow();
        }

    txDisableAutoPause();
    }

//=================================================================================================

void draw_mandelbrot (float shiftX, float shiftY, float scale, scr_t scr) {
     const float dx = 1/scale;
    
    const int nMax  = 256;
    const __m128 r2Max = _mm_set_ps1 (4.f);
    const __m128  _255 = _mm_set_ps1 (255.f);
    const __m128 _3210 = _mm_set_ps  (3.f, 2.f, 1.f, 0.f);
    const __m128 nmax  = _mm_set_ps1 (nMax);

    for (int iy = 0; iy < SCREEN_HEIGHT; iy++) {
        float x0 = shiftX / scale;
        float y0 = (iy + shiftY) / scale;

        for (int ix = 0; ix < SCREEN_WIDTH; ix += 4, x0 += dx * 4)
        {
            __m128 X0 = _mm_add_ps (_mm_set_ps1 (x0), _mm_mul_ps (_3210, _mm_set_ps1 (dx)));
            __m128 Y0 = _mm_set_ps1 (y0);

            __m128 X = X0, Y = Y0;
                
            __m128i N = _mm_setzero_si128();

            for (int n = 0; n < nMax; n++)
            {
                __m128 x2 = _mm_mul_ps (X, X),
                       y2 = _mm_mul_ps (Y, Y);

                __m128 r2 = _mm_add_ps (x2, y2);

                __m128 cmp = _mm_cmple_ps (r2, r2Max);
                int mask = _mm_movemask_ps (cmp);
                if (!mask)
                    break;

                N = _mm_sub_epi32 (N, _mm_castps_si128 (cmp));

                __m128 xy = _mm_mul_ps (X, Y);

                X = _mm_add_ps (_mm_sub_ps (x2, y2), X0);
                Y = _mm_add_ps (_mm_add_ps (xy, xy), Y0);
            }

            // 255 * (N/nmax)^(1/4)
            __m128 color = _mm_mul_ps(_mm_sqrt_ps(_mm_sqrt_ps(_mm_div_ps(_mm_cvtepi32_ps (N), nmax))), _255);

            for (int i = 0, j = 0; i < 4; i++, j++)
                {
                int*   pn = (int*)   &N;
                float* pI = (float*) &color;

                BYTE    c     = (BYTE) pI[i];
                scr[iy][ix+i] = (pn[i] < nMax)? RGBQUAD { (BYTE) (255-c), (BYTE) (c%2 * 64), c } : RGBQUAD {};
                }
        }
    }
}   


