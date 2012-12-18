module photon.scene.tbcamera;

private
{
    import std.math;

    import derelict.opengl.gl;
    import derelict.opengl.glu;

    import dlib.math.utils;
    import dlib.math.vector;
    import dlib.math.matrix4x4;
    import dlib.math.quaternion;

    import photon.core.modifier;
    import photon.scene.scenenode;
}

interface SceneObject
{
    @property Vector3f position();
}

final class TrackballCamera: Modifier
{
    private:

    Vector3f center;
    float distance;
    Quaternionf rotPitch;
    Quaternionf rotTurn;
    Quaternionf rotRoll;
    Matrix4x4f transform;

    float rotPitchTheta = 0.0f;
    float rotTurnTheta = 0.0f;
    float rotRollTheta = 0.0f;

    float pitch_current_theta = 0.0f;
    float pitch_target_theta = 0.0f;
    float turn_current_theta = 0.0f;
    float turn_target_theta = 0.0f;
    float roll_current_theta = 0.0f;
    float roll_target_theta = 0.0f;

    float current_move = 0.0f;
    float target_move = 0.0f;

    float current_strafe = 0.0f;
    float target_strafe = 0.0f;

    float current_zoom = 0.0f;
    float target_zoom = 0.0f;

    bool zoomIn = false;
    float zoom_smooth = 2.0f;

    Vector3f current_translate;
    Vector3f target_translate;

    public bool movingToTarget = false;

    SceneNode targetObject = null;

    public:

    this()
    {
        center = Vector3f();
        rotPitch = rotation(Vector3f(1.0f,0.0f,0.0f), 0.0f);
        rotTurn = rotation(Vector3f(0.0f,1.0f,0.0f), 0.0f);
        rotRoll = rotation(Vector3f(0.0f,0.0f,1.0f), 0.0f);
        transform.identity();
        distance = 30.0f;
    }

    void bind(double delta)
    {
        if (targetObject) 
            center = -targetObject.position;

        if (current_zoom < target_zoom)
        {
            current_zoom += (target_zoom - current_zoom) / zoom_smooth;
            if (zoomIn) 
                zoom((target_zoom - current_zoom) / zoom_smooth);
            else 
                zoom(-(target_zoom - current_zoom) / zoom_smooth);
        }
        if (current_translate != target_translate)
        {
            current_translate += (target_translate - current_translate)/30.0f;
            translateTarget((target_translate - current_translate)/30.0f);
        }

	glPushMatrix();

        rotPitch = rotation(Vector3f(1.0f,0.0f,0.0f), degtorad(rotPitchTheta));
        rotTurn = rotation(Vector3f(0.0f,1.0f,0.0f), degtorad(rotTurnTheta));
        rotRoll = rotation(Vector3f(0.0f,0.0f,1.0f), degtorad(rotRollTheta));

        Quaternionf q = rotPitch * rotTurn * rotRoll;
        Matrix4x4f rotationMatrix = q.toMatrix();
        transform = translationMatrix(Vector3f(0.0f, 0.0f, -distance)) * rotationMatrix * translationMatrix(center);
        glLoadMatrixf(transform.arrayof.ptr);

        transform.invert();
    }

    void unbind()
    {
        glPopMatrix();
    }

    void free()
    {
    }

    void pitch(float theta)
    {
        rotPitchTheta += theta;
    }

    void turn(float theta)
    {
        rotTurnTheta += theta;
    }

    void roll(float theta)
    {
        rotRollTheta += theta;
    }

    float getPitch()
    {
        return rotPitchTheta;
    }

    float getTurn()
    {
        return rotTurnTheta;
    }

    float getRoll()
    {
        return rotRollTheta;
    }

    void pitchSmooth(float theta, float smooth)
    {
        pitch_target_theta += theta;
        float pitch_theta = (pitch_target_theta - pitch_current_theta) / smooth;
        pitch_current_theta += pitch_theta;
        pitch(pitch_theta);
    }

    void turnSmooth(float theta, float smooth)
    {
        turn_target_theta += theta;
        float turn_theta = (turn_target_theta - turn_current_theta) / smooth;
        turn_current_theta += turn_theta;
        turn(turn_theta);
    }

    void rollSmooth(float theta, float smooth)
    {
        roll_target_theta += theta;
        float roll_theta = (roll_target_theta - roll_current_theta) / smooth;
        roll_current_theta += roll_theta;
        roll(roll_theta);
    }

    void setTarget(Vector3f pos)
    {
        center = pos;
    }

    void setTargetSmooth(Vector3f pos, float smooth)
    {
        current_translate = center;
        target_translate = -pos;
    }

    void setTargetObject(SceneNode obj)
    {
        targetObject = obj;
        center = -targetObject.position;
    }

    void translateTarget(Vector3f pos)
    {
        center += pos;
    }

    Vector3f getTarget()
    {
        return center;
    }

    void setZoom(float z)
    {
        distance = z;
    }

    void zoom(float z)
    {
        distance -= z;
    }

    void zoomSmooth(float z, float smooth)
    {
        zoom_smooth = smooth;

        if (z < 0) 
            zoomIn = true;
        else
            zoomIn = false;

        target_zoom += abs(z);
    }

    Vector3f getPosition()
    {
        return transform.translation();
    }

    Vector3f getRightVector()
    {
        return transform.right();
    }

    Vector3f getUpVector()
    {
        return transform.up();
    }

    Vector3f getDirectionVector()
    {
        return transform.forward();
    }

    void strafe(float speed)
    {
        Vector3f Forward;
        Forward.x = cos(degtorad(rotTurnTheta));
        Forward.y = 0.0f;
        Forward.z = sin(degtorad(rotTurnTheta));
        center += Forward * speed;
    }

    void strafeSmooth(float speed, float smooth)
    {
        target_move += speed;
        float move_sp = (target_move - current_move) / smooth;
        current_move += move_sp;
        strafe(move_sp);
    }

    void move(float speed)
    {
        Vector3f Left;
        Left.x = cos(degtorad(rotTurnTheta+90.0f));
        Left.y = 0.0f;
        Left.z = sin(degtorad(rotTurnTheta+90.0f));
        center += Left * speed;
    }

    void moveSmooth(float speed, float smooth)
    {
        target_strafe += speed;
        float strafe_sp = (target_strafe - current_strafe) / smooth;
        current_strafe += strafe_sp;
        move(strafe_sp);
    }

    void screenToWorld(int scrx, int scry, int scrw, int scrh, float yfov, ref float worldx, ref float worldy, bool snap)
    {
        Vector3f camPos = getPosition();
        Vector3f camDir = getDirectionVector();

        float aspect = cast(float)scrw / cast(float)scrh;

        float xfov = fovXfromY(yfov, aspect);

        float tfov1 = tan(yfov*PI/360.0f); 
        float tfov2 = tan(xfov*PI/360.0f);

        Vector3f camUp = getUpVector() * tfov1;
        Vector3f camRight = getRightVector() * tfov2;

        float width  = 1.0f - 2.0f * cast(float)(scrx) / cast(float)(scrw);
        float height = 1.0f - 2.0f * cast(float)(scry) / cast(float)(scrh);

        float mx = camDir.x + camUp.x * height + camRight.x * width;
        float my = camDir.y + camUp.y * height + camRight.y * width;
        float mz = camDir.z + camUp.z * height + camRight.z * width;

        worldx = snap? floor(camPos.x - mx * camPos.y / my) : (camPos.x - mx * camPos.y / my);
        worldy = snap? floor(camPos.z - mz * camPos.y / my) : (camPos.z - mz * camPos.y / my);
    }
}

