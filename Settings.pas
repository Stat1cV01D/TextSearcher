unit Settings;

interface

uses Windows;

const
  INIfile = 'CSR_Settings.ini';

procedure WriteValue(Key, Value: String);
function GetValue(Key: String): String;

implementation

Function ReadINIStr(Filename, section, Value, default: String): String;
var
  buffer: array [0 .. 1024] of Char;
begin
  SetString(Result, buffer, GetPrivateProfileString(PChar(section),
    PChar(Value), PChar(default), buffer, SizeOf(buffer), PChar(Filename)));
end;

procedure WriteINIStr(Filename, section, Key, Value: String);
begin
  WritePrivateProfileString(PChar(section), PChar(Key), PChar(Value),
    PChar(Filename));
end;

procedure WriteValue(Key, Value: String);
begin
  WriteINIStr(INIfile, 'Main', Key, Value);
end;

function GetValue(Key: String): String;
begin
  Result := ReadINIStr(INIfile, 'Main', Key, '');
end;

end.
