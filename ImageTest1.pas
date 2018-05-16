program ImageTest1;

{$mode delphi}{$H+}
{$hints off}
{$notes off}

{ OMX Image Test Program 1 }
{ copied / inspired from raspberry pi gpu audio video programming by Jan Mewmarch
{ pjde 2018 }

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads, VC4,
  SysUtils, Winsock2, uIL_Client, uOMX, SysCalls,
  Classes, Console, uTFTP, uLog,
  Ultibo
  { Add additional units here };

const
  ny : array [boolean] of string = ('NO', 'YES');

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  ImageStream : TMemoryStream;
  ch : char;
  client : PILCLIENT_T;
  comps : array of PCOMPONENT_T;
  ext : string;
  eos : boolean;

// General routines
procedure Log1 (s : string);
begin
  ConsoleWindowWriteLn (Console1, s);
end;

procedure Log2 (s : string);
begin
  ConsoleWindowWriteLn (Console2, s);
end;

procedure Log3 (s : string);
begin
  ConsoleWindowWriteLn (Console3, s);
end;

procedure Msg2 (Sender : TObject; s : string);
begin
  Log2 ('TFTP - ' + s);
end;

function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

// Image specific routines
function ComponentName (comp : PCOMPONENT_T) : string;
var
  n : array [0..127] of char;
  cv, sv : OMX_VERSIONTYPE;
  cu : OMX_UUIDTYPE;
begin
  Result := '';
  n[0] := #0;
  FillChar (n, 128, 0);
  if OMX_GetComponentVersion (ilclient_get_handle (comp), n, @cv, @sv, @cu) = OMX_ErrorNone then
    begin
      Result := string (n);
      Result := Copy (Result, 14, length (Result) - 13); // remove OMX.Broadcom.
    end;
end;

procedure PrintState (handle : OMX_HANDLETYPE);
var
  state : OMX_STATETYPE;
  err : OMX_ERRORTYPE;
begin
  err := OMX_GetState (handle, @state);
  if (err <> OMX_ErrorNone) then
    Log ('Error getting state.')
  else
    case state of
      OMX_StateLoaded           : Log ('State Loaded.');
      OMX_StateIdle             : Log ('State Idle.');
      OMX_StateExecuting        : Log ('State Executing.');
      OMX_StatePause            : Log ('State Pause.');
      OMX_StateWaitForResources : Log ('State Wait.');
      OMX_StateInvalid          : Log ('State Invalid.');
      else                        Log ('State Unknown');
      end;
end;

procedure OpenFile (fn : string);
var
  f : TFileStream;
  id : string;
  w : Word;
  l, s : LongWord;
begin
  ImageStream.Clear;
  try
    ext := UpperCase (ExtractFileExt (fn));
    Log ('Opening file ' + fn + ' ext ' + ext);
    f := TFileStream.Create (fn, fmOpenRead);
    f.Seek (0, soFromBeginning);
    ImageStream.CopyFrom (f, 0);
    f.Free;
    Log ('Image Stream ' + ImageStream.Size.ToString + ' bytes long.');
  except
    on e : exception do
      Log ('Error opening "' + fn + '". ' + e.Message);
  end;
end;

procedure port_settings_callback (userdata : pointer; comp : PCOMPONENT_T; data : LongWord); cdecl;
begin
  Log (ComponentName (comp) + ' : Port Settings Changed.');
end;

procedure empty_buffer_callback (userdata : pointer; comp : PCOMPONENT_T; data : LongWord); cdecl;
begin
//
end;

procedure fill_buffer_callback (userdata : pointer; comp : PCOMPONENT_T; data : LongWord); cdecl;
begin
//
end;

procedure eos_callback (userdata : pointer; comp : PCOMPONENT_T; data : LongWord); cdecl;
begin
  Log (ComponentName (comp) + ' : End Of Stream Detected.');
  eos := true;
end;

procedure error_callback (userdata : pointer; comp : PCOMPONENT_T; data : LongWord); cdecl;
begin
  Log (ComponentName (comp) + ' : ' + OMX_ErrToStr (data));
end;

function read_into_buffer_and_empty (comp : PCOMPONENT_T;
                                     buff : POMX_BUFFERHEADERTYPE) : OMX_ERRORTYPE;
var
  buff_size : integer;
  read : integer;
begin
  buff_size := buff.nAllocLen;
  read := ImageStream.Size - ImageStream.Position;
  if read > buff_size then read := buff_size;
  ImageStream.Read (buff.pBuffer^, read);
  buff.nFilledLen := read;
  if ImageStream.Position = ImageStream.Size then
    buff.nFlags := buff.nFlags or OMX_BUFFERFLAG_EOS;
  Result := OMX_EmptyThisBuffer (ilclient_get_handle (comps[0]), buff);
end;

procedure OMXCheck (n : string; r : OMX_ERRORTYPE);
begin
  Log (n + ' ' + OMX_ErrToStr (r));
  if r <> OMX_ErrorNone then raise Exception.Create (n + ' ' + OMX_ErrToStr (r));
end;

procedure ILCheck (n : string; e : integer);
begin
  if e = 0 then Log (n + ' OK') else Log (n + ' ' + ' Failed');
  if e <> 0 then raise Exception.Create (n + ' Failed');
end;

procedure DisplayFile;
var
  res : integer;
  param : OMX_IMAGE_PARAM_PORTFORMATTYPE;
  hdr : POMX_BUFFERHEADERTYPE;
  tunnel : TUNNEL_T;
begin
  if Imagestream = nil then exit;
  if Imagestream.Size = 0 then exit;
  Imagestream.Seek (0, soFromBeginning);
  SetLength (comps, 3);
  client := nil;
  eos := false;
  for res := low (comps) to high (comps) do comps[res] := nil;
  // initialise OMX and IL client
  try
    OMXCheck ('OMX Init', OMX_Init);
    client := ilclient_init;
    // set callbacks
    ilclient_set_port_settings_callback (client, @port_settings_callback, nil);
    ilclient_set_empty_buffer_done_callback (client, @empty_buffer_callback, nil);
    ilclient_set_fill_buffer_done_callback (client, @fill_buffer_callback, nil);
    ilclient_set_eos_callback (client, @eos_callback, nil);
    ilclient_set_error_callback (client, @error_callback, nil);
    // create decoder
    ILCheck ('Create decoder', ilclient_create_component (client, @comps[0], 'image_decode', ILCLIENT_DISABLE_ALL_PORTS));
    ILCheck ('Change decoder to idle', ilclient_change_component_state (comps[0], OMX_StateIdle));
    // set decoder input as jpeg or png
    FillChar (param, sizeof (OMX_IMAGE_PARAM_PORTFORMATTYPE), 0);
    param.nSize := sizeof (OMX_IMAGE_PARAM_PORTFORMATTYPE);
    param.nVersion.nVersion := OMX_VERSION;
    param.nPortIndex := 320;
    if ext = '.PNG' then
      param.eCompressionFormat := OMX_IMAGE_CodingPNG
    else
      param.eCompressionFormat := OMX_IMAGE_CodingJPEG;
    OMXCheck ('Set JPEG / PNG', OMX_SetParameter (ilclient_get_handle (comps[0]),
                          OMX_IndexParamImagePortFormat, @param));
    ILCheck ('Create render', ilclient_create_component (client, @comps[1], 'video_render', ILCLIENT_DISABLE_ALL_PORTS));
    ILCheck ('Change render to idle', ilclient_change_component_state (comps[1], OMX_StateIdle));
    ilclient_enable_port_buffers (comps[0], 320, nil, nil, nil);
    ilclient_enable_port (comps[0], 320);
    ILCheck ('Change Executing', ilclient_change_component_state (comps[0], OMX_StateExecuting));
    hdr := ilclient_get_input_buffer (comps[0], 320, 1);
    if hdr <> nil then read_into_buffer_and_empty (comps[0], hdr);
    if ImageStream.Position = ImageStream.Size then  // if all file has been read, then have to re-read this first block
      ImageStream.Seek(0, soFromBeginning);
    // wait for first input block to set params for output port
    ilclient_wait_for_event (comps[0],
			    OMX_EventPortSettingsChanged,
			    321, 0, 0, 1,
			    ILCLIENT_EVENT_ERROR or ILCLIENT_PARAMETER_CHANGED, 5);
    set_tunnel (@tunnel, comps[0], 321, comps[1], 90);
    ILCheck ('Setup Tunnel', ilclient_setup_tunnel (@tunnel, 0, 0));
    // enable decoder
    OMX_SendCommand (ilclient_get_handle (comps[0]), OMX_CommandPortEnable, 321, nil);
    ilclient_enable_port (comps[0], 321);
    // enable render
    ilclient_enable_port (comps[1], 90);
    // set both components to executing state
    ILCheck ('Decode to Executing', ilclient_change_component_state (comps[0], OMX_StateExecuting));
    ILCheck ('Render to Executing', ilclient_change_component_state (comps[1], OMX_StateExecuting));
    while ImageStream.Position < ImageStream.Size do
      begin
        hdr := ilclient_get_input_buffer (comps[0], 320, 1);
        if hdr <> nil then read_into_buffer_and_empty (comps[0], hdr);
      end;
    // wait for eos
    ilclient_wait_for_event (comps[1],
		                         OMX_EventBufferFlag,
		                         90, 0, OMX_BUFFERFLAG_EOS, 0,
		                         ILCLIENT_BUFFER_FLAG_EOS, 10000);
    Log('EOS on render');
    ConsoleGetKey (ch, nil);  // wait until key pressed
  finally
    ilclient_change_component_state (comps[0], OMX_StateLoaded);
    ilclient_cleanup_components (@comps[0]);
    ilclient_destroy (client);
    client := nil;
    OMX_DeInit;
    end;
  Log ('End of DisplayImage ...');
end;


begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('Image Test 1 using OpenMax (OMX).');
  WaitForSDDrive;
  Log2 ('SD Drive ready.');
  Log2 ('');
  Log3 ('C - Clear.');
  Log3 ('1 - Load JPEG File.');
  Log3 ('2 - Load PNG File.');
  Log3 ('3 - Display File.');
  Log3 ('');
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');
  Log3 ('');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' put kernel7.img"');
  SetOnMsg (@Msg2);
  BCMHostInit;
  ImageStream := TMemoryStream.Create;
  ch := #0;
  while true do
    begin
      if ConsoleGetKey (ch, nil) then
        case ch of
          'C' : ConsoleWindowClear (Console1);
          '1' : OpenFile ('test.jpg');
          '2' : OpenFile ('test.png');
          '3' : DisplayFile;
          'Q', 'q' : break;
          end;
    end;
  Log ('Halted.');
  ImageStream.Free;
  ThreadHalt (0);
end.

