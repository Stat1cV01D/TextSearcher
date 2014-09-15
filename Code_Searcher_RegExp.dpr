program Code_Searcher_RegExp;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  Settings in 'Settings.pas',
  VBScript_RegExp_55_TLB in 'VBScript_RegExp_55_TLB.pas',
  Engine in 'Engine.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
