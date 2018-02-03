program Working;

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

const
  ny : array [boolean] of string = ('NO', 'YES');

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  err : OMX_ERRORTYPE;
  handle : OMX_HANDLETYPE;
  n : integer;
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

procedure printState (handle : OMX_HANDLETYPE);
var
  state : OMX_STATETYPE;
  err : OMX_ERRORTYPE;
begin
  err := OMX_GetState (handle, @state);
  if err <> OMX_ErrorNone then
    begin
      Log ('Error on getting state.');
      exit;
    end;
  case state of
    OMX_StateLoaded : Log ('StateLoaded');
    OMX_StateIdle : Log ('StateIdle');
    OMX_StateExecuting : Log ('StateExecuting');
    OMX_StatePause : Log ('StatePause');
    OMX_StateWaitForResources : Log ('StateWait');
    OMX_StateInvalid : Log ('StateInvalid');
    else Log ('State unknown');
    end;
end;

function cEventHandler (hComponent : OMX_HANDLETYPE;
                        pAppData : OMX_PTR;
                        eEvent : OMX_EVENTTYPE;
                        Data1 : OMX_U32;
                        Data2 : OMX_U32;
                        pEventData : OMX_PTR) : OMX_ERRORTYPE; cdecl;
begin
  Log ('Hi there, I am in the callback');
  Log ('Event is ' + eEvent.ToString);
  Log ('Param1 is ' + Data1.ToString);
  Log ('Param2 is ' + Data2.ToString);
  Result := OMX_ErrorNone;
end;

procedure disableSomePorts (handle : OMX_HANDLETYPE; indexType : OMX_INDEXTYPE);
var
  param : OMX_PORT_PARAM_TYPE;
  startPortNumber, endPortNumber : integer;
  nPorts : integer;
  n : integer;
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
  endPortNumber := startPortNumber + nPorts;
  for n := startPortNumber to endPortNumber - 1 do
    begin
	    OMX_SendCommand (handle, OMX_CommandPortDisable, n, nil);
    end;
end;

procedure disableAllPorts (handle : OMX_HANDLETYPE);
begin
  disableSomePorts (handle, OMX_IndexParamVideoInit);
  disableSomePorts (handle, OMX_IndexParamImageInit);
  disableSomePorts (handle, OMX_IndexParamAudioInit);
  disableSomePorts (handle, OMX_IndexParamOtherInit);
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('OpenMAX IL Test.');
  WaitForSDDrive;
  Log3 ('SD Drive ready.');
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');

  {$ifdef use_tftp}
  Log2 ('TFTP - Enabled.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' PUT kernel7.img"');
  SetOnMsg (@Msg2);
  {$endif}

  callbacks.EventHandler := cEventHandler;
  callbacks.EmptyBufferDone := nil;
  callbacks.FillBufferDone := nil;
  BCMHostInit;
  err := OMX_Init;
  if err <> OMX_ErrorNone then
    begin
      Log ('OMX_Init failed. Error Code ' + err.ToHexString (8));
      ThreadHalt (0);
    end;

  // Ask the core for a handle to the component
  err := OMX_GetHandle (@handle, 'OMX.broadcom.audio_render', nil, @callbacks);
  if err<> OMX_ErrorNone then
	  begin
      Log ('OMX_GetHandle failed. Error Code ' + err.ToHexString (8));
      ThreadHalt (0);
    end;

  sleep (1);
  // check our current state - should be Loaded
  printState (handle);

  disableAllPorts (handle);

  // request a move to idle
  OMX_SendCommand (handle, OMX_CommandStateSet, OMX_StateIdle, nil);

  n := 0;
  while n < 10 do
    begin
      sleep (1);
      n := n + 1;
    end;
	// are we there yet?
	printState (handle);
  ThreadHalt (0);
end.

