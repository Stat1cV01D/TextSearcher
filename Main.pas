unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus, ShellAPI, CommCtrl, CommDlg, ShlObj,
  ActiveX, Engine, ExtCtrls, Types;

const
  StopBtnFlag_Default = 0;
  StopBtnFlag_Raised = 1;

  StopBtnFlag_DefaultMessage = 'Stop';
  StopBtnFlag_RaisedMessage = 'Stopping...';

type
  TForm1 = class(TForm)
    lvResults: TListView;
    StatusBar1: TStatusBar;
    MainPanel: TPanel;
    lblExpression: TLabel;
    lblFolders: TLabel;
    ExpressionMemo: TMemo;
    btnSearch: TButton;
    lvFolders: TListView;
    btnStop: TButton;
    Folder_PopupMenu: TPopupMenu;
    Menu_Add: TMenuItem;
    Menu_Modify: TMenuItem;
    Menu_Delete: TMenuItem;
    txtMaxFileSize: TLabeledEdit;
    btnAddFolder: TButton;
    btnDelFolder: TButton;
    procedure Menu_AddClick(Sender: TObject);
    procedure Menu_ModifyClick(Sender: TObject);
    procedure Menu_DeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSearchClick(Sender: TObject);
    procedure lvResultsDblClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    Folders: TStringList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Settings, IOUtils;
{$R *.dfm}

function BrowseCallbackProc(HWND: HWND; uMsg: uint; lp: lParam; pData: wParam)
  : integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    SendMessage(HWND, BFFM_SETSELECTION, 1, pData);

  result := 0;
end;

/// <returns>
/// Full path to selected folder or '' if error or user cancelled the selection
/// </returns>
function SelectFolderDialog(hwndParent: HWND; initialDir: PWideChar; Title: PChar): String;
Var
  bi: TBROWSEINFO;
  resultPIDL: PITEMIDLIST;
  _Result: array [0 .. MAX_PATH] of Char;
begin
  bi.hwndOwner := hwndParent;
  bi.pidlRoot := nil;
  bi.pszDisplayName := @_Result[0];
  bi.lpszTitle := Title;

  bi.ulFlags := BIF_STATUSTEXT or BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  bi.lpfn := BrowseCallbackProc;
  bi.lParam := lParam(initialDir);
  bi.iImage := 0;

  resultPIDL := SHBrowseForFolder(bi);
  try
    if (resultPIDL <> nil) then
    begin
      if SHGetPathFromIDList(resultPIDL, @_Result[0]) then
      begin
        SetString(Result, PChar(@_Result[0]), StrLen(PChar(@_Result[0])));
        Exit;
      end;
    end;
    Result := '';
  finally
    CoTaskMemFree(resultPIDL);
  end;
end;

procedure TForm1.btnSearchClick(Sender: TObject);
Var
  i: integer;
  TheEngine: TEngine;
begin
  btnStop.Tag := StopBtnFlag_Default;
  btnStop.Enabled := True;
  btnSearch.Enabled := False;
  lvResults.Clear;

  TheEngine := TEngine.Create;
  try
    TheEngine.Expression := ExpressionMemo.Text;
    TheEngine.MaxFileSize := StrToInt(txtMaxFileSize.Text) * 1024 * 1024;
    TheEngine.Callback :=
      function(State: TProcessState; _File, Dir: String): Boolean
      begin
        case State of
          Found:
            with lvResults.Items.Add do
            begin
              Caption := _File;
              SubItems.Add(Dir);
            end;
          CurrentFile:
            StatusBar1.Panels[0].Text := Dir;
        end;
        Result := (btnStop.Tag = StopBtnFlag_Default);
        Application.ProcessMessages;
      end;

    for i := 0 to Folders.Count - 1 do
    begin
      TheEngine.ProcessDirectory(IncludeTrailingPathDelimiter(Folders[i]),
        TSearchOption.soAllDirectories);
    end;

  finally
    TheEngine.Destroy;

    StatusBar1.Panels[0].Text := '';
    btnStop.Caption := StopBtnFlag_DefaultMessage;
    btnStop.Enabled := False;
    btnSearch.Enabled := True;
  end;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  btnStop.Tag := StopBtnFlag_Raised;
  btnStop.Caption := StopBtnFlag_RaisedMessage;
  btnStop.Enabled := False;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Folders.SaveToFile(INIfile);
  Folders.Destroy;
end;

procedure TForm1.FormCreate(Sender: TObject);
Var
  i: integer;
begin
  Folders := TStringList.Create(True);
  try
    Folders.LoadFromFile(INIfile);
    for i := 0 to Folders.Count - 1 do
      lvFolders.AddItem(Folders[i], nil);
  except
  end;
end;

procedure TForm1.lvResultsDblClick(Sender: TObject);
begin
  with lvResults.Selected do
    ShellExecute(Handle, 'open', PChar(TPath.Combine(SubItems[0], Caption)), nil,
      nil, SW_SHOW);
end;

procedure TForm1.Menu_AddClick(Sender: TObject);
Var
  Folder: String;
begin
  Folder := SelectFolderDialog(Self.Handle, PChar(ExtractFileDir(ParamStr(0))),
    'Select Dir');
  if Folder = '' then
    Exit;

  lvFolders.AddItem(Folder, nil);
  Folders.Add(Folder);
end;

procedure TForm1.Menu_DeleteClick(Sender: TObject);
begin
  Folders.Delete(lvFolders.Selected.Index);
  lvFolders.DeleteSelected;
end;

procedure TForm1.Menu_ModifyClick(Sender: TObject);
Var
  Folder: String;
begin
  Folder := SelectFolderDialog(Self.Handle, PChar(lvFolders.Selected.Caption),
    'Select Dir');
  if Folder = '' then
    Exit;

  with lvFolders.Selected do
  begin
    Caption := Folder;
    Folders[Index] := Folder;
  end;
end;

end.
