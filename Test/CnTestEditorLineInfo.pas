{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestEditorLineInfo;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试控件板封装的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 7 以上
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id:  CnTestPaletteWizard 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* 修改记录：2016.04.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TTestEditorLineInfoForm = class(TForm)
    lstInfo: TListBox;
    EditorTimer: TTimer;
    procedure EditorTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// 测试编辑器行与光标信息的测试用专家
//==============================================================================

{ TCnTestEditorLineInfoWizard }

  TCnTestEditorLineInfoWizard = class(TCnMenuWizard)
  private
    FTestEdiotrLineForm: TTestEditorLineInfoForm;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnWizIdeUtils, CnDebug, CnEditControlWrapper;

{$R *.DFM}

//==============================================================================
// 测试编辑器行与光标信息的测试用专家
//==============================================================================

{ TCnTestEditorLineInfoWizard }

procedure TCnTestEditorLineInfoWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorLineInfoWizard.Create;
begin
  inherited;
  FTestEdiotrLineForm := TTestEditorLineInfoForm.Create(Application);
end;

procedure TCnTestEditorLineInfoWizard.Execute;
begin
  FTestEdiotrLineForm.Show;
  FTestEdiotrLineForm.EditorTimer.Enabled := True;
end;

function TCnTestEditorLineInfoWizard.GetCaption: string;
begin
  Result := 'Test Editor Line Info';
end;

function TCnTestEditorLineInfoWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorLineInfoWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorLineInfoWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorLineInfoWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorLineInfoWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Line Info Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Line Info';
end;

procedure TCnTestEditorLineInfoWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorLineInfoWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestEditorLineInfoForm.EditorTimerTimer(Sender: TObject);
const
  SEP = '================================================';
var
  EditView: IOTAEditView;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  Text: string;
  LineNo: Integer;
  CharIndex: Integer;
  EditControl: TControl;
  StatusBar: TStatusBar;
  PasParser: TCnGeneralPasStructParser;
  Stream: TMemoryStream;
  Element, LineFlag: Integer;
begin
  lstInfo.Clear;
  lstInfo.Items.Add(SEP);
  // NtaGetCurrentLine(LineText Property)/GetTextAtLine CursorPos ConvertPos

  CnNtaGetCurrLineText(Text, LineNo, CharIndex);

  lstInfo.Items.Add('CnNtaGetCurrLineText using LineText property:');
  lstInfo.Items.Add(Text);
  lstInfo.Items.Add(Format('LineNo %d, CharIndex %d.', [LineNo, CharIndex]));

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;

  Text := EditControlWrapper.GetTextAtLine(EditControl, LineNo);
  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add(Format('EditControlWrapper.GetTextAtLine %d', [LineNo]));
  lstInfo.Items.Add(Text);

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);

  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CursorPos/EditPos(1/1) CharPos(1/0) Conversion.');
  lstInfo.Items.Add(Format('EditPos %d:%d, CharPos %d:%d.', [EditPos.Line,
    EditPos.Col, CharPos.Line, CharPos.CharIndex]));


  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CnOtaGetCurrentCharPosFromCursorPosForParser.');
  if CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos) then
    lstInfo.Items.Add(Format('For Parser CharPos (Ansi/Wide) %d:%d.',
      [CharPos.Line, CharPos.CharIndex]))
  else
    lstInfo.Items.Add('Get Current Position Failed.');

  lstInfo.Items.Add(SEP);
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
  lstInfo.Items.Add(Format('GetAttributeAtPos EditPos %d:%d. Element %d, Flag %d. (NOT Correct in Unicode)',
   [EditPos.Line, EditPos.Col, Element, LineFlag]));

  PasParser := TCnGeneralPasStructParser.Create;
  Stream := TMemoryStream.Create;

  try
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
    CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
      or IsInc(EditView.Buffer.FileName), False);

    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

{$IFDEF BDS}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.AnsiIndex, PasParser.BlockStartToken.ItemLayer,
        PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
         PasParser.BlockCloseToken.AnsiIndex, PasParser.BlockCloseToken.ItemLayer,
         PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
         PasParser.InnerBlockStartToken.AnsiIndex, PasParser.InnerBlockStartToken.ItemLayer,
         PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
         PasParser.InnerBlockCloseToken.AnsiIndex, PasParser.InnerBlockCloseToken.ItemLayer,
         PasParser.InnerBlockCloseToken.Token]));

{$ELSE}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.ItemLayer, PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
        PasParser.BlockCloseToken.ItemLayer, PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
        PasParser.InnerBlockStartToken.ItemLayer, PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
        PasParser.InnerBlockCloseToken.ItemLayer, PasParser.InnerBlockCloseToken.Token]));
{$ENDIF}
  finally
    PasParser.Free;
    Stream.Free;
  end;

  StatusBar := GetEditWindowStatusBar;
  if (StatusBar <> nil) and (StatusBar.Panels.Count > 0) then
  begin
    lstInfo.Items.Add(SEP);
    lstInfo.Items.Add('Editor Position at StatusBar:');
    lstInfo.Items.Add(StatusBar.Panels[0].Text);
  end;
end;

initialization
  RegisterCnWizard(TCnTestEditorLineInfoWizard); // 注册此测试专家

end.
