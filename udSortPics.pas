unit udSortPics;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, phObj, ActiveX,
  phDlg, VirtualTrees, TBX, TB2Item, Menus, StdCtrls, ExtCtrls, DTLangTools,
  ufrSorting;

type
  TdSortPics = class(TPhoaDialog)
    bReset: TButton;
    gbWhereToSort: TGroupBox;
    rbCurGroup: TRadioButton;
    rbAllGroups: TRadioButton;
    frSorting: TfrSorting;
    procedure bResetClick(Sender: TObject);
  private
     // ����������
    FPhoA: TPhotoAlbum;
     // ������� ��������� ������ � ������
    FGroup: TPhoaGroup;
     // ����� ������
    FUndoOperations: TPhoaOperations;
     // ���� True, ����������� ��������, ��� ���������� ������ ������
    FDirectSort: Boolean;
     // ������� ��������� frSorting
    procedure frSortingChange(Sender: TObject);
  protected
    procedure InitializeDialog; override;
    procedure ButtonClick_OK; override;
    function  GetDataValid: Boolean; override;
  end;

   // ���������� ������ ���������� �����������. ���� bDirectSort=True, �� ��������� ��������� ������ ���������������,
   //   ��� ���������� ���������� ��� ������ (������������ ��� ���������� ����������� ������)
  function DoSortPics(PhoA: TPhotoAlbum; Group: TPhoaGroup; UndoOperations: TPhoaOperations; bDirectSort: Boolean): Boolean;

implementation
{$R *.dfm}
uses phUtils, ConsVars, Main;

  function DoSortPics(PhoA: TPhotoAlbum; Group: TPhoaGroup; UndoOperations: TPhoaOperations; bDirectSort: Boolean): Boolean;
  begin
    with TdSortPics.Create(Application) do
      try
        FPhoA           := PhoA;
        FGroup          := Group;
        FUndoOperations := UndoOperations;
        FDirectSort     := bDirectSort;
        Result := Execute;
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TdSortPics
   //===================================================================================================================

  procedure TdSortPics.bResetClick(Sender: TObject);
  begin
    frSorting.Reset;
  end;

  procedure TdSortPics.ButtonClick_OK;
  var g: TPhoaGroup;
  begin
     // ������ ��������
    if rbAllGroups.Checked then g := FPhoA.RootGroup else g := FGroup;
    if rbCurGroup.Checked and FDirectSort then begin
      g.SortPics(frSorting.Sortings, FPhoA.Pics);
      fMain.RefreshViewer;
    end else
      fMain.PerformOperation(TPhoaMultiOp_PicSort.Create(FUndoOperations, FPhoA, g, frSorting.Sortings, rbAllGroups.Checked));
     // ��������� �������������� ����������
    frSorting.Sortings.RegSave(SRegSort_LastSortings);
    inherited ButtonClick_OK;
  end;

  procedure TdSortPics.frSortingChange(Sender: TObject);
  begin
    Modified := True;
  end;

  function TdSortPics.GetDataValid: Boolean;
  begin
    Result := frSorting.Sortings.Count>0;
  end;

  procedure TdSortPics.InitializeDialog;
  var b: Boolean;
  begin
    inherited InitializeDialog;
    HelpContext := IDH_intf_sort_pics;
    OKIgnoresModified := True;
    frSorting.Sortings.RegLoad(SRegSort_LastSortings);
    frSorting.SyncSortings;
    frSorting.OnChange := frSortingChange;
     // Adjust RadioButtons
    b := FGroup<>nil;
    rbCurGroup.Enabled  := b;
    rbCurGroup.Checked  := b;
    rbAllGroups.Checked := not b;
  end;

end.
