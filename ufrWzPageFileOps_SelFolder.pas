unit ufrWzPageFileOps_SelFolder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, phWizard, StdCtrls, VirtualTrees, ExtCtrls, VirtualExplorerTree,
  DTLangTools;

type
  TfrWzPageFileOps_SelFolder = class(TWizardPage)
    tvFolder: TVirtualExplorerTree;
    pFolderOptions: TPanel;
    bCreateFolder: TButton;
    eFolderPath: TEdit;
    dtlsMain: TDTLanguageSwitcher;
    procedure tvFolderChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure bCreateFolderClick(Sender: TObject);
    procedure tvFolderEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  private
     // ����������� �������� �����
    procedure AdjustFolderControls;
  protected
    function  GetDataValid: Boolean; override;
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, ConsVars, udFileOpsWizard, Main, phObj, VirtualShellUtilities;

  procedure TfrWzPageFileOps_SelFolder.AdjustFolderControls;
  var NS: TNamespace;
  begin
    bCreateFolder.Enabled := tvFolder.ValidateNamespace(tvFolder.FocusedNode, NS) and NS.FileSystem;
    eFolderPath.Text := tvFolder.SelectedPath;
  end;

  procedure TfrWzPageFileOps_SelFolder.bCreateFolderClick(Sender: TObject);
  begin
    tvFolder.CreateNewFolder(tvFolder.SelectedPath);
  end;

  procedure TfrWzPageFileOps_SelFolder.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    AdjustFolderControls;
  end;

  function TfrWzPageFileOps_SelFolder.GetDataValid: Boolean;
  begin
    Result := eFolderPath.Text<>'';
  end;

  procedure TfrWzPageFileOps_SelFolder.InitializePage;
  begin
    inherited InitializePage;
     // ����������� �������
    tvFolder.Active := True;
    tvFolder.BrowseTo(TdFileOpsWizard(StorageForm).DestinationFolder, False, True, False, True);
  end;

  function TfrWzPageFileOps_SelFolder.NextPage: Boolean;
  begin
    TdFileOpsWizard(StorageForm).DestinationFolder := ExcludeTrailingPathDelimiter(eFolderPath.Text);
    Result := True;
  end;

  procedure TfrWzPageFileOps_SelFolder.tvFolderChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    AdjustFolderControls;
  end;

  procedure TfrWzPageFileOps_SelFolder.tvFolderEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  begin
     // ��������� ���� ����� ��������������
    AdjustFolderControls; 
  end;

end.
