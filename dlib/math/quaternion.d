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

module dlib.math.quaternion;

private 
{
    import std.stdio;
    import std.conv;
    import std.range;
    import std.format;
    import std.math;

    import dlib.math.utils;
    import dlib.math.vector;
    import dlib.math.matrix4x4;
}

public:

struct Quaternion(T)
{
    public:

    this (T newx = 0.0, T newy = 0.0, T newz = 0.0, T neww = 0.0)
    body
    {
        x = newx; 
        y = newy; 
        z = newz; 
        w = neww;
    }

    this (Quaternion!(T) q)
    body
    { 
        x = q.x; 
        y = q.y; 
        z = q.z; 
        w = q.w;
    }

    this (T[4] arr)
    body
    {
        arrayof = arr;
    }
	
    this (Vector!(T,3) v, T neww)
    body 
    { 
        x = v.x; 
        y = v.y; 
        z = v.z; 
        w = neww;
    }

    this (Vector!(T,4) v)
    body 
    { 
        x = v.x; 
        y = v.y; 
        z = v.z; 
        w = v.w;
    }

   /*
    * ~Quaternion!(T)
    */
    Quaternion!(T) opUnary (string s)() if (s == "~")
    body
    {
        return Quaternion!(T)(-x, -y, -z, w);
    }

   /*
    * -Quaternion!(T)
    */
    Quaternion!(T) opUnary (string s)() if (s == "-")
    body
    {
        return Quaternion!(T)(-x, -y, -z, -w);
    }

   /*
    * Quaternion!(T) + Quaternion!(T)
    */
    Quaternion!(T) opAdd (Quaternion!(T) q)
    body
    {
        return Quaternion!(T)(x + q.x, y + q.y, z + q.z, w + q.w);
    }

   /*
    * Quaternion!(T) - Quaternion!(T)
    */
    Quaternion!(T) opSub (Quaternion!(T) q)
    body
    {
        return Quaternion!(T)(x - q.x, y - q.y, z - q.z, w - q.w);
    }
    
   /*
    * Quaternion!(T) * Quaternion!(T)
    */
    Quaternion!(T) opMul (Quaternion!(T) q)
    body
    {
        return Quaternion!(T) 
        (
	    (x * q.w) + (w * q.x) + (y * q.z) - (z * q.y),
            (y * q.w) + (w * q.y) + (z * q.x) - (x * q.z),
            (z * q.w) + (w * q.z) + (x * q.y) - (y * q.x),
            (w * q.w) - (x * q.x) - (y * q.y) - (z * q.z)
        );
    }

   /*
    * Quaternion!(T) += Quaternion!(T)
    */
    Quaternion!(T) opAddAssign (Quaternion!(T) q)
    body
    {
        x += q.x; 
        y += q.y; 
        z += q.z; 
        w += q.w;
        return this;
    }

   /*
    * Quaternion!(T) -= Quaternion!(T)
    */
    Quaternion!(T) opSubAssign (Quaternion!(T) q)
    body
    {
        x -= q.x; 
        y -= q.y; 
        z -= q.z; 
        w -= q.w;
        return this;
    }

   /*
    * Quaternion!(T) *= Quaternion!(T)
    */
    Quaternion!(T) opMulAssign (Quaternion!(T) q)
    body
    {
        this = this * q;
        return this;
    }

   /*
    * Quaternion!(T) * T
    */
    Quaternion!(T) opMul (T k)
    body
    {
        return Quaternion!(T)(x * k, y * k, z * k, w * k);
    }

   /*
    * Quaternion!(T) *= T
    */
    Quaternion!(T) opMulAssign (T k)
    body
    {
        w *= k; x *= k; y *= k; z *= k;
        return this;
    }

   /*
    * Quaternion!(T) / T
    */
    Quaternion!(T) opDiv (T k)
    in
    {
        assert (k != 0.0, "Quaternion!(T).opDiv(T k): division by zero");
    }
    body
    {
        T oneOverK = 1.0 / k;
        return Quaternion!(T)(x * oneOverK, y * oneOverK, z * oneOverK, w * oneOverK);
    }
    
   /*
    * Quaternion!(T) /= T
    */
    Quaternion!(T) opDivAssign (T k)
    in
    {
        assert (k != 0.0, "Quaternion!(T).opDivAssign(T k): division by zero");
    }
    body
    {
        T oneOverK = 1.0 / k;
        w *= oneOverK; x *= oneOverK; y *= oneOverK; z *= oneOverK;
        return this;
    }

   /* 
    * Quaternion!(T) * Vector!(T,3)
    */
    Quaternion!(T) opMul (Vector!(T,3) v)
    body
    {
        return Quaternion!(T)
        (
            (w * v.x) + (y * v.z) - (z * v.y),
            (w * v.y) + (z * v.x) - (x * v.z),
            (w * v.z) + (x * v.y) - (y * v.x),
          - (x * v.x) - (y * v.y) - (z * v.z)
        );
    }

   /*
    * Quaternion!(T) *= Vector!(T,3)
    */
    Quaternion!(T) opMulAssign (Vector!(T,3) v)
    body
    {
        this = this * v;
        return this;
    }

   /*
    * T = Quaternion!(T)[index]
    */
    T opIndex (int index)
    in
    {
        assert ((0 <= index) && (index < 3),
            "Quaternion!(T).opIndex(int index): array index out of bounds");
    }
    body
    {
        return arrayof[index];
    }

   /*
    * Quaternion!(T)[index] = T
    */
    T opIndexAssign (T t, int index)
    in
    {
        assert ((0 <= index) && (index < 3),
            "Quaternion!(T).opIndexAssign(T t, int index): array index out of bounds");
    }
    body
    {
        arrayof[index] = t;
        return t;
    }

   /* 
    * Quaternion!(T)[index1..index2] = T
    */
    T opSliceAssign (T t, int index1, int index2)
    in
    {
        assert ((0 <= index1) && (index1 < 3) && (0 <= index2) && (index2 < 3) && (index1 < index2), 
            "Quaternion!(T).opSliceAssign(T t, int index1, int index2): array index out of bounds");
    }
    body
    {
        arrayof[index1..index2] = t;
        return t;
    }
	
   /* 
    * Quaternion!(T)[] = T
    */
    T opSliceAssign (T t)
    body
    {
        arrayof[] = t;
        return t;
    }

   /* 
    * Set to identity
    */
    void identity()
    body
    {
        w = 1.0; 
        x = y = z = 0.0;
    }

   /* 
    * Set vector length to 1
    */
    void normalize()
    body
    {
        T mag = sqrt( (w * w) + (x * x) + (y * y) + (z * z) );
        if (mag > 0.0)
        {
            T oneOverMag = 1.0 / mag;
            w *= oneOverMag;
            x *= oneOverMag;
            y *= oneOverMag;
            z *= oneOverMag;
        }
    }

   /* 
    * Compute the W component of a unit length quaternion
    */
    void computeW()
    body
    {
        T t = 1.0 - (x * x) - (y * y) - (z * z);
        if (t < 0.0) 
            w = 0.0;
        else 
            w = -sqrt(t);
    }

   /* 
    * Rotate a point by quaternion
    */
/*
    void rotate(ref Vector!(T,3) v)
    body
    {
        Quaternion!(T) qf = this * v * (~this);
        v.x = qf.x;
        v.y = qf.y;
        v.z = qf.z;
    }
*/

    Vector!(T,3) rotate(Vector!(T,3) v)
    body
    {
        Quaternion!(T) qf = this * v * (~this);
        return Vector!(T,3)(qf.x, qf.y, qf.z);
    }

   /* 
    * Convert to 4x4 matrix
    */
    Matrix4x4!(T) toMatrix()
    body
    {
        Matrix4x4!(T) mat;
        mat.identity();

        mat[0]  = 1.0 - 2.0 * (y * y + z * z);
        mat[1]  = 2.0 * (x * y + z * w);
        mat[2]  = 2.0 * (x * z - y * w);
        mat[3]  = 0.0;

        mat[4]  = 2.0 * (x * y - z * w);
        mat[5]  = 1.0 - 2.0 * (x * x + z * z);
        mat[6]  = 2.0 * (z * y + x * w);
        mat[7]  = 0.0;

        mat[8]  = 2.0 * (x * z + y * w);
        mat[9]  = 2.0 * (y * z - x * w);
        mat[10] = 1.0 - 2.0 * (x * x + y * y);
        mat[11] = 0.0;

        mat[12] = 0.0;
        mat[13] = 0.0;
        mat[14] = 0.0;
        mat[15] = 1.0;

        return mat;
    }

   /*
    * Setup the quaternion to perform a rotation, 
    * given the angular displacement in matrix form
    */
    void fromMatrix (Matrix4x4!(T) m)
    body
    {
        T trace = m.m11 + m.m22 + m.m33 + 1.0;

        if (trace > 0.0001)
        {
            T s = 0.5 / sqrt(trace);
            w = 0.25 / s;
            x = (m.m23 - m.m32) * s;
            y = (m.m31 - m.m13) * s;
            z = (m.m12 - m.m21) * s;
        }
        else
        {
            if ((m.m11 > m.m22) && (m.m11 > m.m33))
            {
                T s = 0.5 / sqrt(1.0 + m.m11 - m.m22 - m.m33);
                x = 0.25 / s;
                y = (m.m21 + m.m12) * s;
                z = (m.m31 + m.m13) * s;
                w = (m.m32 - m.m23) * s;
            }
            else if (m.m22 > m.m33)
            {
                T s = 0.5 / sqrt(1.0 + m.m22 - m.m11 - m.m33);
                x = (m.m21 + m.m12) * s;
                y = 0.25 / s;
                z = (m.m32 + m.m23) * s;
                w = (m.m31 - m.m13) * s;
            }
            else
            {
                T s = 0.5 / sqrt(1.0 + m.m33 - m.m11 - m.m22);
                x = (m.m31 + m.m13) * s;
                y = (m.m32 + m.m23) * s;
                z = 0.25 / s;
                w = (m.m21 - m.m12) * s;
            }
        }
    }

   /*
    * Setup the quaternion to perform a rotation, 
    * given the orientation in XYZ-Euler angles format (in radians)
    */
    void fromEulerAngles (T x, T y, T z)
    body
    {
        T sr = sin(x * 0.5);
        T cr = cos(x * 0.5);
        T sp = sin(y * 0.5);
        T cp = cos(y * 0.5);
        T sy = sin(z * 0.5);
        T cy = cos(z * 0.5);

        w =  (cy * cp * cr) + (sy * sp * sr);
        x = -(sy * sp * cr) + (cy * cp * sr);
        y =  (cy * sp * cr) + (sy * cp * sr);
        z = -(cy * sp * sr) + (sy * cp * cr);
    }

   /* 
    * Setup the Euler angles, given a rotation Quaternion.
    * Returned x,y,z are in radians
    */
    void toEulerAngles (out T x, out T y, out T z)
    body
    {
        y = asin(2.0 * ((x * z) + (w * y)));

        T cy = cos(y);
        T oneOverCosY = 1.0 / cy;

        if (fabs(cy) > 0.001)
        {
            x = atan2(2.0 * ((w * x) - (y * z)) * oneOverCosY,
                     (1.0 - 2.0 *  (x*x + y*y)) * oneOverCosY);
            z = atan2(2.0 * ((w * z) - (x * y)) * oneOverCosY,
                     (1.0 - 2.0 *  (y*y + z*z)) * oneOverCosY);
        }
        else
        {
            x = 0.0;
            z = atan2(2.0 * ((x * y) + (w * z)), 
                      1.0 - 2.0 *  (x*x + z*z));
        }
    }

   /* 
    * Return the rotation angle theta (in radians)
    */
    T rotationAngle()
    body
    {
        T thetaOver2 = acos(w);
        return thetaOver2 * 2.0;
    }

   /* 
    * Return the rotation axis
    */
    Vector!(T,3) rotationAxis()
    body
    {
        T sinThetaOver2Sq = 1.0 - (w * w);

        if (sinThetaOver2Sq <= 0.0)
            return Vector!(T,3)(1.0, 0.0, 0.0);

        T oneOverSinThetaOver2 = 1.0 / sqrt(sinThetaOver2Sq);
        return Vector!(T,3)
        (
            x * oneOverSinThetaOver2,
            y * oneOverSinThetaOver2,
            z * oneOverSinThetaOver2
        );
    }

   /*
    * Convert to string
    */
    string toString()
    body
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", arrayof);
        return writer.data;
    }

    string toString(size_t index)
    body
    {
        return to!string(arrayof[index]);
    }

   /* 
    * Quaternion components
    */
    union 
    { 
        struct
        {
            T x, y, z, w; 
        }
        T[4] arrayof;
    }
}

/*
 * Scalar on left multiplication
 */
Quaternion!(T) opMul(T) (T k, Quaternion!(T) q)
body
{
    return Quaternion!(T)(q.x * k, q.y * k, q.z * k, q.w * k);
}

/*
 * Dot product
 */
T dot(T) (Quaternion!(T) a, Quaternion!(T) b)
body
{
    return ((a.w * b.w) + (a.x * b.x) + (a.y * b.y) + (a.z * b.z));
}

/* 
 * Compute the quaternion conjugate. 
 * This is a quaternion with the opposite 
 * rotation as the original quaternion
 */
Quaternion!(T) conjugate(T) (Quaternion!(T) q)
body
{
    return Quaternion!(T)(-q.x, -q.y, -q.z, q.w);
}

/* 
 * Compute the inverse quaternion (for unit quaternion only)
 */
Quaternion!(T) inverse(T) (Quaternion!(T) q)
body
{
    Quaternion!(T) res = Quaternion!(T)(-q.x, -q.y, -q.z, q.w);
    res.normalize();
    return res;
}

/*
 * Setup a quaternion to rotate about the specified axis.
 * Theta must be in radians
 */
Quaternion!(T) rotation(T) (uint rotaxis, T theta)
body
{
    Quaternion!(T) res = identityQuaternion!(T);
    T thetaOver2 = theta * 0.5;

    switch (rotaxis)
    {
        case Axis.x:
            res.w = cos(thetaOver2);
            res.x = sin(thetaOver2);
            res.y = 0.0;
            res.z = 0.0;
            break;

        case Axis.y:
            res.w = cos(thetaOver2);
            res.x = 0.0;
            res.y = sin(thetaOver2);
            res.z = 0.0;
            break;

        case Axis.z:
            res.w = cos(thetaOver2);
            res.x = 0.0;
            res.y = 0.0;
            res.z = sin(thetaOver2);
            break;

        default:
	    assert(0);
    }

    return res;
}

Quaternion!(T) rotation(T) (Vector!(T,3) rotaxis, T theta)
body
{
    Quaternion!(T) res = Quaternion!(T)(0.0f,0.0f,1.0f);
    //assert (fabs(dlib.math.vector.dot(rotaxis, rotaxis) - 1.0) < 0.001);
    T thetaOver2 = theta * 0.5;
    T sinThetaOver2 = sin(thetaOver2);

    res.w = cos(thetaOver2);
    res.x = rotaxis.x * sinThetaOver2;
    res.y = rotaxis.y * sinThetaOver2;
    res.z = rotaxis.z * sinThetaOver2;
    return res;
}

/*
 * Setup a quaternion to represent rotation 
 * between two unit-length vectors
 */
Quaternion!(T) rotationBetween(T) (Vector!(T,3) from, Vector!(T,3) to)
{     
    Quaternion!(T) result;     
    Vector!(T,3) H = (from + to).normalized; 

    result.w = dot(from, H);     
    result.x = from.y*H.z - from.z*H.y;     
    result.y = from.z*H.x - from.x*H.z;     
    result.z = from.x*H.y - from.y*H.x;     
    return result;
}

/*
 * Logarithm
 */
Quaternion!(T) log(T)(Quaternion!(T) q)
body
{
    Quaternion!(T) res = Quaternion!(T);
    res.w = 0.0;

    if (fabs(q.w) < 1.0)
    {
        T theta = acos(q.w);
        T sin_theta = sin(theta);

        if (fabs(sin_theta) > 0.00001)
        {
            T thetaOverSinTheta = theta / sin_theta;
            res.x = q.x * thetaOverSinTheta;
            res.y = q.y * thetaOverSinTheta;
            res.z = q.z * thetaOverSinTheta;
            return res;
        }
    }

    res.x = q.x;
    res.y = q.y;
    res.z = q.z;
    return res;
}

/* 
 * Exponential
 */
Quaternion!(T) exp(T) (Quaternion!(T) q)
body
{
    T theta = sqrt(dot(q, q));
    T sin_theta = sin(theta);
    Quaternion!(T) res = Quaternion!(T)();
    res.w = cos(theta);

    if (fabs(sin_theta) > 0.00001)
    {
        T sinThetaOverTheta = sin_theta / theta;
        res.x = q.x * sinThetaOverTheta;
        res.y = q.y * sinThetaOverTheta;
        res.z = q.z * sinThetaOverTheta;
    }
    else
    {
        res.x = q.x;
        res.y = q.y;
        res.z = q.z;
    }

    return res;
}

/* 
 * Exponentiation
 */
Quaternion!(T) pow(T) (Quaternion!(T) q, T exponent)
body
{
    if (fabs(q.w) > 0.9999)
        return q;
    T alpha = acos(q.w);
    T newAlpha = alpha * exponent;
    Vector!(T,3) n = Vector!(T,3)(q.x, q.y, q.z);
    n *= sin(newAlpha) / sin(alpha);
    return new Quaternion!(T)(n, cos(newAlpha));
}

/* 
 * Spherical linear interpolation
 */
Quaternion!(T) slerp(T) (Quaternion!(T) q0, Quaternion!(T) q1, T t)
body
{
    if (t <= 0.0) return q0;
    if (t >= 1.0) return q1;

    T cosOmega = dot(q0, q1);
    T q1w = q1.w;
    T q1x = q1.x;
    T q1y = q1.y;
    T q1z = q1.z;

    if (cosOmega < 0.0)
    {
        q1w = -q1w;
        q1x = -q1x;
        q1y = -q1y;
        q1z = -q1z;
        cosOmega = -cosOmega;
    }
    assert (cosOmega < 1.1);

    T k0, k1;
    if (cosOmega > 0.9999)
    {
        k0 = 1.0 - t;
        k1 = t;
    }
    else
    {
        T sinOmega = sqrt(1.0 - (cosOmega * cosOmega));
        T omega = atan2(sinOmega, cosOmega);
        T oneOverSinOmega = 1.0 / sinOmega;
        k0 = sin((1.0 - t) * omega) * oneOverSinOmega;
        k1 = sin(t * omega) * oneOverSinOmega;
    }

    Quaternion!(T) res = Quaternion!(T)
    (
        (k0 * q0.x) + (k1 * q1x),
        (k0 * q0.y) + (k1 * q1y),
        (k0 * q0.z) + (k1 * q1z),
        (k0 * q0.w) + (k1 * q1w)
    );
    return res;
}

/* 
 * Spherical cubic interpolation
 */
Quaternion!(T) squad(T) (Quaternion!(T) q0, Quaternion!(T) qa, Quaternion!(T) qb, Quaternion!(T) q1, T t)
body
{
    T slerp_t = 2.0 * t * (1.0 - t);
    Quaternion!(T) slerp_q0 = slerp(q0, q1, t);
    Quaternion!(T) slerp_q1 = slerp(qa, qb, t);
    return slerp(slerp_q0, slerp_q1, slerp_t);
}

/*
 * Compute intermediate quaternions for building spline segments
 */
Quaternion!(T) intermediate(T) (Quaternion!(T) qprev, Quaternion!(T) qcurr, Quaternion!(T) qnext, ref Quaternion!(T) qa, ref Quaternion!(T) qb)
in
{
    assert (dot(qprev, qprev) <= 1.0001);
    assert (dot(qcurr, qcurr) <= 1.0001);
}
body
{
    Quaternion!(T) inv_prev = conjugate(qprev);
    Quaternion!(T) inv_curr = conjugate(qcurr);

    Quaternion!(T) p0 = inv_prev * qcurr;
    Quaternion!(T) p1 = inv_curr * qnext;

    Quaternion!(T) arg = (log(p0) - log(p1)) * 0.25;

    qa = qcurr * exp( arg);
    qb = qcurr * exp(-arg);
}

/*
 * Return identity quaternion
 */
Quaternion!(T) identityQuaternion(T)()
body
{
    return Quaternion!(T)(0.0, 0.0, 0.0, 1.0);
}

/*
 * Predefined quaternion type aliases
 */
alias Quaternion!(float) Quaternionf;
alias Quaternion!(double) Quaterniond;

