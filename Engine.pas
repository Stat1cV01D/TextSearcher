unit Engine;

interface

uses Windows, Forms, SysUtils, Classes, Generics.Collections, IOUtils, Types,
  VBScript_RegExp_55_TLB, Character, WideStrUtils;

type
  TProcessState = (CurrentFile, Found);
  TCallback = reference to function(State: TProcessState;
    _File, SubDir: String): Boolean;

  /// <summary>
  ///   The recursive file search engine with regexp criteria
  /// </summary>
  TEngine = class
  private
    /// <summary>
    /// The RegExp object from VBScript   
    /// </summary>
    Reg: TRegExp;
    /// <summary>
    ///   Regular expression string
    /// </summary>
    fExpr: String;
    FMaxFileSize: Uint32;
    procedure SetExpression(Value: String);
    /// <summary>
    ///   Checks the text or binary file for matches with the Expression
    /// </summary>
    /// <param name="_File">
    ///   Full path to the file to process
    /// </param>
    function IsFileMatches(_File: String): Boolean;

  public
    /// <summary>
    ///   The callback for GUI to display current results
    /// </summary>
    Callback: TCallback;
    property MaxFileSize: Uint32 read FMaxFileSize write FMaxFileSize;
    property Expression: String read fExpr write SetExpression;

    /// <summary>
    ///   The executive function. 
    /// Processes files in the <paramref name="Dir"/> directory and subdirectories
    /// </summary>
    /// <param name="Dir">
    ///   The directory to process files in
    /// </param>
    /// <param name="SO">
    ///   Specifies whether process current directory or subdirectories as well
    /// </param>
    procedure ProcessDirectory(Dir: String; SO: TSearchOption);
    constructor Create();
    destructor Destroy; override;
  end;

implementation

var
  Encodings: TList<TEncoding>;

procedure TEngine.SetExpression(Value: String);
begin
  if Value = '' then
    raise EArgumentException.Create('Expression can not be null');
  fExpr := Value;
  Reg.Pattern := fExpr;
end;

function TEngine.IsFileMatches(_File: String): Boolean;
Var
  mc: MatchCollection;

  BinData: TBytes;
  I: Integer;
  WStrData: String;
begin  
  Result := False;
  try
    // Read all the file to search quicker
    BinData := TFile.ReadAllBytes(_File);
    for I := 0 to Encodings.Count - 1 do
    begin
      // So that window in main thread doesn't get frozen
      Application.ProcessMessages;
      
      // We have to do a workaround for UTF8 as
      // TEncoding.UTF8.GetString() can't process whole binary file.
      // So we will call UnicodeFromLocaleChars() directly and
      // specify MB_ERR_INVALID_CHARS flag here to force
      // the function do the job. 
      if Encodings[i] = TEncoding.UTF8 then
      begin
        SetLength(WStrData, Length(BinData)); //Guaranteed to be less than initial ASCII string length
        UnicodeFromLocaleChars(CP_UTF8, MB_ERR_INVALID_CHARS, 
          PAnsiChar(@BinData[0]), Length(BinData), PWideChar(@WStrData[1]), Length(WStrData));
      end
      else
      begin
        WStrData := Encodings[I].GetString(BinData);
      end;

      // Pass the data thru the current encoding and try to get all possible strings
      mc := Reg.Execute(WideString(WStrData)) as MatchCollection;
      Result := (mc.Count > 0); // We got some matches
      SetLength(WStrData, 0);
      
      if Result then
        break;
    end;
  finally
    SetLength(BinData, 0);
    SetLength(WStrData, 0);
  end;
end;

procedure TEngine.ProcessDirectory(Dir: String; SO: TSearchOption);
const
  cCurrentDir: string = '.';
  cParentDir: string = '..';
var
  SearchRec: TSearchRec;
  Recursive: Boolean;
begin
  Recursive := SO = TSearchOption.soAllDirectories;
  if FindFirst(TPath.Combine(Dir, '*'), faAnyFile, SearchRec) = 0 then
  try
    repeat               
      if (SearchRec.Name = cCurrentDir) or
         (SearchRec.Name = cParentDir) 
      then
         continue;
         
      // go recursive in subdirectories
      if Recursive and (SearchRec.Attr and SysUtils.faDirectory <> 0) then
      begin
        ProcessDirectory(TPath.Combine(Dir, SearchRec.Name), SO)
      end
      else
      begin
        if SearchRec.Size > MaxFileSize then
          continue;

        if not Callback(CurrentFile, SearchRec.Name, Dir) then
          break;

        try  
          if IsFileMatches(TPath.Combine(Dir, SearchRec.Name)) then
          begin
            if not Callback(Found, SearchRec.Name, Dir) then
              break;
          end;
        except
          on E: EInOutError do ; // do nothing here
        end;
      end;
    until (FindNext(SearchRec) <> 0);
  finally
    FindClose(SearchRec);
  end;
end;

constructor TEngine.Create();
begin
  Reg := TRegExp.Create(nil);
  Reg.IgnoreCase := True;
  Reg.Global := True;
  Reg.Multiline := True;
end;

destructor TEngine.Destroy;
begin
  Reg.Destroy;
  inherited;
end;

initialization

Encodings := TList<TEncoding>.Create;
Encodings.Add(TEncoding.ASCII);
Encodings.Add(TEncoding.UTF8);
Encodings.Add(TEncoding.Unicode);

finalization

Encodings.Free;

end.
