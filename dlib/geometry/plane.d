/*
Copyright (c) 2011-2012 Timur Gafarov 

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

module dlib.geometry.plane;

private
{
    import std.math;
    import dlib.math.vector;
    import dlib.math.utils;
}

struct Plane
{
   /*
    * Return a Plane with all values at zero
    */
    static Plane opCall()
    {
        return Plane(0.0f, 0.0f, 0.0f, 0.0f);
    }

   /*
    * Return a Plane with the Vec3f component of n and distance of d
    */
    static Plane opCall(Vector3f n, float d)
    {
        return Plane(n.x, n.y, n.z, d);
    }

   /*
    * Return a Plane with a Vec3f component of x, y, z and distance of d
    */
    static Plane opCall(float x, float y, float z, float d)
    {
        Plane p;
        p.x = x;
        p.y = y;
        p.z = z;
        p.d = d;
        return p;
    }

    void fromPoints(Vector3f p0, Vector3f p1, Vector3f p2)
    {
        Vector3f v0 = p0 - p1;
        Vector3f v1 = p2 - p1;
        Vector3f n = cross(v1, v0);
        n.normalize();
        x = n.x;
        y = n.y;
        z = n.z;
	    d = -(p0.x * x + p0.y * y + p0.z * z);
    }

    void fromPointAndNormal(Vector3f p, Vector3f n)
    {
        n.normalize();
        x = n.x;
        y = n.y;
        z = n.z;
        d = -(p.x * x + p.y * y + p.z * z);
    }

    float dot(Vector3f p)
    {
        return x * p.x + y * p.y + z * p.z;
    }

    void normalize()
    {
        float len = sqrt(x * x + y * y + z * z);
        x *= len;
        y *= len;
        z *= len;
        d *= len;
    }

    Plane normalized()
    {
        Plane res;
        float len = sqrt(x * x + y * y + z * z);
        return Plane(x * len, y * len, z * len, d * len);
    }

   /*
    * Get the distance from the center of the plane to the given point.
    * This is useful for determining which side of the plane the point is on. 
    */
    float distance(Vector3f p)
    {
        return x * p.x + y * p.y + z * p.z + d;
    }

    Vector3f reflect(Vector3f vec)
    {
        float d = distance(vec);
        return vec + 2 * Vector3f(-x, -y, -z) * d;
    }

    Vector3f project(Vector3f p)
    {
        float h = distance(p);
        return Vector3f(p.x - x * h,
                        p.y - y * h,
                        p.z - z * h);
    }

    bool isOnPlane(Vector3f p, float threshold = 0.001f)
    {
        float d = distance(p);
        if (d < threshold && d > -threshold)
            return true;
        return false;
    }

   /*
    * Calculate the intersection between this plane and a line
    * If the plane and the line are parallel, false is returned
    */
    bool intersectsLine(Vector3f p0, Vector3f p1, ref float t)
    {
        Vector3f dir = p1 - p0;
        float div = dot(dir);
        if (div == 0.0)
            return false;
        t = -distance(p0) / div;
        return true;
    }

    bool intersectsLine(Vector3f p0, Vector3f p1, ref Vector3f ip)
    {
        Vector3f dir = p1 - p0;
        float div = dot(dir);
        if (div == 0.0)
        {
            ip = (p0 + p1) * 0.5f;
            return false;
        }
        float u = -distance(p0) / div;
        ip = p0 + u * (p1 - p0);
        return true;
    }

    bool intersectsLineSegment(Vector3f p0, Vector3f p1, ref Vector3f ip)
    {
        Vector3f ray = p1 - p0;

        // calculate plane
        float d = dot(position);
        float dr = dot(ray);

        if (abs(dr) < EPSILON)
            return false; // avoid divide by zero

        // Compute the t value for the directed line ray intersecting the plane
        float t = (d - dot(p0)) / dr;

        // scale the ray by t
        Vector3f newRay = ray * t;

        // calc contact point
        ip = p0 + newRay;

        if (t >= 0.0 && t <= 1.0)
            return true; // line intersects plane

        return false; // line does not
    }

    float opIndex(size_t i)
    {
        return arrayof[i];
    }

    float opIndexAssign(float value, size_t i)
    {
        return (arrayof[i] = value);
    }

    union
    {
        float arrayof[4];// = [0, 0, 0, 0];
        
        Vector4f vectorof;

        struct
        {
            float a, b, c, d;
        }
        
        Vector3f normal;
    }

    alias vectorof this;

    @property Vector3f position()
    {
        return -(normal * d);
    }
}

