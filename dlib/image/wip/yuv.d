/*
Copyright (c) 2011 Timur Gafarov 

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

module dlib.image2.yuv;

private
{
    import std.math;
    import dlib.math.utils;
    import dlib.image2.rgb;
}

public:

enum YUVAChannel
{
    Y, U, V, A
};

struct YUVAf
{
    union
    {
        struct
        {
             float y;
             float u;
             float v;
             float a;
        }
        float[4] arrayof;
    }
}

YUVAf convertRGBAfToYUVAf(RGBAf col)
{
    YUVAf res;
    res.y = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
    res.u = -0.14713 * col.r - 0.28886 * col.g + 0.436 * col.b;
    res.v = 0.615 * col.r - 0.51499 * col.g - 0.10001 * col.b;
    res.a = col.a;
    return res;
}

RGBAf convertYUVAfToRGBAf(YUVAf col)
{
    RGBAf res;
    res.r = col.y + 1.13983 * col.v;
    res.g = col.y - 0.39465 * col.u - 0.58060 * col.v;
    res.b = col.y + 2.03211 * col.u;
    res.a = col.a;
    return res;
}




