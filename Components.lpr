program Components;

{$mode delphi}{$H+}

{$define use_tftp}    // if PI not connected to LAN and set for DHCP then remove this

// based on working.c
// for rasberry-pi-gpu-audio-video_master
// companion code to "Raspberry PI GPU Audio Video Progamming" by Jan Newmarch.

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Ultibo, VC4,
  {$ifdef use_tftp}
  uTFTP,
  {$endif}
  Console, Winsock2, uLog, uOMX, uIL_Client
  { Add additional units here };

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  err : OMX_ERRORTYPE;
  callbacks : OMX_CALLBACKTYPE;

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

procedure printPorts (handle : OMX_HANDLETYPE; desc : string; indexType : OMX_INDEXTYPE);
var
  param : OMX_PORT_PARAM_TYPE;
  startPortNumber, endPortNumber : integer;
  nPorts : integer;
  err : OMX_ERRORTYPE;
begin
  param.nSize := 0;
  FillChar (param, sizeof (OMX_PORT_PARAM_TYPE), 0);
  param.nSize := sizeof (OMX_PORT_PARAM_TYPE);
  param.nVersion.nVersion := OMX_VERSION;
  err := OMX_GetParameter (handle, indexType, @param);
  if err <> OMX_ErrorNone then
    begin
      Log ('Error in getting image OMX_PORT_PARAM_TYPE parameter.');
      exit;
    end;
  startPortNumber := param.nStartPortNumber;
  nPorts := param.nPorts;
  endPortNumber := startPortNumber + nPorts - 1;
  if nPorts = 1 then
    Log ('  ' + desc + ' Port : ' + startPortNumber.ToString)
  else if nPorts > 1 then
    Log ('  ' + desc + ' Ports : ' + startPortNumber.ToString + '-' + endPortNumber.ToString);
end;

procedure printAvailable (name : string);
var
  err : OMX_ERRORTYPE;
  handle : OMX_HANDLETYPE;
begin
  err := OMX_GetHandle (@handle, PChar (name), nil, @callbacks);
  if err = OMX_ErrorNone then
     begin
       Log ('Component "' + name + '" available.');
       printPorts (handle, 'Audio', OMX_IndexParamAudioInit);
       printPorts (handle, 'Video', OMX_IndexParamVideoInit);
       printPorts (handle, 'Image', OMX_IndexParamImageInit);
       printPorts (handle, 'Other', OMX_IndexParamOtherInit);
     end
  else
    begin
      Log ('Component "' + name  + '" not available.');
      Log ('  Reason : "' + OMX_ErrToStr (err) + '"');
    end;
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('OpenMAX Component Listing.');
  WaitForSDDrive;
  Log3 ('SD Drive ready.');
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');

  {$ifdef use_tftp}
  Log2 ('TFTP - Enabled.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' PUT kernel7.img"');
  SetOnMsg (@Msg2);
  {$endif}

  callbacks.EventHandler := nil;
  callbacks.EmptyBufferDone := nil;
  callbacks.FillBufferDone := nil;
  BCMHostInit;
  err := OMX_Init;
  if err <> OMX_ErrorNone then
    begin
      Log ('OMX_Init failed. Error Code ' + err.ToHexString (8));
      ThreadHalt (0);
    end;

  printAvailable ('OMX.broadcom.audio_capture');
  printAvailable ('OMX.broadcom.audio_decode');
  printAvailable ('OMX.broadcom.audio_encode');
  printAvailable ('OMX.broadcom.audio_lowpower');
  printAvailable ('OMX.broadcom.audio_mixer');
  printAvailable ('OMX.broadcom.audio_processor');
  printAvailable ('OMX.broadcom.audio_render');
  printAvailable ('OMX.broadcom.audio_splitter');

  printAvailable ('OMX.broadcom.image_decode');
  printAvailable ('OMX.broadcom.image_encode');
  printAvailable ('OMX.broadcom.image_fx');
  printAvailable ('OMX.broadcom.image_read');
  printAvailable ('OMX.broadcom.image_write');
  printAvailable ('OMX.broadcom.resize');
  printAvailable ('OMX.broadcom.source');
  printAvailable ('OMX.broadcom.transition');
  printAvailable ('OMX.broadcom.write_still');

  printAvailable ('OMX.broadcom.clock');
  printAvailable ('OMX.broadcom.null_sink');
  printAvailable ('OMX.broadcom.text_schedule');
  printAvailable ('OMX.broadcom.visualisation');

  printAvailable ('OMX.broadcom.read_media');
  printAvailable ('OMX.broadcom.write_media');

  printAvailable ('OMX.broadcom.camera');
  printAvailable ('OMX.broadcom.egl_render');
  printAvailable ('OMX.broadcom.video_decode');
  printAvailable ('OMX.broadcom.video_encode');
  printAvailable ('OMX.broadcom.video_render');
  printAvailable ('OMX.broadcom.video_scheduler');
  printAvailable ('OMX.broadcom.video_splitter');
  ThreadHalt (0);
end.

