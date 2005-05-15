unit udGroupProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, 
  phDlg, StdCtrls, ExtCtrls, DKLang;

type
  TdGroupProps = class(TPhoaDialog)
    dklcMain: TDKLanguageController;
    lID: TLabel;
    eID: TEdit;
    lText: TLabel;
    eText: TEdit;
    lDesc: TLabel;
    mDescription: TMemo;
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

  function EditPicGroup(AApp: IPhotoAlbumApp; AUndoOperations: TPhoaOperations): Boolean;

implementation
{$R *.dfm}
uses ConsVars, phUtils, Main;

  function EditPicGroup(AApp: IPhotoAlbumApp; AUndoOperations: TPhoaOperations): Boolean;
  begin
    with TdGroupProps.Create(Application) do
      try
        FApp            := AApp;
        FUndoOperations := AUndoOperations;
        Result := ExecuteModal(False, False);
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TdGroupProps
   //===================================================================================================================

  procedure TdGroupProps.ButtonClick_OK;
  begin
    FApp.PerformOperation(
      'GroupEdit',
      ['Group', FApp.CurGroup, 'NewText', eText.Text, 'NewDescription', mDescription.Lines.Text]);
    inherited ButtonClick_OK;
  end;

  procedure TdGroupProps.DoCreate;
  begin
    inherited DoCreate;
    HelpContext := IDH_intf_group_props;
  end;

  procedure TdGroupProps.ExecuteInitialize;
  var Group: IPhotoAlbumPicGroup;
  begin
    inherited ExecuteInitialize;
    Group := FApp.CurGroupX;
    eID.Text                := IntToStr(Group.ID);
    eText.Text              := Group.Text;
    mDescription.Lines.Text := Group.Description;
  end;

  function TdGroupProps.GetDataValid: Boolean;
  begin
    Result := eText.Text<>'';
  end;

end.

