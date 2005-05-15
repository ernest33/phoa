//**********************************************************************************************************************
//  $Id: udSelPhoaGroup.pas,v 1.19 2005-05-15 09:03:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udSelPhoaGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, 
  phDlg, VirtualTrees, StdCtrls, ExtCtrls, DKLang;

type
  TdSelPhoaGroup = class(TPhoaDialog)
    dklcMain: TDKLanguageController;
    lGroup: TLabel;
    tvGroups: TVirtualStringTree;
    procedure tvGroupsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  private
     // ����������
    FApp: IPhotoAlbumApp;
     // ����� ������
    FUndoOperations: TPhoaOperations;
  protected
    function  GetDataValid: Boolean; override;
    procedure ButtonClick_OK; override;
    procedure DoCreate; override;
    procedure ExecuteInitialize; override;
  end;

  function MakeGroupFromView(AApp: IPhotoAlbumApp; AUndoOperations: TPhoaOperations): Boolean;

implementation
{$R *.dfm}
uses phUtils, ConsVars, Main, phSettings;

  function MakeGroupFromView(AApp: IPhotoAlbumApp; AUndoOperations: TPhoaOperations): Boolean;
  begin
    with TdSelPhoaGroup.Create(Application) do
      try
        FApp            := AApp;
        FUndoOperations := AUndoOperations;
        Result := ExecuteModal(False, True);
      finally
        Free;
      end;
  end;

  procedure TdSelPhoaGroup.ButtonClick_OK;
  begin
    FApp.PerformOperation('ViewMakeGroup', ['Group', PPhotoAlbumPicGroup(tvGroups.GetNodeData(tvGroups.FocusedNode))^]);
    inherited ButtonClick_OK;
  end;

  procedure TdSelPhoaGroup.DoCreate;
  begin
    inherited DoCreate;
    HelpContext := IDH_intf_sel_phoa_group;
    tvGroups.NodeDataSize := SizeOf(Pointer);
    ApplyTreeSettings(tvGroups);
  end;

  procedure TdSelPhoaGroup.ExecuteInitialize;
  begin
    inherited ExecuteInitialize;
    tvGroups.RootNodeCount := 1;
  end;

  function TdSelPhoaGroup.GetDataValid: Boolean;
  begin
    Result := tvGroups.FocusedNode<>nil;
  end;

  procedure TdSelPhoaGroup.tvGroupsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    Modified := True;
  end;

  procedure TdSelPhoaGroup.tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    PPhotoAlbumPicGroup(Sender.GetNodeData(Node))^ := nil;
  end;

  procedure TdSelPhoaGroup.tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if Kind in [ikNormal, ikSelected] then ImageIndex := iif(Sender.NodeParent[Node]=nil, iiPhoA, iif(Kind=ikSelected, iiFolderOpen, iiFolder));
  end;

  procedure TdSelPhoaGroup.tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    p: PPhotoAlbumPicGroup;
    s: String;
  begin
    p := Sender.GetNodeData(Node);
    if p<>nil then
      if TextType=ttStatic then begin
        if p^.Pics.Count>0 then s := Format('(%d)', [p^.Pics.Count]);
      end else if Sender.NodeParent[Node]<>nil then s := p^.Text
      else s := ConstVal('SPhotoAlbumNode');
    CellText := PhoaAnsiToUnicode(s);
  end;

  procedure TdSelPhoaGroup.tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p, pp: PPhotoAlbumPicGroup;
  begin
    p := Sender.GetNodeData(Node);
    if ParentNode=nil then
      p^ := FApp.ProjectX.RootGroupX 
    else begin
      pp := Sender.GetNodeData(ParentNode);
      p^ := pp^.GroupsX[Node.Index];
    end;
    Sender.ChildCount[Node] := p^.Groups.Count;
     // ������������� �������� ���� ��� ���� ������ ���������
    if (ParentNode=nil) or p^.Expanded then Include(InitialStates, ivsExpanded);
  end;

  procedure TdSelPhoaGroup.tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if TextType=ttStatic then TargetCanvas.Font.Color := clGrayText;
  end;

end.

