program GencmdTest;

{$mode objfpc}{$H+}
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
{$ifdef use_tftp}
  uTFTP, Winsock2,
{$endif}
  Console, uLog, VC4,
  Ultibo, uVCGencmd
  { Add additional units here };

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  res : integer;
  buffer : array [0 .. 31] of char;
  mem_gpu : integer;
  camera_supported, camera_detected : LongBool;

const
  ny : array [boolean] of string = ('NO', 'YES');

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

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log3 ('VC gencmd Test.');
  WaitForSDDrive;
  Log3 ('SD Drive ready.');
{$ifdef use_tftp}
  IPAddress := WaitForIPComplete;
  Log3 ('Network ready. Local Address : ' + IPAddress + '.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' put kernel7.img"');
  SetOnMsg (@Msg2);
{$endif}
  BCMHostInit;
  res := vc_gencmd (buffer, sizeof (buffer), 'get_mem gpu');
  if res = 0 then
    begin
      vc_gencmd_number_property (buffer, 'gpu', @mem_gpu);
      Log ('GPU Memory       : ' + mem_gpu.tostring);
    end
  else
    Log ('Error getting gpu memory.');
  res := vc_gencmd (buffer, sizeof (buffer), 'get_camera');
  if res = 0 then
    begin
      vc_gencmd_number_property (buffer, 'supported', @camera_supported);
      vc_gencmd_number_property (buffer, 'detected', @camera_detected);
      Log ('Camera Supported : ' + ny[camera_supported]);
      Log ('Camera Detected  : ' + ny[camera_detected]);
    end
  else
    Log ('Error getting camera.');
  ThreadHalt (0);
end.

