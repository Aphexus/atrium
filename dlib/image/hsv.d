/*
Copyright (c) 2013 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dlib.image.hsv;

private
{
    import std.algorithm;
    import dlib.math.utils;
    import dlib.image.color;
}

enum HSVAChannel
{
    H = 0, 
    S = 1, 
    V = 2, 
    A = 3
}

struct ColorHSVAf
{
    union
    {
        struct
        {
            float h;
            float s;
            float v;
            float a;
        }
        float[4] arrayof;
    }
    
    this(ColorRGBAf c)
    {
        a = c.a;
        
        float cmin, cmax, delta;
        cmin = min(c.r, c.g, c.b);
        cmax = max(c.r, c.g, c.b);
        
        v = cmax;
        delta = cmax - cmin;
        
        if (cmax > 0.0f)
            s = delta / cmax;
        else
        {
            // r = g = b = 0                        
            // s = 0, h is undefined
            s = 0.0f;
            h = float.nan;
            return;
        }
        
        if (c.r >= cmax)
            h = (c.g - c.b) / delta;
        else
        {
            if (c.g >= cmax)
                h = 2.0f + (c.b - c.r) / delta;
            else
                h = 4.0f + (c.r - c.g) / delta;
        }
        
        h *= 60.0f;

        if (h < 0.0f)
            h += 360.0f;
    }
    
    ColorRGBAf rgba()
    {
        ColorRGBAf res;
        
        res.a = a;

        if (s <= 0.0f)
        {
            res.r = res.g = res.b = v;
            return res;
        }

        float hh = h;

        if (hh >= 360.0f) 
            hh = 0.0f;
            hh /= 60.0f;

        int i = cast(int)hh;
        float ff = hh - i;
        float p = v * (1.0f - s);
        float q = v * (1.0f - (s * ff));
        float t = v * (1.0f - (s * (1.0f - ff)));

        switch(i) 
        {
            case 0:  res.r = v; res.g = t; res.b = p; break;
            case 1:  res.r = q; res.g = v; res.b = p; break;
            case 2:  res.r = p; res.g = v; res.b = t; break;
            case 3:  res.r = p; res.g = q; res.b = v; break;
            case 4:  res.r = t; res.g = p; res.b = v; break;
            case 5:
            default: res.r = v; res.g = p; res.b = q; break;
        }

        return res;
    }
    
    void shiftHue(float degrees)
    {
        h += degrees;
        while (h >= 360.0f) 
            h -= 360.0f;
        while (h < 0.0f) 
            h += 360.0f;
    }
    
    void shiftSaturation(float val)
    {
        s += val;
        s = clamp(s, 0.0f, 1.0f);
    }
    
    void scaleSaturation(float val)
    {
        s *= val;
        s = clamp(s, 0.0f, 1.0f);
    }
    
    void shiftValue(float val)
    {
        v += val;
        v = clamp(v, 0.0f, 1.0f);
    }

    void scaleValue(float val)
    {
        v *= val;
        v = clamp(v, 0.0f, 1.0f);
    }
    
    bool hueInRange(float hue2, float tmin, float tmax)
    {
        if (h == hue2) 
            return true;

        float h1 = hue2 + tmin;
        while (h1 >= 360.0f) 
            h1 -= 360.0f;
        while (h1 < 0.0f) 
            h1 += 360.0f;

        float h2 = hue2 + tmax;
        while (h2 >= 360.0f) 
            h2 -= 360.0f;
        while (h1 < 0.0f) 
            h2 += 360.0f;

        return (h1 > h2)? 
            (h > h1 || h < h2):
            (h > h1 && h < h2);
    }
}

