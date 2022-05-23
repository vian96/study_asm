
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
    
    for (int iy = 0; iy < 600; iy++) {
        float x0 = shiftX / scale;
        float y0 = (iy + shiftY) / scale;

        for (int ix = 0; ix < 800; ix++, x0 += dx) {
            float X = x0, Y = y0;

            int N = 0;
            for (; N < nMax; N++) {
                float x2 = X*X,
                      y2 = Y*Y,
                      xy = X*Y;

                float r2 = x2 + y2;
                    
                if (r2 >= 4) 
                    break;

                X = x2 - y2 + x0,
                Y = xy + xy + y0;
            }
            
            float I = sqrtf (sqrtf ((float)N / (float)nMax)) * 255.f;

            BYTE c = (BYTE) I;
            RGBQUAD color = (N < nMax)? RGBQUAD { (BYTE) (255-c), (BYTE) (c%2 * 64), c } : RGBQUAD {};
            scr[iy][ix] = color;
        }
    }
}


