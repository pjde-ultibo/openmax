unit uGLES2;

{$mode delphi}
{
  Copyright (c) 2012, Broadcom Europe Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
      * Neither the name of the copyright holder nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   }

interface

uses
  Classes, SysUtils, uKHR;

const
  GL_ES_VERSION_2_0                        = 1;
  { ClearBufferMask  }
  GL_DEPTH_BUFFER_BIT                      = $00000100;
  GL_STENCIL_BUFFER_BIT                    = $00000400;
  GL_COLOR_BUFFER_BIT                      = $00004000;

  GL_POINTS                                = $0000;
  GL_LINES                                 = $0001;
  GL_LINE_LOOP                             = $0002;
  GL_LINE_STRIP                            = $0003;
  GL_TRIANGLES                             = $0004;
  GL_TRIANGLE_STRIP                        = $0005;
  GL_TRIANGLE_FAN                          = $0006;


  { AlphaFunction (not supported in ES20) }
  {      GL_NEVER }
  {      GL_LESS }
  {      GL_EQUAL }
  {      GL_LEQUAL }
  {      GL_GREATER }
  {      GL_NOTEQUAL }
  {      GL_GEQUAL }
  {      GL_ALWAYS }

  { BlendingFactorDest }
  GL_ZERO                                  = 0;
  GL_ONE                                   = 1;
  GL_SRC_COLOR                             = $0300;
  GL_ONE_MINUS_SRC_COLOR                   = $0301;
  GL_SRC_ALPHA                             = $0302;
  GL_ONE_MINUS_SRC_ALPHA                   = $0303;
  GL_DST_ALPHA                             = $0304;
  GL_ONE_MINUS_DST_ALPHA                   = $0305;
  { BlendingFactorSrc }
  {      GL_ZERO }
  {      GL_ONE }
  GL_DST_COLOR                             = $0306;
  GL_ONE_MINUS_DST_COLOR                   = $0307;
  GL_SRC_ALPHA_SATURATE                    = $0308;
  {      GL_SRC_ALPHA }
  {      GL_ONE_MINUS_SRC_ALPHA }
  {      GL_DST_ALPHA }
  {      GL_ONE_MINUS_DST_ALPHA }
  { BlendEquationSeparate }
  GL_FUNC_ADD                              = $8006;
  GL_BLEND_EQUATION                        = $8009;

  GL_BLEND_EQUATION_RGB                    = $8009;      { same as BLEND_EQUATION }
  GL_BLEND_EQUATION_ALPHA                  = $883D;
  { BlendSubtract }
  GL_FUNC_SUBTRACT                         = $800A;
  GL_FUNC_REVERSE_SUBTRACT                 = $800B;
  { Separate Blend Functions }
  GL_BLEND_DST_RGB                         = $80C8;
  GL_BLEND_SRC_RGB                         = $80C9;
  GL_BLEND_DST_ALPHA                       = $80CA;
  GL_BLEND_SRC_ALPHA                       = $80CB;
  GL_CONSTANT_COLOR                        = $8001;
  GL_ONE_MINUS_CONSTANT_COLOR              = $8002;
  GL_CONSTANT_ALPHA                        = $8003;
  GL_ONE_MINUS_CONSTANT_ALPHA              = $8004;
  GL_BLEND_COLOR                           = $8005;
  { Buffer Objects }
  GL_ARRAY_BUFFER                          = $8892;
  GL_ELEMENT_ARRAY_BUFFER                  = $8893;
  GL_ARRAY_BUFFER_BINDING                  = $8894;
  GL_ELEMENT_ARRAY_BUFFER_BINDING          = $8895;
  GL_STREAM_DRAW                           = $88E0;
  GL_STATIC_DRAW                           = $88E4;
  GL_DYNAMIC_DRAW                          = $88E8;
  GL_BUFFER_SIZE                           = $8764;
  GL_BUFFER_USAGE                          = $8765;
  GL_CURRENT_VERTEX_ATTRIB                 = $8626;
  { CullFaceMode }
  GL_FRONT                                 = $0404;
  GL_BACK                                  = $0405;
  GL_FRONT_AND_BACK                        = $0408;
  { DepthFunction }
  {      GL_NEVER }
  {      GL_LESS }
  {      GL_EQUAL }
  {      GL_LEQUAL }
  {      GL_GREATER }
  {      GL_NOTEQUAL }
  {      GL_GEQUAL }
  {      GL_ALWAYS }
  { EnableCap }
  GL_TEXTURE_2D                            = $0DE1;
  GL_CULL_FACE                             = $0B44;
  GL_BLEND                                 = $0BE2;
  GL_DITHER                                = $0BD0;
  GL_STENCIL_TEST                          = $0B90;
  GL_DEPTH_TEST                            = $0B71;
  GL_SCISSOR_TEST                          = $0C11;
  GL_POLYGON_OFFSET_FILL                   = $8037;
  GL_SAMPLE_ALPHA_TO_COVERAGE              = $809E;
  GL_SAMPLE_COVERAGE                       = $80A0;
  { ErrorCode }
  GL_NO_ERROR                              = 0;
  GL_INVALID_ENUM                          = $0500;
  GL_INVALID_VALUE                         = $0501;
  GL_INVALID_OPERATION                     = $0502;
  GL_OUT_OF_MEMORY                         = $0505;
  { FrontFaceDirection }
  GL_CW                                    = $0900;
  GL_CCW                                   = $0901;
  { GetPName }
  GL_LINE_WIDTH                            = $0B21;
  GL_ALIASED_POINT_SIZE_RANGE              = $846D;
  GL_ALIASED_LINE_WIDTH_RANGE              = $846E;
  GL_CULL_FACE_MODE                        = $0B45;
  GL_FRONT_FACE                            = $0B46;
  GL_DEPTH_RANGE                           = $0B70;
  GL_DEPTH_WRITEMASK                       = $0B72;
  GL_DEPTH_CLEAR_VALUE                     = $0B73;
  GL_DEPTH_FUNC                            = $0B74;
  GL_STENCIL_CLEAR_VALUE                   = $0B91;
  GL_STENCIL_FUNC                          = $0B92;
  GL_STENCIL_FAIL                          = $0B94;
  GL_STENCIL_PASS_DEPTH_FAIL               = $0B95;
  GL_STENCIL_PASS_DEPTH_PASS               = $0B96;
  GL_STENCIL_REF                           = $0B97;
  GL_STENCIL_VALUE_MASK                    = $0B93;
  GL_STENCIL_WRITEMASK                     = $0B98;
  GL_STENCIL_BACK_FUNC                     = $8800;
  GL_STENCIL_BACK_FAIL                     = $8801;
  GL_STENCIL_BACK_PASS_DEPTH_FAIL          = $8802;
  GL_STENCIL_BACK_PASS_DEPTH_PASS          = $8803;
  GL_STENCIL_BACK_REF                      = $8CA3;
  GL_STENCIL_BACK_VALUE_MASK               = $8CA4;
  GL_STENCIL_BACK_WRITEMASK                = $8CA5;
  GL_VIEWPORT                              = $0BA2;
  GL_SCISSOR_BOX                           = $0C10;
  {      GL_SCISSOR_TEST }
  GL_COLOR_CLEAR_VALUE                     = $0C22;
  GL_COLOR_WRITEMASK                       = $0C23;
  GL_UNPACK_ALIGNMENT                      = $0CF5;
  GL_PACK_ALIGNMENT                        = $0D05;
  GL_MAX_TEXTURE_SIZE                      = $0D33;
  GL_MAX_VIEWPORT_DIMS                     = $0D3A;
  GL_SUBPIXEL_BITS                         = $0D50;
  GL_RED_BITS                              = $0D52;
  GL_GREEN_BITS                            = $0D53;
  GL_BLUE_BITS                             = $0D54;
  GL_ALPHA_BITS                            = $0D55;
  GL_DEPTH_BITS                            = $0D56;
  GL_STENCIL_BITS                          = $0D57;
  GL_POLYGON_OFFSET_UNITS                  = $2A00;
  {      GL_POLYGON_OFFSET_FILL }
  GL_POLYGON_OFFSET_FACTOR                 = $8038;
  GL_TEXTURE_BINDING_2D                    = $8069;
  GL_SAMPLE_BUFFERS                        = $80A8;
  GL_SAMPLES                               = $80A9;
  GL_SAMPLE_COVERAGE_VALUE                 = $80AA;
  GL_SAMPLE_COVERAGE_INVERT                = $80AB;
  { GetTextureParameter }
  {      GL_TEXTURE_MAG_FILTER }
  {      GL_TEXTURE_MIN_FILTER }
  {      GL_TEXTURE_WRAP_S }
  {      GL_TEXTURE_WRAP_T }
  GL_NUM_COMPRESSED_TEXTURE_FORMATS        = $86A2;
  GL_COMPRESSED_TEXTURE_FORMATS            = $86A3;
  { HintMode }
  GL_DONT_CARE                             = $1100;
  GL_FASTEST                               = $1101;
  GL_NICEST                                = $1102;
  { HintTarget }
  GL_GENERATE_MIPMAP_HINT                  = $8192;
  { DataType }
  GL_BYTE                                  = $1400;
  GL_UNSIGNED_BYTE                         = $1401;
  GL_SHORT                                 = $1402;
  GL_UNSIGNED_SHORT                        = $1403;
  GL_INT                                   = $1404;
  GL_UNSIGNED_INT                          = $1405;
  GL_FLOAT                                 = $1406;
  GL_FIXED                                 = $140C;
  { PixelFormat }
  GL_DEPTH_COMPONENT                       = $1902;
  GL_ALPHA                                 = $1906;
  GL_RGB                                   = $1907;
  GL_RGBA                                  = $1908;
  GL_LUMINANCE                             = $1909;
  GL_LUMINANCE_ALPHA                       = $190A;
  { PixelType }
  {      GL_UNSIGNED_BYTE }
  GL_UNSIGNED_SHORT_4_4_4_4                = $8033;
  GL_UNSIGNED_SHORT_5_5_5_1                = $8034;
  GL_UNSIGNED_SHORT_5_6_5                  = $8363;
  { Shaders }
  GL_FRAGMENT_SHADER                       = $8B30;
  GL_VERTEX_SHADER                         = $8B31;
  GL_MAX_VERTEX_ATTRIBS                    = $8869;
  GL_MAX_VERTEX_UNIFORM_VECTORS            = $8DFB;
  GL_MAX_VARYING_VECTORS                   = $8DFC;
  GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS      = $8B4D;
  GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS        = $8B4C;
  GL_MAX_TEXTURE_IMAGE_UNITS               = $8872;
  GL_MAX_FRAGMENT_UNIFORM_VECTORS          = $8DFD;
  GL_SHADER_TYPE                           = $8B4F;
  GL_DELETE_STATUS                         = $8B80;
  GL_LINK_STATUS                           = $8B82;
  GL_VALIDATE_STATUS                       = $8B83;
  GL_ATTACHED_SHADERS                      = $8B85;
  GL_ACTIVE_UNIFORMS                       = $8B86;
  GL_ACTIVE_UNIFORM_MAX_LENGTH             = $8B87;
  GL_ACTIVE_ATTRIBUTES                     = $8B89;
  GL_ACTIVE_ATTRIBUTE_MAX_LENGTH           = $8B8A;
  GL_SHADING_LANGUAGE_VERSION              = $8B8C;
  GL_CURRENT_PROGRAM                       = $8B8D;
  { StencilFunction }
  GL_NEVER                                 = $0200;
  GL_LESS                                  = $0201;
  GL_EQUAL                                 = $0202;
  GL_LEQUAL                                = $0203;
  GL_GREATER                               = $0204;
  GL_NOTEQUAL                              = $0205;
  GL_GEQUAL                                = $0206;
  GL_ALWAYS                                = $0207;
  { StencilOp }
  {      GL_ZERO  }
  GL_KEEP                                  = $1E00;
  GL_REPLACE                               = $1E01;
  GL_INCR                                  = $1E02;
  GL_DECR                                  = $1E03;
  GL_INVERT                                = $150A;
  GL_INCR_WRAP                             = $8507;
  GL_DECR_WRAP                             = $8508;
  { StringName }
  GL_VENDOR                                = $1F00;
  GL_RENDERER                              = $1F01;
  GL_VERSION                               = $1F02;
  GL_EXTENSIONS                            = $1F03;
  { TextureMagFilter }
  GL_NEAREST                               = $2600;
  GL_LINEAR                                = $2601;
  { TextureMinFilter }
  {      GL_NEAREST }
  {      GL_LINEAR }
  GL_NEAREST_MIPMAP_NEAREST                = $2700;
  GL_LINEAR_MIPMAP_NEAREST                 = $2701;
  GL_NEAREST_MIPMAP_LINEAR                 = $2702;
  GL_LINEAR_MIPMAP_LINEAR                  = $2703;
  { TextureParameterName }
  GL_TEXTURE_MAG_FILTER                    = $2800;
  GL_TEXTURE_MIN_FILTER                    = $2801;
  GL_TEXTURE_WRAP_S                        = $2802;
  GL_TEXTURE_WRAP_T                        = $2803;
  { TextureTarget }
  {      GL_TEXTURE_2D }
  GL_TEXTURE                               = $1702;
  GL_TEXTURE_CUBE_MAP                      = $8513;
  GL_TEXTURE_BINDING_CUBE_MAP              = $8514;
  GL_TEXTURE_CUBE_MAP_POSITIVE_X           = $8515;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_X           = $8516;
  GL_TEXTURE_CUBE_MAP_POSITIVE_Y           = $8517;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Y           = $8518;
  GL_TEXTURE_CUBE_MAP_POSITIVE_Z           = $8519;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Z           = $851A;
  GL_MAX_CUBE_MAP_TEXTURE_SIZE             = $851C;
  { TextureUnit  }
  GL_TEXTURE0                              = $84C0;
  GL_TEXTURE1                              = $84C1;
  GL_TEXTURE2                              = $84C2;
  GL_TEXTURE3                              = $84C3;
  GL_TEXTURE4                              = $84C4;
  GL_TEXTURE5                              = $84C5;
  GL_TEXTURE6                              = $84C6;
  GL_TEXTURE7                              = $84C7;
  GL_TEXTURE8                              = $84C8;
  GL_TEXTURE9                              = $84C9;
  GL_TEXTURE10                             = $84CA;
  GL_TEXTURE11                             = $84CB;
  GL_TEXTURE12                             = $84CC;
  GL_TEXTURE13                             = $84CD;
  GL_TEXTURE14                             = $84CE;
  GL_TEXTURE15                             = $84CF;
  GL_TEXTURE16                             = $84D0;
  GL_TEXTURE17                             = $84D1;
  GL_TEXTURE18                             = $84D2;
  GL_TEXTURE19                             = $84D3;
  GL_TEXTURE20                             = $84D4;
  GL_TEXTURE21                             = $84D5;
  GL_TEXTURE22                             = $84D6;
  GL_TEXTURE23                             = $84D7;
  GL_TEXTURE24                             = $84D8;
  GL_TEXTURE25                             = $84D9;
  GL_TEXTURE26                             = $84DA;
  GL_TEXTURE27                             = $84DB;
  GL_TEXTURE28                             = $84DC;
  GL_TEXTURE29                             = $84DD;
  GL_TEXTURE30                             = $84DE;
  GL_TEXTURE31                             = $84DF;
  GL_ACTIVE_TEXTURE                        = $84E0;
  { TextureWrapMode }
  GL_REPEAT                                = $2901;
  GL_CLAMP_TO_EDGE                         = $812F;
  GL_MIRRORED_REPEAT                       = $8370;
  { Uniform Types }
  GL_FLOAT_VEC2                            = $8B50;
  GL_FLOAT_VEC3                            = $8B51;
  GL_FLOAT_VEC4                            = $8B52;
  GL_INT_VEC2                              = $8B53;
  GL_INT_VEC3                              = $8B54;
  GL_INT_VEC4                              = $8B55;
  GL_BOOL                                  = $8B56;
  GL_BOOL_VEC2                             = $8B57;
  GL_BOOL_VEC3                             = $8B58;
  GL_BOOL_VEC4                             = $8B59;
  GL_FLOAT_MAT2                            = $8B5A;
  GL_FLOAT_MAT3                            = $8B5B;
  GL_FLOAT_MAT4                            = $8B5C;
  GL_SAMPLER_2D                            = $8B5E;
  GL_SAMPLER_CUBE                          = $8B60;
  { Vertex Arrays }
  GL_VERTEX_ATTRIB_ARRAY_ENABLED           = $8622;
  GL_VERTEX_ATTRIB_ARRAY_SIZE              = $8623;
  GL_VERTEX_ATTRIB_ARRAY_STRIDE            = $8624;
  GL_VERTEX_ATTRIB_ARRAY_TYPE              = $8625;
  GL_VERTEX_ATTRIB_ARRAY_NORMALIZED        = $886A;
  GL_VERTEX_ATTRIB_ARRAY_POINTER           = $8645;
  GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING    = $889F;
  { Read Format }
  GL_IMPLEMENTATION_COLOR_READ_TYPE        = $8B9A;
  GL_IMPLEMENTATION_COLOR_READ_FORMAT      = $8B9B;
  { Shader Source }
  GL_COMPILE_STATUS                        = $8B81;
  GL_INFO_LOG_LENGTH                       = $8B84;
  GL_SHADER_SOURCE_LENGTH                  = $8B88;
  GL_SHADER_COMPILER                       = $8DFA;
  { Shader Binary }
    GL_SHADER_BINARY_FORMATS               = $8DF8;
  GL_NUM_SHADER_BINARY_FORMATS             = $8DF9;
  { Shader Precision-Specified Types }
  GL_LOW_FLOAT                             = $8DF0;
  GL_MEDIUM_FLOAT                          = $8DF1;
  GL_HIGH_FLOAT                            = $8DF2;
  GL_LOW_INT                               = $8DF3;
  GL_MEDIUM_INT                            = $8DF4;
  GL_HIGH_INT                              = $8DF5;
  { Framebuffer Object. }
  GL_FRAMEBUFFER                           = $8D40;
  GL_RENDERBUFFER                          = $8D41;
  GL_RGBA4                                 = $8056;
  GL_RGB5_A1                               = $8057;
  GL_RGB565                                = $8D62;
  GL_DEPTH_COMPONENT16                     = $81A5;
  GL_STENCIL_INDEX                         = $1901;
  GL_STENCIL_INDEX8                        = $8D48;
  GL_RENDERBUFFER_WIDTH                    = $8D42;
  GL_RENDERBUFFER_HEIGHT                   = $8D43;
  GL_RENDERBUFFER_INTERNAL_FORMAT          = $8D44;
  GL_RENDERBUFFER_RED_SIZE                 = $8D50;
  GL_RENDERBUFFER_GREEN_SIZE               = $8D51;
  GL_RENDERBUFFER_BLUE_SIZE                = $8D52;
  GL_RENDERBUFFER_ALPHA_SIZE               = $8D53;
  GL_RENDERBUFFER_DEPTH_SIZE               = $8D54;
  GL_RENDERBUFFER_STENCIL_SIZE             = $8D55;
  GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE    = $8CD0;
  GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME    = $8CD1;
  GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL  = $8CD2;
  GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = $8CD3;
  GL_COLOR_ATTACHMENT0                     = $8CE0;
  GL_DEPTH_ATTACHMENT                      = $8D00;
  GL_STENCIL_ATTACHMENT                    = $8D20;
  GL_NONE                                  = 0;
  GL_FRAMEBUFFER_COMPLETE                  = $8CD5;
  GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT     = $8CD6;
  GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = $8CD7;
  GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS     = $8CD9;
  GL_FRAMEBUFFER_UNSUPPORTED               = $8CDD;
  GL_FRAMEBUFFER_BINDING                   = $8CA6;
  GL_RENDERBUFFER_BINDING                  = $8CA7;
  GL_MAX_RENDERBUFFER_SIZE                 = $84E8;
  GL_INVALID_FRAMEBUFFER_OPERATION         = $0506;

type
  // basic types
  GLvoid                                   = pointer;
  GLchar                                   = char;
  GLenum                                   = dword;
  GLboolean                                = byte;
  GLbitfield                               = dword;
  GLbyte                                   = khronos_int8_t;
  GLshort                                  = smallint;
  GLint                                    = longint;
  GLsizei                                  = longint;
  GLubyte                                  = khronos_uint8_t;
  GLushort                                 = word;
  GLuint                                   = dword;
  GLfloat                                  = khronos_float_t;
  GLclampf                                 = khronos_float_t;
  GLfixed                                  = khronos_int32_t;
  { GL types for handling large vertex buffer objects }
  GLintptr                                 = khronos_intptr_t;
  GLsizeiptr                               = khronos_ssize_t;


const
  // of basic types
  GL_FALSE                                 = GLboolean (0);
  GL_TRUE                                  = GLBoolean (1);

type
  // forward declarations
  PGLchar                                  = ^GLchar;
  PGLvoid                                  = ^GLvoid;
  PGLuint                                  = ^GLuint;
  PGLsizei                                 = ^GLsizei;
  PGLint                                   = ^GLint;
  PGLenum                                  = ^GLenum;
  PGLboolean                               = ^GLboolean;
  PGLfloat                                 = ^GLfloat;
  PGLubyte                                 = ^GLubyte;
  PPGLvoid                                 = ^PGLvoid;
  PPGLchar                                 = ^PGLchar;

procedure glActiveTexture (texture : GLenum); cdecl; external;
procedure glAttachShader (_program : GLuint; shader : GLuint); cdecl; external;
procedure glBindAttribLocation (_program : GLuint; index : GLuint; const name : PGLchar); cdecl; external;
procedure glBindBuffer (target : GLenum; buffer : GLuint); cdecl; external;
procedure glBindFramebuffer (target : GLenum; framebuffer : GLuint); cdecl; external;
procedure glBindRenderbuffer (target : GLenum; renderbuffer : GLuint); cdecl; external;
procedure glBindTexture (target : GLenum; texture : GLuint); cdecl; external;
procedure glBlendColor (red : GLclampf; green : GLclampf; blue : GLclampf; alpha : GLclampf); cdecl; external;
procedure glBlendEquation (mode : GLenum); cdecl; external;
procedure glBlendEquationSeparate (modeRGB : GLenum; modeAlpha : GLenum); cdecl; external;
procedure glBlendFunc (sfactor : GLenum; dfactor : GLenum); cdecl; external;
procedure glBlendFuncSeparate (srcRGB : GLenum; dstRGB : GLenum; srcAlpha : GLenum; dstAlpha : GLenum); cdecl; external;
procedure glBufferData (target : GLenum; size : GLsizeiptr; const data : PGLvoid; usage : GLenum); cdecl; external;
procedure glBufferSubData (target : GLenum; offset : GLintptr; size : GLsizeiptr; const data : PGLvoid); cdecl; external;
function glCheckFramebufferStatus (target : GLenum) : GLenum; cdecl; external;
procedure glClear (mask : GLbitfield); cdecl; external;
procedure glClearColor (red : GLclampf; green : GLclampf; blue : GLclampf; alpha : GLclampf); cdecl; external;
procedure glClearDepthf (depth : GLclampf); cdecl; external;
procedure glClearStencil (s : GLint); cdecl; external;
procedure glColorMask (red : GLboolean; green : GLboolean; blue : GLboolean; alpha : GLboolean); cdecl; external;
procedure glCompileShader (shader : GLuint); cdecl; external;
procedure glCompressedTexImage2D (target : GLenum; level : GLint; internalformat : GLenum; width : GLsizei; height : GLsizei; border : GLint; imageSize : GLsizei; const data : PGLvoid); cdecl; external;
procedure glCompressedTexSubImage2D (target : GLenum; level : GLint; xoffset : GLint; yoffset : GLint; width : GLsizei; height : GLsizei; format : GLenum; imageSize : GLsizei; const data : PGLvoid); cdecl; external;
procedure glCopyTexImage2D (target : GLenum; level : GLint; internalformat : GLenum; x : GLint; y : GLint; width : GLsizei; height : GLsizei; border : GLint); cdecl; external;
procedure glCopyTexSubImage2D (target : GLenum; level : GLint; xoffset : GLint; yoffset : GLint; x : GLint; y : GLint; width : GLsizei; height : GLsizei); cdecl; external;
function glCreateProgram : GLuint; cdecl; external;
function glCreateShader (_type : GLenum) : GLuint; cdecl; external;
procedure glCullFace (mode : GLenum); cdecl; external;
procedure glDeleteBuffers (n : GLsizei; const buffers : PGLuint); cdecl; external;
procedure glDeleteFramebuffers (n : GLsizei; const framebuffers : PGLuint); cdecl; external;
procedure glDeleteProgram (_program : GLuint); cdecl; external;
procedure glDeleteRenderbuffers (n : GLsizei; const renderbuffers : PGLuint); cdecl; external;
procedure glDeleteShader (shader : GLuint); cdecl; external;
procedure glDeleteTextures (n : GLsizei; const textures : PGLuint); cdecl; external;
procedure glDepthFunc (func : GLenum); cdecl; external;
procedure glDepthMask (flag : GLboolean); cdecl; external;
procedure glDepthRangef (zNear : GLclampf; zFar : GLclampf); cdecl; external;
procedure glDetachShader (_program : GLuint; shader : GLuint); cdecl; external;
procedure glDisable (cap : GLenum); cdecl; external;
procedure glDisableVertexAttribArray (index : GLuint); cdecl; external;
procedure glDrawArrays (mode : GLenum; first : GLint; count : GLsizei); cdecl; external;
procedure glDrawElements (mode : GLenum; count : GLsizei; _type : GLenum; const indices : PGLvoid); cdecl; external;
procedure glEnable (cap : GLenum); cdecl; external;
procedure glEnableVertexAttribArray (index : GLuint); cdecl; external;
procedure glFinish; cdecl; external;
procedure glFlush; cdecl; external;
procedure glFramebufferRenderbuffer (target : GLenum; attachment : GLenum; renderbuffertarget : GLenum; renderbuffer : GLuint); cdecl; external;
procedure glFramebufferTexture2D (target : GLenum; attachment : GLenum; textarget : GLenum; texture : GLuint; level : GLint); cdecl; external;
procedure glFrontFace (mode : GLenum); cdecl; external;
procedure glGenBuffers (n : GLsizei; buffers : PGLuint); cdecl; external;
procedure glGenerateMipmap (target : GLenum); cdecl; external;
procedure glGenFramebuffers (n : GLsizei; framebuffers : PGLuint); cdecl; external;
procedure glGenRenderbuffers (n : GLsizei; renderbuffers : PGLuint); cdecl; external;
procedure glGenTextures (n : GLsizei; textures : PGLuint); cdecl; external;
procedure glGetActiveAttrib (_program : GLuint; index : GLuint; bufsize : GLsizei; length : PGLsizei; Size : PGLint; _type : PGLenum; name : PGLchar); cdecl; external;
procedure glGetActiveUniform (_program : GLuint; index : GLuint; bufsize : GLsizei; length : PGLsizei; Size : PGLint; _type : PGLenum; name : PGLchar); cdecl; external;
procedure glGetAttachedShaders (_program : GLuint; maxcount : GLsizei; count : PGLsizei; shaders : PGLuint); cdecl; external;
function glGetAttribLocation (_program : GLuint; const name : PGLchar) : integer; cdecl; external;
procedure glGetBooleanv (pname : GLenum; params : PGLboolean); cdecl; external;
procedure glGetBufferParameteriv (target : GLenum; pname : GLenum; params : PGLint); cdecl; external;
function glGetError : GLenum; cdecl; external;
procedure glGetFloatv (pname : GLenum; params : PGLfloat); cdecl; external;
procedure glGetFramebufferAttachmentParameteriv (target : GLenum; attachment : GLenum; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetIntegerv (pname : GLenum; params : PGLint); cdecl; external;
procedure glGetProgramiv (_program : GLuint; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetProgramInfoLog (_program : GLuint; bufsize : GLsizei; length : PGLsizei; infolog : PGLchar); cdecl; external;
procedure glGetRenderbufferParameteriv (target : GLenum; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetShaderiv (shader : GLuint; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetShaderInfoLog (shader : GLuint; bufsize : GLsizei; length : PGLsizei; infolog : PGLchar); cdecl; external;
procedure glGetShaderPrecisionFormat (shadertype : GLenum; precisiontype : GLenum; range : PGLint; precision : PGLint); cdecl; external;
procedure glGetShaderSource (shader : GLuint; bufsize : GLsizei; length : PGLsizei; source : PGLchar); cdecl; external;
function glGetString (name : GLenum) : PGLubyte; cdecl; external;
procedure glGetTexParameterfv (target : GLenum; pname : GLenum; params : PGLfloat); cdecl; external;
procedure glGetTexParameteriv (target : GLenum; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetUniformfv (_program : GLuint; location : GLint; params : PGLfloat); cdecl; external;
procedure glGetUniformiv (_program : GLuint; location : GLint; params : PGLint); cdecl; external;
function glGetUniformLocation (_program : GLuint; const name : PGLChar) : integer; cdecl; external;
procedure glGetVertexAttribfv (index : GLuint; pname : GLenum; params : PGLfloat); cdecl; external;
procedure glGetVertexAttribiv (index : GLuint; pname : GLenum; params : PGLint); cdecl; external;
procedure glGetVertexAttribPointerv (index : GLuint; pname : GLenum; _pointer : PPGLvoid); cdecl; external;
procedure glHint (target : GLenum; mode : GLenum); cdecl; external;
function glIsBuffer (buffer : GLuint) : GLboolean; cdecl; external;
function glIsEnabled (cap : GLenum) : GLboolean; cdecl; external;
function glIsFramebuffer (framebuffer : GLuint) : GLboolean; cdecl; external;
function glIsProgram (_program : GLuint) : GLboolean; cdecl; external;
function glIsRenderbuffer (renderbuffer : GLuint) : GLboolean; cdecl; external;
function glIsShader (shader : GLuint) : GLboolean; cdecl; external;
function glIsTexture (texture : GLuint) : GLboolean; cdecl; external;
procedure glLineWidth (width : GLfloat); cdecl; external;
procedure glLinkProgram (_program : GLuint); cdecl; external;
procedure glPixelStorei (pname : GLenum; param : GLint); cdecl; external;
procedure glPolygonOffset (factor : GLfloat; units : GLfloat); cdecl; external;
procedure glReadPixels (x : GLint; y : GLint; width : GLsizei; height : GLsizei; format : GLenum; _type : GLenum; pixels : PGLvoid); cdecl; external;
procedure glReleaseShaderCompiler; cdecl; external;
procedure glRenderbufferStorage (target : GLenum; internalformat : GLenum; width : GLsizei; height : GLsizei); cdecl; external;
procedure glSampleCoverage (value : GLclampf; invert : GLboolean); cdecl; external;
procedure glScissor (x : GLint; y : GLint; width : GLsizei; height : GLsizei); cdecl; external;
procedure glShaderBinary (n : GLsizei; const shaders : PGLuint; binaryformat : GLenum; const binary : PGLvoid; length : GLsizei); cdecl; external;
procedure glShaderSource (shader : GLuint; count : GLsizei; const _string : PPGLchar; const length : PGLint); cdecl; external;
procedure glStencilFunc (func : GLenum; ref : GLint; mask : GLuint); cdecl; external;
procedure glStencilFuncSeparate (face : GLenum; func : GLenum; ref : GLint; mask : GLuint); cdecl; external;
procedure glStencilMask (mask : GLuint); cdecl; external;
procedure glStencilMaskSeparate (face : GLenum; mask : GLuint); cdecl; external;
procedure glStencilOp (fail : GLenum; zfail : GLenum; zpass : GLenum); cdecl; external;
procedure glStencilOpSeparate (face : GLenum; fail : GLenum; zfail : GLenum; zpass : GLenum); cdecl; external;
procedure glTexImage2D (target : GLenum; level : GLint; internalformat : GLint; width : GLsizei; height : GLsizei; border : GLint; format : GLenum; _type : GLenum; const pixels : PGLvoid); cdecl; external;
procedure glTexParameterf (target : GLenum; pname : GLenum; param : GLfloat); cdecl; external;
procedure glTexParameterfv (target : GLenum; pname : GLenum; const params : PGLfloat); cdecl; external;
procedure glTexParameteri (target : GLenum; pname : GLenum; params : GLint); cdecl; external;
procedure glTexParameteriv (target : GLenum; pname : GLenum; const params : PGLint); cdecl; external;
procedure glTexSubImage2D (target : GLenum; level : GLint; xoffset : GLint; yoffset : GLint; width : GLsizei; height : GLsizei; format : GLenum; _type : GLenum; const pixels : PGLvoid); cdecl; external;
procedure glUniform1f (location : GLint; x : GLfloat); cdecl; external;
procedure glUniform1fv (location : GLint; count : GLsizei; const v : PGLfloat); cdecl; external;
procedure glUniform1i (location : GLint; x : GLint); cdecl; external;
procedure glUniform1iv (location : GLint; count : GLsizei; const v : PGLint); cdecl; external;
procedure glUniform2f (location : GLint; x : GLfloat; y : GLfloat); cdecl; external;
procedure glUniform2fv (location : GLint; count : GLsizei; const v : PGLfloat); cdecl; external;
procedure glUniform2i (location : GLint; x : GLint; y : GLint); cdecl; external;
procedure glUniform2iv (location : GLint; count : GLsizei; const v : PGLint); cdecl; external;
procedure glUniform3f (location : GLint; x : GLfloat; Y : GLfloat; z : GLfloat); cdecl; external;
procedure glUniform3fv (location : GLint; count : GLsizei; const v : PGLfloat); cdecl; external;
procedure glUniform3i (location : GLint; x : GLint; y : GLint; z : GLint); cdecl; external;
procedure glUniform3iv (location : GLint; count : GLsizei; const v : PGLint); cdecl; external;
procedure glUniform4f (location : GLint; x : GLfloat; y : GLfloat; z : GLfloat; w : GLfloat); cdecl; external;
procedure glUniform4fv (location : GLint; count : GLsizei; const v : PGLfloat); cdecl; external;
procedure glUniform4i (location : GLint; x : GLint; y : GLint; z : GLint; w : GLint); cdecl; external;
procedure glUniform4iv (location : GLint; count : GLsizei; const v : PGLint); cdecl; external;
procedure glUniformMatrix2fv (location : GLint; count : GLsizei; transpose : GLboolean; const value : PGLfloat); cdecl; external;
procedure glUniformMatrix3fv (location : GLint; count : GLsizei; transpose : GLboolean; const value : PGLfloat); cdecl; external;
procedure glUniformMatrix4fv (location : GLint; count : GLsizei; transpose : GLboolean; const value : PGLfloat); cdecl; external;
procedure glUseProgram (_program : GLuint); cdecl; external;
procedure glValidateProgram (_program : GLuint); cdecl; external;
procedure glVertexAttrib1f (indx : GLuint; x : GLfloat); cdecl; external;
procedure glVertexAttrib1fv (indx : GLuint; const values : PGLfloat); cdecl; external;
procedure glVertexAttrib2f (indx : GLuint; x : GLfloat; y : GLfloat); cdecl; external;
procedure glVertexAttrib2fv (indx : GLuint; const values : PGLfloat); cdecl; external;
procedure glVertexAttrib3f (indx : GLuint; x : GLfloat; y : GLfloat; z : GLfloat); cdecl; external;
procedure glVertexAttrib3fv (indx : GLuint; const values : PGLfloat); cdecl; external;
procedure glVertexAttrib4f (indx : GLuint; x : GLfloat; y : GLfloat; z : GLfloat; w : GLfloat); cdecl; external;
procedure glVertexAttrib4fv (indx : GLuint; const values : PGLfloat); cdecl; external;
procedure glVertexAttribPointer (indx : GLuint; size : GLint; _type : GLenum; normalized : GLboolean; stride : GLsizei; const ptr : PGLvoid); cdecl; external;
procedure glViewport (x : GLfloat; y : GLfloat; width : GLsizei; height : GLsizei); cdecl; external;

implementation

end.

