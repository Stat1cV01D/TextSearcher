object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Code Searcher'
  ClientHeight = 396
  ClientWidth = 609
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvResults: TListView
    Left = 225
    Top = 0
    Width = 384
    Height = 377
    Align = alClient
    Columns = <
      item
        Caption = 'Files'
        Width = 150
      end
      item
        Caption = 'Dir'
        Width = 220
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvResultsDblClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 377
    Width = 609
    Height = 19
    Panels = <
      item
        Width = 609
      end>
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 377
    Align = alLeft
    Caption = 'MainPanel'
    ShowCaption = False
    TabOrder = 2
    object lblExpression: TLabel
      Left = 8
      Top = 5
      Width = 88
      Height = 13
      Caption = 'Search expression'
    end
    object lblFolders: TLabel
      Left = 8
      Top = 153
      Width = 35
      Height = 13
      Caption = 'Folders'
    end
    object ExpressionMemo: TMemo
      Left = 8
      Top = 24
      Width = 208
      Height = 97
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object btnSearch: TButton
      Left = 8
      Top = 127
      Width = 97
      Height = 25
      Caption = 'Search'
      TabOrder = 1
      OnClick = btnSearchClick
    end
    object lvFolders: TListView
      Left = 8
      Top = 172
      Width = 205
      Height = 123
      Columns = <
        item
          Caption = 'Folders'
          Width = 200
        end>
      RowSelect = True
      PopupMenu = Folder_PopupMenu
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = Menu_ModifyClick
    end
    object btnStop: TButton
      Left = 119
      Top = 127
      Width = 97
      Height = 25
      Caption = 'Stop'
      Enabled = False
      TabOrder = 3
      OnClick = btnStopClick
    end
    object txtMaxFileSize: TLabeledEdit
      Left = 8
      Top = 350
      Width = 121
      Height = 21
      EditLabel.Width = 119
      EditLabel.Height = 13
      EditLabel.Caption = 'Skip files more than X Mb'
      NumbersOnly = True
      TabOrder = 4
      Text = '1'
    end
    object btnAddFolder: TButton
      Left = 8
      Top = 301
      Width = 33
      Height = 25
      Caption = '+'
      TabOrder = 5
      OnClick = Menu_AddClick
    end
    object btnDelFolder: TButton
      Left = 47
      Top = 301
      Width = 33
      Height = 25
      Caption = '-'
      TabOrder = 6
      OnClick = Menu_DeleteClick
    end
  end
  object Folder_PopupMenu: TPopupMenu
    Left = 152
    Top = 248
    object Menu_Add: TMenuItem
      Caption = 'Add'
      OnClick = Menu_AddClick
    end
    object Menu_Modify: TMenuItem
      Caption = 'Modify'
      OnClick = Menu_ModifyClick
    end
    object Menu_Delete: TMenuItem
      Caption = 'Delete'
      OnClick = Menu_DeleteClick
    end
  end
end
