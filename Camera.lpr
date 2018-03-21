program Camera;

{$mode delphi}{$H+}
{$define use_tftp}    // if PI not connected to LAN and set for DHCP then remove this

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  FrameBuffer,
{$ifdef use_tftp}
  uTFTP, Winsock2,
{$endif}
  Console, uLog, uIL_Client, uOMX, VC4,
  Ultibo
  { Add additional units here };

(* based on hjimbens camera example
   https://www.raspberrypi.org/forums/viewtopic.php?t=44852

   pjde 2018 *)

const
  kRendererInputPort                       = 90;
  kClockOutputPort0                        = 80;
  kCameraCapturePort                       = 71;
  kCameraClockPort                         = 73;

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  ch : char;
  DefFrameBuff : PFrameBufferDevice;
  DefFrameProps : TFramebufferProperties;

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

{$ifdef use_tftp}
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
{$endif}

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

procedure camera;
var
  cstate : OMX_TIME_CONFIG_CLOCKSTATETYPE;
  cameraport : OMX_CONFIG_PORTBOOLEANTYPE;
  displayconfig : OMX_CONFIG_DISPLAYREGIONTYPE;
  camera, video_render, clock : PCOMPONENT_T;
  list : array [0..3] of PCOMPONENT_T;
  tunnel : array [0..3] of TUNNEL_T;
  client : PILCLIENT_T;
  height, w, h, x, y, layer : integer;
begin
  height := 600;
  w := (4 * height) div 3;
  h := height;
  x := (DefFrameProps.PhysicalWidth - w) div 2;
  y := (DefFrameProps.PhysicalHeight - h) div 2;
  layer := 0;
  list[0] := nil;   // suppress hint
  FillChar (list, SizeOf (list), 0);
  tunnel[0].sink_port := 0;   // suppress hint
  FillChar (tunnel, SizeOf (tunnel), 0);
  client := ilclient_init;
  if client <> nil then
    Log ('IL Client initialised OK.')
  else
    begin
      Log ('IL Client failed to initialise.');
      exit;
    end;
  if OMX_Init = OMX_ErrorNone then
    Log ('OMX Initialised OK.')
  else
    begin
      Log ('OMX failed to Initialise.');
      exit;
    end;
  // create camera
  if (ilclient_create_component (client, @camera, 'camera', ILCLIENT_DISABLE_ALL_PORTS) = 0) then
   Log ('camera created ok')
  else
   exit;
  list[0] := camera;
  // create video_render
  if (ilclient_create_component(client, @video_render, 'video_render', ILCLIENT_DISABLE_ALL_PORTS) = 0) then
    Log ('Video Render created ok')
  else
    exit;
  list[1] := video_render;
  // create clock
  if (ilclient_create_component(client, @clock, 'clock', ILCLIENT_DISABLE_ALL_PORTS) = 0) then
    Log ('Clock created ok.')
  else
    exit;
  list[2] := clock;
   // enable the capture port of the camera
  cameraport.nSize := 0;  // suppress hint
  FillChar (cameraport, sizeof (cameraport), 0);
  cameraport.nSize := sizeof (cameraport);
  cameraport.nVersion.nVersion := OMX_VERSION;
  cameraport.nPortIndex := kCameraCapturePort;
  cameraport.bEnabled := OMX_TRUE;
  if (OMX_SetParameter (ilclient_get_handle (camera), OMX_IndexConfigPortCapturing, @cameraport) = OMX_ErrorNone) then
    Log ('Capture port set ok.')
  else
    exit;
  // configure the renderer to display the content in a 4:3 rectangle in the middle of a 1280x720 screen
  displayconfig.nSize := 0; // suppress hint
  FillChar (displayconfig, SizeOf (displayconfig), 0);
  displayconfig.nSize := SizeOf (displayconfig);
  displayconfig.nVersion.nVersion := OMX_VERSION;
  displayconfig.set_ := OMX_DISPLAY_SET_FULLSCREEN or OMX_DISPLAY_SET_DEST_RECT or OMX_DISPLAY_SET_LAYER;
  displayconfig.nPortIndex := kRendererInputPort;
  if (w > 0) and (h > 0) then
    displayconfig.fullscreen := OMX_FALSE
  else
    displayconfig.fullscreen := OMX_TRUE;
  displayconfig.dest_rect.x_offset := x;
  displayconfig.dest_rect.y_offset := y;
  displayconfig.dest_rect.width := w;
  displayconfig.dest_rect.height := h;
  displayconfig.layer := layer;
  Log (format ('dest_rect: %d,%d,%d,%d', [x, y, w, h]));
  Log (format ('layer: %d', [displayconfig.layer]));
  if (OMX_SetParameter (ilclient_get_handle (video_render), OMX_IndexConfigDisplayRegion, @displayconfig) = OMX_ErrorNone) then
     Log ('Render Region set ok.')
  else
    exit;
  // create a tunnel from the camera to the video_render component
  set_tunnel (@tunnel[0], camera, kCameraCapturePort, video_render, kRendererInputPort);
  // create a tunnel from the clock to the camera
  set_tunnel (@tunnel[1], clock, kClockOutputPort0, camera, kCameraClockPort);
  // setup both tunnels
  if ilclient_setup_tunnel (@tunnel[0], 0, 0) = 0 then
    Log ('First tunnel created ok.')
  else
    exit;
  if ilclient_setup_tunnel (@tunnel[1], 0, 0) = 0 then
    Log ('Second tunnel created ok.')
  else
    exit;
  // change state of components to executing
  ilclient_change_component_state (camera, OMX_StateExecuting);
  ilclient_change_component_state (video_render, OMX_StateExecuting);
  ilclient_change_component_state (clock, OMX_StateExecuting);
  // start the camera by changing the clock state to running
  cstate.nSize := 0;  // suppress hint
  FillChar (cstate, SizeOf (cstate), 0);
  cstate.nSize := sizeOf (displayconfig);
  cstate.nVersion.nVersion := OMX_VERSION;
  cstate.eState := OMX_TIME_ClockStateRunning;
  OMX_SetParameter (ilclient_get_handle (clock), OMX_IndexConfigTimeClockState, @cstate);
  Log ('Press any key to exit.');
  ch := #0;
  ConsoleGetKey (ch, nil);
  ilclient_disable_tunnel (@tunnel[0]);
  ilclient_disable_tunnel (@tunnel[1]);
  ilclient_teardown_tunnels (@tunnel[0]);
  ilclient_state_transition (@list, OMX_StateIdle);
  ilclient_state_transition (@list, OMX_StateLoaded);
  ilclient_cleanup_components (@list);
  OMX_Deinit;
  ilclient_destroy (client);
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('Basic Camera Test.');
  Log3 ('Based on hjimbens program https://www.raspberrypi.org/forums/viewtopic.php?t=44852');
  WaitForSDDrive;
  Log3 ('SD Drive ready.');
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');
{$ifdef use_tftp}
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' put kernel7.img"');
  SetOnMsg (@Msg2);
{$endif}
  DefFrameBuff := FramebufferDeviceGetDefault;
  FramebufferDeviceGetProperties (DefFrameBuff, @DefFrameProps);
  BCMHostInit;
  camera;
  ThreadHalt (0);
end.

