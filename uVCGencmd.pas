unit uVCGencmd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, VC4;


(*
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
*)

// General command service API

const
  GENCMDSERVICE_MSGFIFO_SIZE               = 1024;
  VC_GENCMD_VER                            = 1;


procedure vc_vchi_gencmd_init (initialise_instance : VCHI_INSTANCE_T; connections : PPVCHI_CONNECTION_T; num_connections : Longword); cdecl; external;


(* Initialise general command service. Returns it's interface number. This initialises
   the host side of the interface, it does not send anything to VideoCore. *)
function vc_gencmd_init : integer; cdecl; external;

(* Stop the service from being used. *)
procedure vc_gencmd_stop; cdecl; external;

(* Return the service number (-1 if not running). *)
function  vc_gencmd_inum : integer; cdecl; external;

(******************************************************************************
Send commands to VideoCore.
These all return 0 for success. They return VC_MSGFIFO_FIFO_FULL if there is
insufficient space for the whole message in the fifo, and none of the message is
sent.
******************************************************************************)

(* send command to general command serivce *)
function vc_gencmd_send (const _format : PChar) : integer; cdecl; varargs; external;

(* get resonse from general command service *)
function vc_gencmd_read_response (response : PChar; maxlen : integer) : integer; cdecl; external;

(* convenience function to send command and receive the response *)
function vc_gencmd (response : PChar; maxlen : integer; const _format : PChar) : integer; cdecl; varargs; external;

(* read part of a response from the general command service *)
function vc_gencmd_read_response_partial (response : PChar; nbytes : integer) : integer; cdecl; external;

(* if reading with vc_gencmd_read_response_partial end response reads with this *)
function vc_gencmd_close_response_partial : integer; cdecl; external;

(* get state of reading of response *)
function vc_gencmd_read_partial_state : integer; cdecl; external;

(******************************************************************************
Utilities to help interpret the responses.
******************************************************************************)

(* Read the value of a property=value type pair from a string (typically VideoCore's
   response to a general command). Return non-zero if found. *)
function vc_gencmd_string_property (text : PChar; const _property : PChar; vale : PPChar; length : Pinteger) : integer; cdecl; external;

(* Read the numeric value of a property=number field from a response string. Return
   non-zero if found. *)
function vc_gencmd_number_property (text : Pchar; const _property : PChar; number : Pinteger) : integer; cdecl; external;

(* Send a command until the desired response is received, the error message is detected, or the timeout *)
function vc_gencmd_until (cmd : PChar; _property : PChar; value : PChar; const error_string : PChar; timeout : integer) : integer; cdecl; external;

implementation

end.

