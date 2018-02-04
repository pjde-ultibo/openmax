program VideoTest;

{$mode delphi}{$H+}

{$define use_tftp}    // if PI not connected to LAN and set for DHCP then remove this

// translation of hello_video example
// be sure to add test.h264 from userland-ultibo distro onto SD Card

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

procedure video_decode_test (filename : PChar);
var
  format : OMX_VIDEO_PARAM_PORTFORMATTYPE;
  cstate : OMX_TIME_CONFIG_CLOCKSTATETYPE;
  video_decode : PCOMPONENT_T;
  video_scheduler : PCOMPONENT_T;
  video_render : PCOMPONENT_T;
  clock : PCOMPONENT_T;
  list : array [0..3] of PCOMPONENT_T;
  tunnel : array [0..3] of TUNNEL_T;
  client : PILCLIENT_T;
  f : file;
  status : integer;
  data_len, bytesread : LongWord;

  buf : POMX_BUFFERHEADERTYPE;
  port_settings_changed : integer;
  first_packet : integer;
  dest : POMX_U8;
begin
  video_decode := nil;
  video_scheduler := nil;
  video_render := nil;
  clock := nil;
  data_len := 0;
  status := 0;
//  FillChar (list, sizeof (list), 0);
  list[0] := nil;
  list[1] := nil;
  list[2] := nil;
  list[3] := nil;
  FillChar (tunnel, sizeof (tunnel), 0);
  {$I-}
  assign (f, filename);
  reset (f, 1);
  {$I+}
  if IOResult <> 0 then exit;
  client := ilclient_init;
  if client = nil then
    begin
      close (f);
      exit;
    end;
  if OMX_Init <> OMX_ErrorNone then
    begin
      ilclient_destroy (client);
      close (f);
      exit;
    end;
  // create video_decode
  if ilclient_create_component (client, @video_decode, 'video_decode', ILCLIENT_DISABLE_ALL_PORTS or ILCLIENT_ENABLE_INPUT_BUFFERS) <> 0 then
    status := -14;
  list[0] := video_decode;
  // create video_render
  if (status = 0) and (ilclient_create_component (client, @video_render, 'video_render', ILCLIENT_DISABLE_ALL_PORTS) <> 0) then
    status := -14;
  list[1] := video_render;
  // create clock
  if (status = 0) and (ilclient_create_component (client, @clock, 'clock', ILCLIENT_DISABLE_ALL_PORTS) <> 0) then
    status := -14;
  list[2] := clock;
  FillChar (cstate, sizeof (cstate), 0);
  cstate.nSize := sizeof (cstate);
  cstate.nVersion.nVersion := OMX_VERSION;
  cstate.eState := OMX_TIME_ClockStateWaitingForStartTime;
  cstate.nWaitMask := 1;
  if (clock <> nil) and (OMX_SetParameter (ilclient_get_handle (clock), OMX_IndexConfigTimeClockState, @cstate) <> OMX_ErrorNone) then
    status := -13;
  // create video_scheduler
  if (status = 0) and (ilclient_create_component (client, @video_scheduler, 'video_scheduler', ILCLIENT_DISABLE_ALL_PORTS) <> 0) then
    status := -14;
  list[3] := video_scheduler;
  set_tunnel (@tunnel[0], video_decode, 131, video_scheduler, 10);
  set_tunnel (@tunnel[1], video_scheduler, 11, video_render, 90);
  set_tunnel (@tunnel[2], clock, 80, video_scheduler, 12);
  // setup clock tunnel first
  if (status = 0) and (ilclient_setup_tunnel (@tunnel[2], 0, 0) <> 0) then
    status := -15
  else
    ilclient_change_component_state (clock, OMX_StateExecuting);
  if status = 0 then
    ilclient_change_component_state (video_decode, OMX_StateIdle);
  FillChar (format, sizeof (OMX_VIDEO_PARAM_PORTFORMATTYPE), 0);
  format.nSize := sizeof (OMX_VIDEO_PARAM_PORTFORMATTYPE);
  format.nVersion.nVersion := OMX_VERSION;
  format.nPortIndex := 130;
  format.eCompressionFormat := OMX_VIDEO_CodingAVC;
  if (status = 0) and
     (OMX_SetParameter (ilclient_get_handle (video_decode), OMX_IndexParamVideoPortFormat, @format) = OMX_ErrorNone) and
     (ilclient_enable_port_buffers (video_decode, 130, nil, nil, nil) = 0) then
    begin
      port_settings_changed := 0;
      first_packet := 1;
      ilclient_change_component_state (video_decode, OMX_StateExecuting);
      buf := ilclient_get_input_buffer (video_decode, 130, 1);
      while buf <> nil do
        begin
          // feed data and wait until we get port settings changed
          dest := buf.pBuffer;
          bytesread := 0;
          blockread (f, dest^, buf.nAllocLen - data_len, bytesread);
          data_len := data_len + bytesread;
          if (port_settings_changed = 0) and
            ((data_len > 0) and (ilclient_remove_event (video_decode, OMX_EventPortSettingsChanged, 131, 0, 0, 1) = 0) or
             (data_len = 0) and (ilclient_wait_for_event (video_decode, OMX_EventPortSettingsChanged, 131, 0, 0, 1,
                                                       ILCLIENT_EVENT_ERROR or ILCLIENT_PARAMETER_CHANGED, 10000) = 0)) then
            begin
              port_settings_changed := 1;
              if ilclient_setup_tunnel (@tunnel[0], 0, 0) <> 0 then
                begin
                  status := -7;
                  break;
                end;
              ilclient_change_component_state (video_scheduler, OMX_StateExecuting);
              // now setup tunnel to video_render
              if ilclient_setup_tunnel (@tunnel[1], 0, 1000) <> 0 then
                begin
                  status := -12;
                  break;
                end;
              ilclient_change_component_state (video_render, OMX_StateExecuting);
            end;
          if data_len = 0 then break;

          buf.nFilledLen := data_len;
          data_len := 0;
          buf.nOffset := 0;
          if first_packet <> 0 then
            begin
              buf.nFlags := OMX_BUFFERFLAG_STARTTIME;
              first_packet := 0;
            end
          else
            buf.nFlags := OMX_BUFFERFLAG_TIME_UNKNOWN;
          if OMX_EmptyThisBuffer (ilclient_get_handle (video_decode), buf) <> OMX_ErrorNone then
            begin
              status := -6;
              break;
            end;
          buf := ilclient_get_input_buffer (video_decode, 130, 1);
        end;
      buf.nFilledLen := 0;
      buf.nFlags := OMX_BUFFERFLAG_TIME_UNKNOWN or OMX_BUFFERFLAG_EOS;
      if OMX_EmptyThisBuffer (ilclient_get_handle  (video_decode), buf) <> OMX_ErrorNone then
        status := -20;
      // wait for EOS from render
      ilclient_wait_for_event (video_render, OMX_EventBufferFlag, 90, 0, OMX_BUFFERFLAG_EOS, 0,
                               ILCLIENT_BUFFER_FLAG_EOS, -1);
      // need to flush the renderer to allow video_decode to disable its input port
      ilclient_flush_tunnels (@tunnel, 0);
    end;     // if status = 0
  close (f);
  Log ('closed file');
  ilclient_disable_tunnel (@tunnel[0]);
  ilclient_disable_tunnel (@tunnel[1]);
  ilclient_disable_tunnel (@tunnel[2]);
  Log ('disabled tunnels');
  ilclient_disable_port_buffers (video_decode, 130, nil, nil, nil);
  Log ('disabled ports');
  ilclient_teardown_tunnels (@tunnel);
//  ilclient_state_transition (@list, OMX_StateIdle);        // hanging
//  ilclient_state_transition (@list, OMX_StateLoaded);      // hanging
  Log ('state transitions');
  ilclient_cleanup_components (@list);
  Log ('cleaned up components');
  OMX_Deinit;
  ilclient_destroy (client);
  Log ('done');
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

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('hello_video example in native code.');
  WaitForSDDrive;
  Log3 ('SD Drive ready.');
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');

  {$ifdef use_tftp}
  Log2 ('TFTP - Enabled.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' PUT kernel7.img"');
  SetOnMsg (@Msg2);
  {$endif}

  BCMHostInit;
  video_decode_test ('test.h264');
  Log ('Playback finished.');

  ThreadHalt (0);
end.

