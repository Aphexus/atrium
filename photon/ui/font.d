module photon.ui.font;

private
{
    import std.string;
    import std.ascii;

    import derelict.opengl.gl;
    import derelict.freetype.ft;
}

struct Glyph
{
    GLuint textureId = 0;
    FT_Glyph ft_glyph = null;
    int width = 0, height = 0;
    FT_Pos advance_x = 0;
}

int nextP2(int a)
{
    int rval=1;
    while(rval<a) rval<<=1;
    return rval;
}

final class Font
{
    private:

    FT_Face m_face;
    FT_Library m_library;
    float m_h;
    Glyph[dchar] m_glyphList;

    public:
    
    void init(string fname, uint h)
    {
        enum ASCII_CHARS = 128;
        this.m_h = h;

        if (FT_Init_FreeType( &m_library )) 
            throw new Exception("FT_Init_FreeType failed");

        if (FT_New_Face( m_library, toStringz(fname), 0, &m_face )) 
            throw new Exception("FT_New_Face failed (there is probably a problem with your font file)");
        
        FT_Set_Char_Size( m_face, h << 6, h << 6, 96, 96);
    
        GLuint[] textures = new GLuint[ASCII_CHARS];
        glGenTextures(ASCII_CHARS, textures.ptr);

        foreach(i; 0..ASCII_CHARS)
            setupGlyph(i, textures[i]);
    }
    
    float getHeight() { return m_h; }
    
    private:

    uint setupGlyph(dchar ch, GLuint texId)
    {
        //The first thing we do is get FreeType to render our character
        //into a bitmap. This actually requires a couple of FreeType commands:
        uint char_index = FT_Get_Char_Index(m_face, ch);

        if (char_index == 0)
        {
            //char wasn't found in font file
        }
    
        if (FT_Load_Glyph( m_face, char_index, FT_LOAD_DEFAULT ))
            throw new Exception("FT_Load_Glyph failed");
        
        FT_Glyph glyph;
        if(FT_Get_Glyph( m_face.glyph, &glyph ))
            throw new Exception("FT_Get_Glyph failed");

        FT_Glyph_To_Bitmap( &glyph, FT_Render_Mode.FT_RENDER_MODE_NORMAL, null, 1 );
        FT_BitmapGlyph bitmap_glyph = cast(FT_BitmapGlyph)glyph;

        FT_Bitmap bitmap = bitmap_glyph.bitmap;
    
        int width = nextP2(bitmap.width);
        int height = nextP2(bitmap.rows);
    
        GLubyte[] expanded_data = new GLubyte[2 * width * height];

        for(int j=0; j < height;j++) 
        for(int i=0; i < width; i++)
        {
            expanded_data[2*(i+j*width)] = 255;
            expanded_data[2*(i+j*width)+1] =
                (i>=bitmap.width || j>=bitmap.rows) ?
                0 : bitmap.buffer[i + bitmap.width*j];
        }
    
        glBindTexture(GL_TEXTURE_2D, texId);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height,
            0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, expanded_data.ptr );

        delete expanded_data;

        Glyph g = Glyph(texId, glyph, width, height, m_face.glyph.advance.x);
        m_glyphList[ch] = g;

        return char_index;
    }
    
    public void render(T)(T str)
    {
        for (size_t i = 0; i < str.length; ++i)
        {
            if (str[i].isASCII)
            {
                if (str[i].isPrintable)
                    renderGlyph(str[i]);
            }
            else
                renderGlyph(str[i]);
        }
    }

    void renderGlyph(dchar code)
    {
        Glyph glyph;
        if (code in m_glyphList)
            glyph = m_glyphList[code];
        else
            glyph = m_glyphList[loadChar(code)];
        
        FT_BitmapGlyph bitmap_glyph = cast(FT_BitmapGlyph)(glyph.ft_glyph);

        FT_Bitmap bitmap = bitmap_glyph.bitmap;

        glBindTexture(GL_TEXTURE_2D, glyph.textureId);

        glPushMatrix();
        glTranslatef(bitmap_glyph.left,0,0);
        glTranslatef(0,bitmap_glyph.top-bitmap.rows,0);
        float x = cast(float)bitmap.width / cast(float)glyph.width;
        float y = cast(float)bitmap.rows / cast(float)glyph.height;
        glBegin(GL_QUADS);
            glTexCoord2d(0,0); glVertex2f(0,bitmap.rows);
            glTexCoord2d(0,y); glVertex2f(0,0);
            glTexCoord2d(x,y); glVertex2f(bitmap.width,0);
            glTexCoord2d(x,0); glVertex2f(bitmap.width,bitmap.rows);
        glEnd();
        glPopMatrix();
        glTranslatef(glyph.advance_x >> 6,0,0);
    }
    
    dchar loadChar(dchar code)
    {
        GLuint tex;
        glGenTextures(1, &tex);
        setupGlyph(code, tex);
        return code;
    }
}

