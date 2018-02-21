unit uWFC;

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
  OPENWFC_VERSION_1_0                      = 1;
  WFC_NONE                                 = 0;
  WFC_FALSE                                = 0;
  WFC_TRUE                                 = 1;
  WFC_BOOLEAN_FORCE_32BIT                  = $7FFFFFFF;
  WFC_DEFAULT_DEVICE_ID                    = 0;

  WFC_ERROR_NONE                           = 0;
  WFC_ERROR_OUT_OF_MEMORY                  = $7001;
  WFC_ERROR_ILLEGAL_ARGUMENT               = $7002;
  WFC_ERROR_UNSUPPORTED                    = $7003;
  WFC_ERROR_BAD_ATTRIBUTE                  = $7004;
  WFC_ERROR_IN_USE                         = $7005;
  WFC_ERROR_BUSY                           = $7006;
  WFC_ERROR_BAD_DEVICE                     = $7007;
  WFC_ERROR_BAD_HANDLE                     = $7008;
  WFC_ERROR_INCONSISTENCY                  = $7009;
  WFC_ERROR_FORCE_32BIT                    = $7FFFFFFF;

  WFC_DEVICE_FILTER_SCREEN_NUMBER          = $7020;
  WFC_DEVICE_FILTER_FORCE_32BIT            = $7FFFFFFF;

  WFC_DEVICE_CLASS                         = $7030;
  WFC_DEVICE_ID                            = $7031;
  WFC_DEVICE_FORCE_32BIT                   = $7FFFFFFF;

  WFC_DEVICE_CLASS_FULLY_CAPABLE           = $7040;
  WFC_DEVICE_CLASS_OFF_SCREEN_ONLY         = $7041;
  WFC_DEVICE_CLASS_FORCE_32BIT             = $7FFFFFFF;

  WFC_CONTEXT_TYPE                         = $7051;
  WFC_CONTEXT_TARGET_HEIGHT                = $7052;
  WFC_CONTEXT_TARGET_WIDTH                 = $7053;
  WFC_CONTEXT_LOWEST_ELEMENT               = $7054;
  WFC_CONTEXT_ROTATION                     = $7061;
  WFC_CONTEXT_BG_COLOR                     = $7062;
  WFC_CONTEXT_FORCE_32BIT                  = $7FFFFFFF;

  WFC_CONTEXT_TYPE_ON_SCREEN               = $7071;
  WFC_CONTEXT_TYPE_OFF_SCREEN              = $7072;
  WFC_CONTEXT_TYPE_FORCE_32BIT             = $7FFFFFFF;

  WFC_ROTATION_0                           = $7081;
  WFC_ROTATION_90                          = $7082;
  WFC_ROTATION_180                         = $7083;
  WFC_ROTATION_270                         = $7084;
  WFC_ROTATION_FORCE_32BIT                 = $7FFFFFFF;

  WFC_ELEMENT_DESTINATION_RECTANGLE        = $7101;
  WFC_ELEMENT_SOURCE                       = $7102;
  WFC_ELEMENT_SOURCE_RECTANGLE             = $7103;
  WFC_ELEMENT_SOURCE_FLIP                  = $7104;
  WFC_ELEMENT_SOURCE_ROTATION              = $7105;
  WFC_ELEMENT_SOURCE_SCALE_FILTER          = $7106;
  WFC_ELEMENT_TRANSPARENCY_TYPES           = $7107;
  WFC_ELEMENT_GLOBAL_ALPHA                 = $7108;
  WFC_ELEMENT_MASK                         = $7109;
  WFC_ELEMENT_FORCE_32BIT                  = $7FFFFFFF;

  WFC_SCALE_FILTER_NONE                    = $7151;
  WFC_SCALE_FILTER_FASTER                  = $7152;
  WFC_SCALE_FILTER_BETTER                  = $7153;
  WFC_SCALE_FILTER_FORCE_32BIT             = $7FFFFFFF;

  WFC_TRANSPARENCY_NONE                    = 0;
  WFC_TRANSPARENCY_ELEMENT_GLOBAL_ALPHA    = 1 shl 0;
  WFC_TRANSPARENCY_SOURCE                  = 1 shl 1;
  WFC_TRANSPARENCY_MASK                    = 1 shl 2;
  WFC_TRANSPARENCY_FORCE_32BIT             = $7FFFFFFF;

  WFC_VENDOR                               = $7200;
  WFC_RENDERER                             = $7201;
  WFC_VERSION                              = $7202;
  WFC_EXTENSIONS                           = $7203;
  WFC_STRINGID_FORCE_32BIT                 = $7FFFFFFF;

type
  WFCboolean                               = LongWord;
  WFCint                                   = khronos_int32_t;
  WFCfloat                                 = khronos_float_t;
  WFCbitfield                              = khronos_uint32_t;
  WFCHandle                                = khronos_uint32_t;
  WFCEGLDisplay                            = pointer; // EGLDisplay;
  WFCEGLSync                               = pointer;

  WFCNativeStreamType                      = WFCHandle;
  WFCDevice                                = WFCHandle;
  WFCContext                               = WFCHandle;
  WFCSource                                = WFCHandle;
  WFCMask                                  = WFCHandle;
  WFCElement                               = WFCHandle;

  WFCErrorCode                             = LongWord;
  WFCDeviceFilter                          = LongWord;
  WFCDeviceAttrib                          = LongWord;
  WFCDeviceClass                           = LongWord;
  WFCContextAttrib                         = LongWord;
  WFCContextType                           = LongWord;
  WFCRotation                              = LongWord;
  WFCElementAttrib                         = LongWord;
  WFCScaleFilter                           = LongWord;
  WFCTransparencyType                      = LongWord;
  WFCStringID                              = LongWord;

  PWFCint                                  = ^WFCint;
  PWFCfloat                                = ^WFCfloat;

const
  // of basic typs
  WFC_INVALID_HANDLE                       = WFCHandle (0);
  WFC_MAX_INT                              = WFCint (16777216);
//  WFC_MAX_FLOAT                            = WFCfloat (16777216);

(* Device *)
function wfcEnumerateDevices (deviceIds : PWFCint; deviceIdsCount : WFCint;
                              const filterList : PWFCint) : WFCint; cdecl; external;
function wfcCreateDevice (deviceId : WFCint; const attribList : PWFCint) : WFCDevice; cdecl; external;
function wfcGetError (dev : WFCDevice) : WFCErrorCode; cdecl; external;
function wfcGetDeviceAttribi (dev : WFCDevice; attrib : WFCDeviceAttrib) : WFCint; cdecl; external;
function wfcDestroyDevice (dev : WFCDevice) : WFCErrorCode; cdecl; external;

(* Context *)
function wfcCreateOnScreenContext (dev : WFCDevice;
                                   screenNumber : WFCint;
                                   const attribList : PWFCint) : WFCContext; cdecl; external;
function wfcCreateOffScreenContext (dev : WFCDevice;
                                    stream : WFCNativeStreamType;
                                    const attribList : PWFCint) : WFCContext; cdecl; external;
procedure wfcCommit (dev : WFCDevice; ctx : WFCContext; wait : WFCboolean); cdecl; external;
function wfcGetContextAttribi (dev : WFCDevice; ctx : WFCContext;
                               attrib : WFCContextAttrib) : WFCint; cdecl; external;
procedure wfcGetContextAttribfv (dev : WFCDevice; ctx : WFCContext;
                                 attrib : WFCContextAttrib; count : WFCint; values : PWFCfloat); cdecl; external;
procedure wfcSetContextAttribi (dev : WFCDevice; ctx : WFCContext;
                                attrib : WFCContextAttrib; value : WFCint); cdecl; external;
procedure wfcSetContextAttribfv (dev : WFCDevice; ctx : WFCContext;
                                 attrib : WFCContextAttrib;
                                 count : WFCint; const values : PWFCfloat); cdecl; external;
procedure wfcDestroyContext (dev : WFCDevice; ctx : WFCContext); cdecl; external;

(* Source *)
function wfcCreateSourceFromStream (dev : WFCDevice; ctx : WFCContext;
                                    stream : WFCNativeStreamType;
                                    const attribList : PWFCint) : WFCSource; cdecl; external;
procedure wfcDestroySource (dev : WFCDevice; src : WFCSource); cdecl; external;

(* Mask *)
function wfcCreateMaskFromStream (dev : WFCDevice;  ctx : WFCContext;
                                  stream : WFCNativeStreamType;
                                  const attribList : PWFCint) : WFCMask; cdecl; external;
procedure wfcDestroyMask (dev : WFCDevice; mask : WFCmask); cdecl; external;

(* Element *)
function wfcCreateElement (dev : WFCDevice; ctx : WFCContext;
                           const attribList : PWFCint) : WFCElement; cdecl; external;
function wfcGetElementAttribi (dev : WFCDevice; element : WFCElement;
                               attrib : WFCElementAttrib) : WFCint; cdecl; external;
function wfcGetElementAttribf (dev : WFCDevice; element : WFCElement;
                               attrib : WFCElementAttrib) : WFCfloat; cdecl; external;
procedure wfcGetElementAttribiv (dev : WFCDevice; element : WFCElement;
                                 attrib : WFCElementAttrib; count : WFCint; values : PWFCint); cdecl; external;
procedure wfcGetElementAttribfv (dev : WFCDevice; element : WFCElement;
                                 attrib : WFCElementAttrib; count : WFCint; values : PWFCfloat); cdecl; external;
procedure wfcSetElementAttribi (dev : WFCDevice; element : WFCElement;
                                attrib : WFCElementAttrib; value : WFCint); cdecl; external;
procedure wfcSetElementAttribf (dev : WFCDevice; element : WFCElement;
                                attrib : WFCElementAttrib; value : WFCfloat); cdecl; external;
procedure wfcSetElementAttribiv (dev : WFCDevice; element : WFCElement;
                                 attrib : WFCElementAttrib;
                                 count : WFCint; const values : PWFCint); cdecl; external;
procedure wfcSetElementAttribfv (dev : WFCDevice; element : WFCElement;
                                 attrib : WFCElementAttrib;
                                 count : WFCint; const values : PWFCfloat); cdecl; external;
procedure wfcInsertElement (dev : WFCDevice; element : WFCElement;
                            subordinate : WFCElement); cdecl; external;
procedure wfcRemoveElement (dev : WFCDevice; element : WFCElement); cdecl; external;
function wfcGetElementAbove (dev : WFCDevice; element : WFCElement) : WFCElement; cdecl; external;
function wfcGetElementBelow (dev : WFCDevice; element : WFCElement) : WFCElement; cdecl; external;
procedure wfcDestroyElement (dev : WFCDevice; element : WFCElement); cdecl; external;

(* Rendering *)
procedure wfcActivate (dev : WFCDevice; ctx : WFCContext); cdecl; external;
procedure wfcDeactivate (dev : WFCDevice; ctx : WFCContext); cdecl; external;
procedure wfcCompose (dev : WFCDevice; ctx : WFCContext; wait : WFCboolean); cdecl; external;
procedure wfcFence (dev : WFCDevice; ctx : WFCContext; dpy : WFCEGLDisplay;
                   sync : WFCEGLSync); cdecl; external;

(* Renderer and extension information *)
function wfcGetStrings (dev : WFCDevice;
                        name : WFCStringID;
                        strings : PPChar;
                        stringsCount : WFCint) : WFCint; cdecl; external;
function wfcIsExtensionSupported (dev : WFCDevice; const _string : PChar) : WFCboolean; cdecl; external;

implementation

end.

