//**********************************************************************************************************************
//  $Id: ufrPicProps_FileProps.pas,v 1.9 2004-11-23 12:51:41 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_FileProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phWizard, VirtualTrees, phPicPropsDlgPage, ActnList, Menus, TB2Item, TBX;

type
  TfrPicProps_FileProps = class(TPicPropsDialogPage)
    tvMain: TVirtualStringTree;
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvMainShortenString(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const S: WideString; TextSpace: Integer; RightToLeft: Boolean; var Result: WideString; var Done: Boolean);
    procedure tvMainContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  private
     // ������������� �������� ��������� ISettingID_Dlgs_PP_ExpFileProps
    FExpandAll: Boolean;
  protected
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
  end;

implementation
{$R *.dfm}
uses TypInfo, VirtualShellUtilities, ConsVars, phUtils, phObj, phSettings;

type
  PNamespace = ^TNamespace;

  procedure TfrPicProps_FileProps.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    if tvMain.RootNodeCount=0 then begin
      tvMain.RootNodeCount := EditedPics.Count;
      ActivateFirstVTNode(tvMain);
    end;
  end;

  procedure TfrPicProps_FileProps.InitializePage;
  begin
    inherited InitializePage;
    ApplyTreeSettings(tvMain);
    tvMain.NodeDataSize := SizeOf(Pointer);
    tvMain.Images := FileImages;
    FExpandAll := SettingValueBool(ISettingID_Dlgs_PP_ExpFileProps);
  end;

  procedure TfrPicProps_FileProps.tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  begin
     // ��� ��������� �������� (�����) ������������� ���� ���� clBtnFace
    if Sender.NodeParent[Node]=nil then
      with TargetCanvas do begin
        Brush.Color := clBtnFace;
        FillRect(CellRect);
      end;
  end;

  procedure TfrPicProps_FileProps.tvMainContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  var Node, nParent: PVirtualNode;
  begin
    Node := tvMain.FocusedNode;
    if Node<>nil then begin
      nParent := tvMain.NodeParent[Node];
      if nParent<>nil then Node := nParent;
      ShowFileShellContextMenu(EditedPics[Node.Index].FileName);
    end;
    Handled := True;
  end;

  procedure TfrPicProps_FileProps.tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
     // ������� ������ TNamespace ���� ��� ��������� ��������
    if Sender.NodeParent[Node]=nil then PNamespace(Sender.GetNodeData(Node))^.Free;
  end;

  procedure TfrPicProps_FileProps.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if (Kind in [ikNormal, ikSelected]) and (Sender.NodeParent[Node]=nil) and (Column=0) then ImageIndex := FileImageIndex[Node.Index];
  end;

  procedure TfrPicProps_FileProps.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    nParent: PVirtualNode;
    NS: TNamespace;
    DFProp: TDiskFileProp;
    s: String;
  begin
    nParent := Sender.NodeParent[Node];
     // ��� ����� ������ (��������)
    if nParent=nil then begin
      if Column=0 then s := EditedPics[Node.Index].FileName;
     // ��� ��������� ������� ����� (�������� ����� �� ��������� � ������)
    end else begin
      NS := PNamespace(Sender.GetNodeData(nParent))^;
      DFProp := TDiskFileProp(Node.Index);
      case Column of
         // ��� ��������
        0: if NS=nil then s := ConstVal('SError') else s := DiskFilePropName(DFProp);
         // �������� ��������
        1: if NS=nil then s := ConstVal('SErrFileNotFound') else s := DiskFilePropValue(DFProp, NS);
      end;
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrPicProps_FileProps.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p: PNamespace;
  begin
     // ������ ������ ������������ ��� �� ������ ���� (�������� �������)
    if ParentNode=nil then begin
      p := Sender.GetNodeData(Node);
       // ��� �������� ������� ������ ����� ����������� ��� ��������� exception, ���� ����� ���
      try
        p^ := TNamespace.CreateFromFileName(EditedPics[Node.Index].FileName);
      except
        p^ := nil;
      end;
       // ���������� ����, ���� ����
      if FExpandAll then Include(InitialStates, ivsExpanded);
       // ���� ��������� ������ ��� ����������, ���������� ������������ ������ � ��������� ������
      Sender.ChildCount[Node] := iif(p^=nil, 1, Byte(High(TDiskFileProp))+1);
    end;
  end;

  procedure TfrPicProps_FileProps.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  var nParent: PVirtualNode;
  begin
    nParent := Sender.NodeParent[Node];
     // �������� ���������� ����� ������ (�������� ����)
    if nParent=nil then TargetCanvas.Font.Style := [fsBold]
     // � ������ ������ �������� �������
    else if PNamespace(Sender.GetNodeData(nParent))^=nil then TargetCanvas.Font.Color := clRed;
  end;

  procedure TfrPicProps_FileProps.tvMainShortenString(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const S: WideString; TextSpace: Integer; RightToLeft: Boolean; var Result: WideString; var Done: Boolean);
  begin
    Result := AnsiToUnicodeCP(ShortenFileName(TargetCanvas, TextSpace-10, UnicodeToAnsiCP(S, cMainCodePage)), cMainCodePage);
    Done := True;
  end;

end.
