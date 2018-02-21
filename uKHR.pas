unit uKHR;

{$mode delphi}

interface
{
 ** Copyright (c) 2008-2009 The Khronos Group Inc.
 **
 ** Permission is hereby granted, free of charge, to any person obtaining a
 ** copy of this software and/or associated documentation files (the
 ** "Materials"), to deal in the Materials without restriction, including
 ** without limitation the rights to use, copy, modify, merge, publish,
 ** distribute, sublicense, and/or sell copies of the Materials, and to
 ** permit persons to whom the Materials are furnished to do so, subject to
 ** the following conditions:
 **
 ** The above copyright notice and this permission notice shall be included
 ** in all copies or substantial portions of the Materials.
 **
 ** THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 ** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 ** MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
  }
 { Khronos platform-specific types and definitions.
  *
  * $Revision: 23298 $ on $Date: 2013-09-30 17:07:13 -0700 (Mon, 30 Sep 2013) $
  *
  * Adopters may modify this file to suit their platform. Adopters are
  * encouraged to submit platform specific modifications to the Khronos
  * group so that they can be included in future versions of this file.
  * Please submit changes by sending them to the public Khronos Bugzilla
  * (http://khronos.org/bugzilla) by filing a bug against product
  * "Khronos (general)" component "Registry".
  *
  * A predefined template which fills in some of the bug fields can be
  * reached using http://tinyurl.com/khrplatform-h-bugreport, but you
  * must create a Bugzilla login first.
  *
  *
  * See the Implementer's Guidelines for information about where this file
  * should be located on your system and for more details of its use:
  *    http://www.khronos.org/registry/implementers_guide.pdf
  *
  * This file should be included as
  *        #include <KHR/khrplatform.h>
  * by Khronos client API header files that use its types and defines.
  *
  * The types in khrplatform.h should only be used to define API-specific types.
  *
  * Types defined in khrplatform.h:
  *    khronos_int8_t              signed   8  bit
  *    khronos_uint8_t             unsigned 8  bit
  *    khronos_int16_t             signed   16 bit
  *    khronos_uint16_t            unsigned 16 bit
  *    khronos_int32_t             signed   32 bit
  *    khronos_uint32_t            unsigned 32 bit
  *    khronos_int64_t             signed   64 bit
  *    khronos_uint64_t            unsigned 64 bit
  *    khronos_intptr_t            signed   same number of bits as a pointer
  *    khronos_uintptr_t           unsigned same number of bits as a pointer
  *    khronos_ssize_t             signed   size
  *    khronos_usize_t             unsigned size
  *    khronos_float_t             signed   32 bit floating point
  *    khronos_time_ns_t           unsigned 64 bit time in nanoseconds
  *    khronos_utime_nanoseconds_t unsigned time interval or absolute time in
  *                                         nanoseconds
  *    khronos_stime_nanoseconds_t signed time interval in nanoseconds
  *    khronos_boolean_enum_t      enumerated boolean type. This should
  *      only be used as a base type when a client API's boolean type is
  *      an enum. Client APIs which use an integer or other type for
  *      booleans cannot use this as the base type for their boolean.
  *  }

uses
  Classes, SysUtils;

const
  KHRONOS_MAX_ENUM                         = $7FFFFFFF;
  KHRONOS_SUPPORT_INT64                    = 1;
  KHRONOS_SUPPORT_FLOAT                    = 1;
  KHRONOS_FALSE                            = 0;
  KHRONOS_TRUE                             = 1;
  KHRONOS_BOOLEAN_ENUM_FORCE_SIZE          = KHRONOS_MAX_ENUM;

type
  khronos_int32_t                          = int32;
  khronos_uint32_t                         = uint32;
  khronos_int64_t                          = int64;
  khronos_uint64_t                         = int64;
  khronos_int8_t                           = char;
  khronos_uint8_t                          = byte;
  khronos_int16_t                          = smallint;
  khronos_uint16_t                         = word;
  khronos_intptr_t                         = int64;
  khronos_uintptr_t                        = qword;
  khronos_ssize_t                          = int64;
  khronos_usize_t                          = qword;
  khronos_float_t                          = single;
  khronos_utime_nanoseconds_t              = khronos_uint64_t;
  khronos_stime_nanoseconds_t              = khronos_int64_t;
  khronos_boolean_enum_t                   = LongWord;

implementation

end.

