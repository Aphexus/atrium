/*
Copyright (c) 2011-2013 Timur Gafarov 

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

module dlib.math.matrix;

private 
{
    import std.stdio;
    import std.math;

    import dlib.math.utils;
    import dlib.math.vector;
}

public:

struct Matrix(T, size_t rows, size_t columns)
{
   /*
    * Return zero matrix
    */
    static opCall() 
    {
        Matrix!(T,rows,columns) res;
        foreach (ref v; res.arrayof)
            v = 0.0f;
        return res;
    }

   /*
    * Matrix * Matrix
    */
    Matrix!(T,rows,columns) opMul (Matrix!(T,rows,columns) mat)
    body
    {       
        auto res = Matrix!(T,rows,columns)(); 

        foreach (r; 0..rows)
        foreach (c; 0..columns)
        {
            foreach (m; 0..columns)
                res.arrayof[r][c] += arrayof[r][m] * mat.arrayof[m][c];
        }

        return res;
    }

   /*
    * Matrix *= Matrix
    */
    Matrix!(T,rows,columns) opMulAssign (Matrix!(T,rows,columns) mat)
    body
    {
        auto res = Matrix!(T,rows,columns)(); 

        foreach (r; 0..rows)
        foreach (c; 0..columns)
        {
            foreach (m; 0..columns)
                res.arrayof[r][c] += arrayof[r][m] * mat.arrayof[m][c];
        }

        arrayof[] = res.arrayof[];

        return mat;
    }

   /* 
    * T = Matrix[x, y]
    */
    T opIndex(size_t x, size_t y)
    in
    {
        assert ((0 < x) && (x < columns) && (0 < y) && (y < rows), 
            "Matrix.opIndex(int x, int y): array index out of bounds");
    }
    body
    {
        return arrayof[y][x];
    }

   /* 
    * Matrix[x, y] = T
    */
    T opIndexAssign(T t, int x, int y)
    in
    {
        assert ((0 < x) && (x < columns) && (0 < y) && (y < rows), 
            "Matrix.opIndexAssign(int x, int y): array index out of bounds");
    }
    body
    {
        return (arrayof[y][x] = t);
    }

    void setRow(size_t row, Vector!(T,columns) vec)
    body
    {
        foreach (c; 0..columns)
            arrayof[row][c] = vec[c];
    }

    Vector!(T,columns) getRow(size_t row)
    body
    {
        Vector!(T,columns) vec;

        foreach (c; 0..columns)
            vec[c] = arrayof[row][c];

        return vec;
    }

    void setColumn(size_t column, Vector!(T,rows) vec)
    body
    {
        foreach (r; 0..rows)
            arrayof[r][column] = vec[r];
    }

    Vector!(T,rows) getColumn(size_t column)
    body
    {
        Vector!(T,rows) vec;

        foreach (r; 0..rows)
            vec[r] = arrayof[r][column];

        return vec;
    }

    void transpose()
    body
    {
        Matrix!(T,rows,columns) res = transposed;
        arrayof[] = res.arrayof[];
    }

    @property Matrix!(T,rows,columns) transposed()
    body
    {
        Matrix!(T,rows,columns) res;

        foreach (r; 0..rows)
        foreach (c; 0..columns)
            res.arrayof[c][r] = arrayof[r][c];

        return res;
    }

    T[rows][columns] arrayof;
}

