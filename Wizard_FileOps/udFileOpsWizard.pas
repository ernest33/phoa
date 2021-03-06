//**********************************************************************************************************************
//  $Id: udFileOpsWizard.pas,v 1.8 2007-07-04 18:48:49 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udFileOpsWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  TntWindows, TntSysUtils, TntWideStrings, TntClasses, GraphicEx, GR32,
  phIntf, phMutableIntf, phNativeIntf, phAppIntf, phObj, phOps, ConsVars, phWizard, phGraphics, 
  phWizForm, DKLang, ExtCtrls, TntExtCtrls, StdCtrls, TntStdCtrls;

type
  TFileOpThread = class;

   // ������ ����� � ������ �� ���������� �����������
  PFileLink = ^TFileLink; 
  TFileLink = class(TObject)
  private
     // Prop storage
    FFileName: WideString;
    FFilePath: WideString;
    FFileSize: Integer;
    FPics: IPhoaMutablePicList;
    FFileTime: TDateTime;
  public
    constructor Create(const wsFileName, wsFilePath: WideString; iFileSize: Integer; const dFileTime: TDateTime);
     // Props
     // -- ��� �����
    property FileName: WideString read FFileName;
     // -- ���� � �����
    property FilePath: WideString read FFilePath;
     // -- ������ �����
    property FileSize: Integer read FFileSize;
     // -- ����/����� ����������� �����
    property FileTime: TDateTime read FFileTime;
     // -- ������ ������ �� �����������, ��� ������� ���� �������� ���������� ��������� ������
    property Pics: IPhoaMutablePicList read FPics; 
  end;

   // ������ �������� TFileLink
  TFileLinks = class(TList)
  private
     // Prop handlers
    function  GetItems(Index: Integer): TFileLink;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
     // ��������� ����� ������ ����� � ���������� ������ �� ����
    function Add(const wsFileName, wsFilePath: WideString; iFileSize: Integer; const dFileTime: TDateTime): TFileLink;
     // Props
     // -- ����� �� �������
    property Items[Index: Integer]: TFileLink read GetItems; default;
  end;

   // ����� ������� �������� ��������
  TdFileOpsWizard = class(TPhoaWizardForm, IPhoaWizardPageHost_Log, IPhoaWizardPageHost_Process)
    dklcMain: TDKLanguageController;
  private
     // ������� ����� (����������� ��������)
    FFileOpThread: TFileOpThread;
     // �������� ��������
    FLog: TWideStrings;
     // ���� ����, ��� ������������ ���������
    FProcessing: Boolean;
     // ���� ���������� ���������
    FProcessingInterrupted: Boolean;
     // ����������� ���������� �����������
    FInitialPicCount: Integer;
     // ������� ������� ������������ ������/�����������
    FCountSucceeded: Integer;
     // ������� ������
    FCountErrors: Integer;
     // True, ���� � ������ ������ ������� ����� ��� � ���� �������
    FSelPicsByDefault: Boolean;
     // Prop storage
    FApp: IPhotoAlbumApp;
    FCDOpt_CopyExecutable: Boolean;
    FCDOpt_CopyIniSettings: Boolean;
    FCDOpt_CopyLangFile: Boolean;
    FCDOpt_CreateAutorun: Boolean;
    FCDOpt_CreatePhoa: Boolean;
    FCDOpt_IncludeViews: Boolean;
    FCDOpt_MediaLabel: WideString;
    FCDOpt_PhoaDesc: WideString;
    FCDOpt_PhoaFileName: WideString;
    FDelFile_DeleteToRecycleBin: Boolean;
    FDestinationFolder: WideString;
    FExportedProject: IPhotoAlbumProject;
    FFileOpKind: TFileOperationKind;
    FMoveFile_AllowDuplicating: Boolean;
    FMoveFile_Arranging: TFileOpMoveFileArranging;
    FMoveFile_BaseGroup: IPhotoAlbumPicGroup;
    FMoveFile_BasePath: WideString;
    FMoveFile_DeleteOriginal: Boolean;
    FMoveFile_DeleteToRecycleBin: Boolean;
    FMoveFile_FileNameFormat: WideString;
    FMoveFile_NoOriginalMode: TFileOpMoveFileNoOriginalMode;
    FMoveFile_OverwriteMode: TFileOpMoveFileOverwriteMode;
    FMoveFile_RenameFiles: Boolean;
    FMoveFile_ReplaceChar: WideChar;
    FMoveFile_UseCDOptions: Boolean;
    FProjectChanged: Boolean;
    FRepair_DeleteUnmatchedPics: Boolean;
    FRepair_FileLinks: TFileLinks;
    FRepair_LookSubfolders: Boolean;
    FRepair_MatchFlags: TFileOpRepairMatchFlags;
    FRepair_RelinkFilesInUse: Boolean;
    FSelectedGroups: IPhotoAlbumPicGroupList;
    FSelectedPics: IPhotoAlbumPicList;
    FSelPicMode: TFileOpSelPicMode;
    FSelPicValidityFilter: TFileOpSelPicValidityFilter;
     // �������� ����������� ��� �������� � FSelectedPics - �� ��������� ���������� ������ � ��������� �����
    procedure DoSelectPictures;
     // �������� ��������� ��������
    procedure StartProcessing;
     // ��������� ��������� ��������
    procedure InterruptProcessing;
     // ������ �������������� ����������
    procedure CreateExportedPhoa;
     // ����������� ��������� ��������� (���������� ������ ����� ��������� ���� �����������)
    procedure FinalizeProcessing;
     // ��������� ���������� � ��������� ��������
    procedure UpdateProgressInfo;
     // ���������� �������, �������������� �����������, ��� ����������� � ���, ��� ����������� ����������
    procedure ThreadPicProcessed;
     // ���������� ������ � ��������
    procedure LogSuccess(const ws: WideString; const aParams: Array of const);
    procedure LogFailure(const ws: WideString; const aParams: Array of const);
     // ���������� ������ ������-���������� ��� �������������� ������
    procedure Repair_SelectFiles;
     // IPhoaWizardPageHost_Log
    function  LogPage_GetLog(iPageID: Integer): TWideStrings;
    function  IPhoaWizardPageHost_Log.GetLog = LogPage_GetLog;
     // IPhoaWizardPageHost_Process
    procedure ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
    function  ProcPage_GetCurrentStatus: WideString;
    function  ProcPage_GetProcessingActive: Boolean;
    function  ProcPage_GetProgressCur: Integer;
    function  ProcPage_GetProgressMax: Integer;
    procedure IPhoaWizardPageHost_Process.StartProcessing     = StartProcessing;
    procedure IPhoaWizardPageHost_Process.StopProcessing      = InterruptProcessing;
    procedure IPhoaWizardPageHost_Process.PaintThumbnail      = ProcPage_PaintThumbnail;
    function  IPhoaWizardPageHost_Process.GetCurrentStatus    = ProcPage_GetCurrentStatus;
    function  IPhoaWizardPageHost_Process.GetProcessingActive = ProcPage_GetProcessingActive;
    function  IPhoaWizardPageHost_Process.GetProgressCur      = ProcPage_GetProgressCur;
    function  IPhoaWizardPageHost_Process.GetProgressMax      = ProcPage_GetProgressMax;
  protected
    function  GetNextPageID: Integer; override;
    function  GetRelativeRegistryKey: AnsiString; override;
    function  GetStartPageID: Integer; override;
    function  IsBtnBackEnabled: Boolean; override;
    function  IsBtnCancelEnabled: Boolean; override;
    function  IsBtnNextEnabled: Boolean; override;
    function  PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean; override;
    procedure DoCreate; override;
    procedure ExecuteFinalize; override;
    procedure ExecuteInitialize; override;
    procedure PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer); override;
    procedure SettingsInitialLoad(rif: TPhoaRegIniFile); override;
    procedure SettingsInitialSave(rif: TPhoaRegIniFile); override;
  public
     // Props
     // -- ����������
    property App: IPhotoAlbumApp read FApp;
     // -- �������� CD/DVD: True, ���� ����� ��������� ���������� �� ���������� �����������
    property CDOpt_CreatePhoa: Boolean read FCDOpt_CreatePhoa write FCDOpt_CreatePhoa;
     // -- �������� CD/DVD: ������������� ��� ����� �����������
    property CDOpt_PhoaFileName: WideString read FCDOpt_PhoaFileName write FCDOpt_PhoaFileName;
     // -- �������� CD/DVD: �������� �����������
    property CDOpt_PhoaDesc: WideString read FCDOpt_PhoaDesc write FCDOpt_PhoaDesc;
     // -- �������� CD/DVD: True, ���� ����� �������� ��������� ������������� � ����������� ����������
    property CDOpt_IncludeViews: Boolean read FCDOpt_IncludeViews write FCDOpt_IncludeViews;
     // -- �������� CD/DVD: True, ���� ����� ����� ����������� ����������� ����
    property CDOpt_CopyExecutable: Boolean read FCDOpt_CopyExecutable write FCDOpt_CopyExecutable;
     // -- �������� CD/DVD: True, ���� ����� ��������� ������� ��������� � phoa.ini
    property CDOpt_CopyIniSettings: Boolean read FCDOpt_CopyIniSettings write FCDOpt_CopyIniSettings;
     // -- �������� CD/DVD: True, ���� ����� ����������� ������� ������������ �������� ����. ����� ����� ������ ����
     //    ������� ���� - �� ����������
    property CDOpt_CopyLangFile: Boolean read FCDOpt_CopyLangFile write FCDOpt_CopyLangFile; 
     // -- �������� CD/DVD: True, ���� ����� ������� ���� autorun.inf
    property CDOpt_CreateAutorun: Boolean read FCDOpt_CreateAutorun write FCDOpt_CreateAutorun;
     // -- �������� CD/DVD: ����� �������� ��� autorun.inf
    property CDOpt_MediaLabel: WideString read FCDOpt_MediaLabel write FCDOpt_MediaLabel;
     // -- ��������: ���� True, ������� ����� � �������, ����� - ������� ������
    property DelFile_DeleteToRecycleBin: Boolean read FDelFile_DeleteToRecycleBin write FDelFile_DeleteToRecycleBin;
     // -- ����� ����������, � ������� ������������ ��������
    property DestinationFolder: WideString read FDestinationFolder write FDestinationFolder;
     // -- ������, ��������������� ��� �������� � �������� �����������/����������� ������
    property ExportedProject: IPhotoAlbumProject read FExportedProject;
     // -- ��������� �������� � ������� �����������
    property FileOpKind: TFileOperationKind read FFileOpKind write FFileOpKind;
     // -- �����������/�����������: ����� ���������� ������
    property MoveFile_Arranging: TFileOpMoveFileArranging read FMoveFile_Arranging write FMoveFile_Arranging;
     // -- �����������/�����������: ����, ������������ �������� ��������� ����� � ������� (���
     //    MoveFileArranging=fomfaMaintainFolderLayout)
    property MoveFile_BasePath: WideString read FMoveFile_BasePath write FMoveFile_BasePath;
     // -- �����������/�����������: ������, ������������ ������� ��������� ����� � ������� (���
     //    MoveFileArranging=fomfaMaintainGroupLayout)
    property MoveFile_BaseGroup: IPhotoAlbumPicGroup read FMoveFile_BaseGroup write FMoveFile_BaseGroup;
     // -- �����������/�����������: ���� True, ������ ��������� ������, ������� �� � �����, ��������������� ������� (���
     //    MoveFileArranging=fomfaMaintainGroupLayout)
    property MoveFile_AllowDuplicating: Boolean read FMoveFile_AllowDuplicating write FMoveFile_AllowDuplicating;
     // -- �����������/�����������: ���� True, ��������������� �����, ��������� �������� MoveFile_FileNameFormat
    property MoveFile_RenameFiles: Boolean read FMoveFile_RenameFiles write FMoveFile_RenameFiles;
     // -- �����������/�����������: ������ ����� �����, ������������ ��� ���������������� ������ ���
     //    MoveFile_RenameFiles=True
    property MoveFile_FileNameFormat: WideString read FMoveFile_FileNameFormat write FMoveFile_FileNameFormat;
     // -- �����������/�����������: ��������� ��� ���������� ��������� ����� ��� �����������
    property MoveFile_NoOriginalMode: TFileOpMoveFileNoOriginalMode read FMoveFile_NoOriginalMode write FMoveFile_NoOriginalMode;
     // -- �����������/�����������: ����� ���������� ������������ ������
    property MoveFile_OverwriteMode: TFileOpMoveFileOverwriteMode read FMoveFile_OverwriteMode write FMoveFile_OverwriteMode;
     // -- �����������/�����������: ������, �� ������� �������� ������������ ��� ����/����� ������ �������
    property MoveFile_ReplaceChar: WideChar read FMoveFile_ReplaceChar write FMoveFile_ReplaceChar;
     // -- �����������/�����������: ���� True, ������� ������������ ����
    property MoveFile_DeleteOriginal: Boolean read FMoveFile_DeleteOriginal write FMoveFile_DeleteOriginal;
     // -- �����������/�����������: ���� True, ������� ������������ ���� � �������, ����� - ������� ������
    property MoveFile_DeleteToRecycleBin: Boolean read FMoveFile_DeleteToRecycleBin write FMoveFile_DeleteToRecycleBin;
     // -- �����������/�����������: ���� True, ���������� � ������������ ����� �������� CD/DVD
    property MoveFile_UseCDOptions: Boolean read FMoveFile_UseCDOptions write FMoveFile_UseCDOptions;
     // -- True, ���� �������� ������ ��������� � ������
    property ProjectChanged: Boolean read FProjectChanged;
     // -- �������������� ������: ����� ������ ���������� ��� ��������������
    property Repair_MatchFlags: TFileOpRepairMatchFlags read FRepair_MatchFlags write FRepair_MatchFlags;
     // -- �������������� ������: ���� True, ������������� ��������� � ����� ���������� ����� � ������� ����������� �����
    property Repair_LookSubfolders: Boolean read FRepair_LookSubfolders write FRepair_LookSubfolders;
     // -- �������������� ������: ���� True, ������������ ������ �������������� ������, ���������� ��� �������������
     //    �����������, �� ������������ �����������, � ������� ����������� �������. ���� False, ���������� ���
     //    ������������ �����
    property Repair_RelinkFilesInUse: Boolean read FRepair_RelinkFilesInUse write FRepair_RelinkFilesInUse;
     // -- �������������� ������: ���� True, ������� �����������, ������� ��� � �� ���� ������� ���������������� �����
    property Repair_DeleteUnmatchedPics: Boolean read FRepair_DeleteUnmatchedPics write FRepair_DeleteUnmatchedPics;
     // -- �������������� ������: ������ ��������� ������ � ������ �� �����������
    property Repair_FileLinks: TFileLinks read FRepair_FileLinks;
     // -- ��������� ������ (������ �� ������ ������ ��� SelPicMode=fospmSelGroups)
    property SelectedGroups: IPhotoAlbumPicGroupList read FSelectedGroups;
     // -- ���������� ��� �������� �����������
    property SelectedPics: IPhotoAlbumPicList read FSelectedPics;
     // -- ����� ������ �����������
    property SelPicMode: TFileOpSelPicMode read FSelPicMode write FSelPicMode;
     // -- ������ ������ ����������� �� ������� ���������������� �����
    property SelPicValidityFilter: TFileOpSelPicValidityFilter read FSelPicValidityFilter write FSelPicValidityFilter;
  end;

   // �����-���������� �������� ��������
  TFileOpThread = class(TThread)
  private
     // �����-�������� ������
    FWizard: TdFileOpsWizard;
     // Prop storage
    FErrorOccured: Boolean;
    FChangesMade: Boolean;
     // ���� ��� AskOverwrite()
    FOverwriteFileName: WideString;
    FOverwriteResults: TMessageBoxResults;
     // ���������, ����������� �������� ��� ���������� �����������
    procedure DoCopyMovePic(Pic: IPhotoAlbumPic);
    procedure DoDelPicAndFile(Pic: IPhotoAlbumPic);
    procedure DoRebuildThumb(Pic: IPhotoAlbumPic);
    procedure DoRepairFileLink(Pic: IPhotoAlbumPic);
     // ��������� �������� �����
    procedure DoDeleteFile(const wsFileName: WideString; bDelToRecycleBin: Boolean);
     // ������� ����������� �� ����������� (����� ������ �� ���� �� �����)
    procedure DoDeletePic(Pic: IPhotoAlbumPic);
     // ��������� ������ �� ���� (�������������� �������� ������������ �����)
    procedure DoUpdateFileLink(Pic: IPhotoAlbumPic; const wsNewFileName: WideString);
     // ���������� ����������� ���������� ����� (���������� � Synchronize())
    procedure AskOverwrite;
  protected
    procedure Execute; override;
  public
    constructor Create(Wizard: TdFileOpsWizard);
     // Props
     // -- True, ���� ��������� �������� ������ ��������� � ����������
    property ChangesMade: Boolean read FChangesMade;
     // -- True, ���� ��������� ������ ��� ���������� ��������
    property ErrorOccured: Boolean read FErrorOccured;
  end;

   // ���������� ������ �������� � ������� �����������. ���������� True, ���� ���-�� � ����������� ���� ��������
   //   AApp - ����������
  function DoFileOperations(AApp: IPhotoAlbumApp; out bProjectChanged: Boolean): Boolean;

implementation
{$R *.dfm}
uses
  ShellAPI, 
  phUtils, ufrWzPage_Log,
  ufrWzPage_Processing, ufrWzPageFileOps_SelTask, ufrWzPageFileOps_SelPics, ufrWzPageFileOps_SelFolder,
  ufrWzPageFileOps_MoveOptions, ufrWzPageFileOps_DelOptions, ufrWzPageFileOps_RepairOptions,
  Main, ufrWzPageFileOps_CDOptions, ufrWzPageFileOps_RepairSelLinks,
  ufrWzPageFileOps_MoveOptions2, phSettings, phMsgBox;

  function DoFileOperations(AApp: IPhotoAlbumApp; out bProjectChanged: Boolean): Boolean;
  begin
    with TdFileOpsWizard.Create(Application) do
      try
        FApp              := AApp;
        FSelPicsByDefault := FApp.FocusedControl=pafcThumbViewer;
        Result := ExecuteModal;
        bProjectChanged := ProjectChanged;
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TFileLink
   //===================================================================================================================

  constructor TFileLink.Create(const wsFileName, wsFilePath: WideString; iFileSize: Integer; const dFileTime: TDateTime);
  begin
    inherited Create;
    FFileName := wsFileName;
    FFilePath := wsFilePath;
    FFileSize := iFileSize;
    FFileTime := dFileTime;
    FPics     := NewPhotoAlbumPicList(True);
  end;

   //===================================================================================================================
   // TFileLinks
   //===================================================================================================================

  function TFileLinks.Add(const wsFileName, wsFilePath: WideString; iFileSize: Integer; const dFileTime: TDateTime): TFileLink;
  begin
    Result := TFileLink.Create(wsFileName, wsFilePath, iFileSize, dFileTime);
    inherited Add(Result);
  end;

  function TFileLinks.GetItems(Index: Integer): TFileLink;
  begin
    Result := TFileLink(Get(Index));
  end;

  procedure TFileLinks.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action=lnDeleted then TFileLink(Ptr).Free;
  end;

   //===================================================================================================================
   // TFileOpThread
   //===================================================================================================================

  procedure TFileOpThread.AskOverwrite;
  begin
    FOverwriteResults := PhoaMsgBoxConst(
      mbkConfirmWarning,
      'SConfirm_FileOverwrite',
      [FOverwriteFileName],
      False,
      [mbbYes, mbbYesToAll, mbbNo, mbbNoToAll, mbbCancel]);
  end;

  constructor TFileOpThread.Create(Wizard: TdFileOpsWizard);
  begin
    inherited Create(True);
    FWizard := Wizard;
    FreeOnTerminate := True;
    Resume;
  end;

  procedure TFileOpThread.DoCopyMovePic(Pic: IPhotoAlbumPic);
  var
    wsSrcFileName, wsSrcPath, wsSrcFullFileName, wsDestPath, wsTargetPath, wsTargetFileName: WideString;
    SLRelTargetPaths: TTntStringList;
    i: Integer;

     // ��������� ������������� ���� � ����������� � SLRelTargetPaths, ���� ������ ������� � ��� ������������ � ������
     //   Group. ���������� �������� ���� ��� ��������� �����
    procedure AddPathIfPicInGroup(Group: IPhotoAlbumPicGroup);
    var
      i: Integer;
      g: IPhotoAlbumPicGroup;
      wsRelPath: WideString;
      bGroupSelected: Boolean;
    begin
       // ��������� ����������� ������
      case FWizard.SelPicMode of
        fospmSelPics:         bGroupSelected := Group.ID=FWizard.App.CurGroup.ID;
        fospmAll:             bGroupSelected := True;
        else {fospmSelGroups} bGroupSelected := FWizard.SelectedGroups.IndexOfID(Group.ID)>=0;
      end;
       // ���� ������ �������, ���� ����������� � ������
      if bGroupSelected and (Group.Pics.IndexOfID(Pic.ID)>=0) then begin
         // ��������� ���� ����������� ������������ MoveFile_BaseGroup
        g := Group;
        wsRelPath := '';
        while (g<>nil) and (g<>FWizard.MoveFile_BaseGroup) do begin
          wsRelPath := ReplaceChars(g.Text, SInvalidPathChars, FWizard.MoveFile_ReplaceChar)+'\'+wsRelPath;
          g := g.OwnerX;
        end;
         // ��������� ���� � ������
        SLRelTargetPaths.Add(wsRelPath);
         // ���� ������������ ������ �� �����������, ��������� �����
        if not FWizard.MoveFile_AllowDuplicating then Exit;
      end;
       // ��������� �� �� ��� ��������� �����
      for i := 0 to Group.Groups.Count-1 do begin
        AddPathIfPicInGroup(Group.GroupsX[i]);
         // ���� ������������ ������ �� �����������, ��������� ����� ��� ������� [���� �� �����] ������ ����
        if not FWizard.MoveFile_AllowDuplicating and (SLRelTargetPaths.Count>0) then Exit;
      end;
    end;

     // ���������� ����������������� � ������������ � FWizard.MoveFile_FileNameFormat ��� ����� ���������� ���
     //   ��������������� �����������
    function GetFormattedTargetFileName: WideString;
    var
      ws: WideString;
      i1, i2: Integer;
      PProp: TPicProperty;
    begin
      Result := '';
      ws := FWizard.MoveFile_FileNameFormat;
      repeat
         // ���� �������� ������ � ������
        i1 := Pos('{', ws);
        i2 := Pos('}', ws);
         // �������� ������ �����������
        if (i1=0) and (i2=0) then Break;
         // ��������� � ���������� ������ ������, �� ���������� �������� ������
        Result := Result+Copy(ws, 1, Min(i1, i2)-1);
         // �������� ��� �������� �����������, ������������ ����� �������� ������
        if (i1<>0) and (i2<>0) and (i1<i2-1) then begin
          PProp := StrToPicProp(Copy(ws, i1+1, i2-i1-1), True);
           // ��������� � ���������� �������� �������� ��� ��������������� �����������
          Result := Result+Pic.PropStrValues[PProp];
        end;
         // ������� ������������ ����� ������ �� ws
        Delete(ws, 1, Max(i1, i2));
      until ws='';
       // ��������� � ���������� ������� ������ (�� ���������� �������� ������) � ���������� ��������� �����
      Result := Result+ws+ExtractFileExt(wsSrcFileName);
       // �������� ������������ ������� � ����� �����
      Result := ReplaceChars(Result, SInvalidPathChars, FWizard.MoveFile_ReplaceChar);
    end;

     // �������� ���� � ���� sTargetPath
    procedure PerformCopying(const wsTargetPath: WideString);
    var wsTargetDir, wsTargetFullFileName: WideString;
    begin
      wsTargetDir := WideExcludeTrailingPathDelimiter(wsTargetPath);
       // ���������, ��� �������� � ������� ���� ������
      if WideSameText(wsSrcPath, wsTargetPath) then PhoaExceptionConst('SErrSrcAndDestFoldersAreSame', [wsTargetDir, wsSrcFileName]);
       // �������� ������� ������� ����������
      if not WideForceDirectories(wsTargetDir) then PhoaExceptionConst('SErrCannotCreateFolder', [wsTargetDir]);
       // ��������� ���������� �����
      wsTargetFullFileName := wsTargetPath+wsTargetFileName;
      case FWizard.MoveFile_OverwriteMode of
        fomfomNever: if WideFileExists(wsTargetFullFileName) then PhoaExceptionConst('SErrTargetFileExists', [wsTargetFullFileName]);
        fomfomPrompt:
          if WideFileExists(wsTargetFullFileName) then begin
            FOverwriteFileName := wsTargetFullFileName;
            Synchronize(AskOverwrite);
             // "��"
            if mbrYes in FOverwriteResults then
              { do nothing }
             // "�� ��� ����"
            else if mbrYesToAll in FOverwriteResults then
              FWizard.MoveFile_OverwriteMode := fomfomAlways
             // "���"
            else if mbrNo in FOverwriteResults then
              PhoaExceptionConst('SLogEntry_UserDeniedFileOverwrite', [wsTargetFullFileName])
             // "��� ��� ����"
            else if mbrNoToAll in FOverwriteResults then begin
              FWizard.MoveFile_OverwriteMode := fomfomNever;
              PhoaExceptionConst('SErrTargetFileExists', [wsTargetFullFileName]);
             // "������"
            end else begin
              FWizard.InterruptProcessing;
              PhoaExceptionConst('SLogEntry_UserAbort');
            end;
          end;
      end;
       // �������� ����
      if not WideCopyFile(PWideChar(wsSrcFullFileName), PWideChar(wsTargetFullFileName), False) then RaiseLastOSError;
       // ������������� �����
      FWizard.LogSuccess('SLogEntry_FileCopiedOK', [wsSrcFullFileName, wsTargetFullFileName]);
    end;

  begin
     // �������� ���/���� ��������� �����
    wsSrcFullFileName := Pic.FileName;
    wsSrcFileName     := WideExtractFileName(wsSrcFullFileName);
    wsSrcPath         := WideExtractFilePath(wsSrcFullFileName);
    wsDestPath        := WideIncludeTrailingPathDelimiter(FWizard.DestinationFolder);
    wsTargetPath      := '';
    if FWizard.MoveFile_RenameFiles then wsTargetFileName := GetFormattedTargetFileName else wsTargetFileName := wsSrcFileName;
    case FWizard.MoveFile_Arranging of
       // ��� � ���� ������� - ������� ����������
      fomfaPutFlatly: begin
        wsTargetPath := wsDestPath;
        PerformCopying(wsTargetPath);
      end;
       // ����������� � �������, �������� ������������ ������������ �������� MoveFile_BasePath
      fomfaMaintainFolderLayout: begin
         // �������� ����� ����, ������������ ������� �������� ����� ����. ������� ':' �� ������, ���� ���� �������� ���
         //   �����
        wsTargetPath := Tnt_WideStringReplace(Copy(wsSrcPath, Length(FWizard.MoveFile_BasePath)+1, MaxInt), ':', '', [rfReplaceAll]);
         // ������� ��� '\' � ������ (� ������ UNC-����, ��� MoveFile_BasePath ��� '\' � �����)
        while (wsTargetPath<>'') and (wsTargetPath[1]='\') do Delete(wsTargetPath, 1, 1);
        wsTargetPath := wsDestPath+wsTargetPath;
        PerformCopying(wsTargetPath);
      end;
       // ����������� � �������, �������� ������������ ����� ������������ ������ MoveFile_BaseGroup
      else {fomfaMaintainGroupLayout} begin
        SLRelTargetPaths := TTntStringList.Create;
        try
          SLRelTargetPaths.Sorted     := True;
          SLRelTargetPaths.Duplicates := dupIgnore;
           // ��������� SLRelTargetPaths ������ ����������
          AddPathIfPicInGroup(FWizard.App.ProjectX.ViewRootGroupX);
           // ���� ���-�� ���� (�� ����, ������ ���� ������)
          if SLRelTargetPaths.Count=0 then PhoaExceptionConst('SErrNoTargetPathDetermined', [Pic.FileName]);
          wsTargetPath := wsDestPath+SLRelTargetPaths[0];
          for i := 0 to iif(FWizard.MoveFile_AllowDuplicating, SLRelTargetPaths.Count-1, 0) do PerformCopying(wsDestPath+SLRelTargetPaths[i]);
        finally
          SLRelTargetPaths.Free;
        end;
      end;
    end;
     // ���� ����� - �����������
    if FWizard.FileOpKind=fokMoveFiles then begin
       // ���������� ������
      DoUpdateFileLink(Pic, wsTargetPath+wsTargetFileName);
       // ������� �������� ����
      if FWizard.MoveFile_DeleteOriginal then DoDeleteFile(wsSrcFullFileName, FWizard.MoveFile_DeleteToRecycleBin);
    end;
     // ���� ������� ����� �������� �����������, ���������� ������ �� ���� � ��������������� �����������
    if FWizard.ExportedProject<>nil then FWizard.ExportedProject.PicsX.ItemsByIDX[Pic.ID].FileName := wsTargetPath+wsTargetFileName;
  end;

  procedure TFileOpThread.DoDeleteFile(const wsFileName: WideString; bDelToRecycleBin: Boolean);
  var SFOS: TSHFileOpStructW;
  begin
     // ��������� ������� �����. ���� ��� ��� - �������, �������, �� �����
    if not WideFileExists(wsFileName) then
      FWizard.LogSuccess('SLogEntry_SkipInsteadOfDelFile', [wsFileName])
     // ����� ������� ����
    else
       // -- � �������
      if bDelToRecycleBin then begin
        SFOS.Wnd    := FWizard.Handle;
        SFOS.wFunc  := FO_DELETE;
        SFOS.pFrom  := PWideChar(wsFileName+#0);
        SFOS.pTo    := #0;
        SFOS.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
        if Tnt_SHFileOperationW(SFOS)=0 then
          FWizard.LogSuccess('SLogEntry_FileRecycledOK', [wsFileName])
        else
          PhoaExceptionConst('SLogEntry_FileRecyclingError', [wsFileName]);
       // -- ������
      end else
        if DeleteFile(wsFileName) then
          FWizard.LogSuccess('SLogEntry_FileDeletedOK', [wsFileName])
        else
          PhoaExceptionConst('SLogEntry_FileDeletingError', [wsFileName]);
  end;

  procedure TFileOpThread.DoDeletePic(Pic: IPhotoAlbumPic);

     // ���������� ������� ����������� �� ������ Group � � ��������
    procedure DelID(Group: IPhotoAlbumPicGroup; iID: Integer);
    var i: Integer;
    begin
      Group.PicsX.Remove(iID);
      for i := 0 to Group.Groups.Count-1 do DelID(Group.GroupsX[i], iID);
    end;

  begin
    FChangesMade := True;
     // ������� ��� ������ �� �����������
    DelID(FWizard.App.ProjectX.RootGroupX, Pic.ID);
     // ������� ����������� �� �������
    FWizard.App.ProjectX.PicsX.Remove(Pic.ID);
  end;

  procedure TFileOpThread.DoDelPicAndFile(Pic: IPhotoAlbumPic);
  var wsFileName: WideString;
  begin
     // ������� ����
    wsFileName := Pic.FileName;
    DoDeleteFile(wsFileName, FWizard.DelFile_DeleteToRecycleBin);
     // ������� �����������
    DoDeletePic(Pic);
     // ������������� �����
    FWizard.LogSuccess('SLogEntry_PicDeletedOK', [wsFileName]);
  end;

  procedure TFileOpThread.DoRebuildThumb(Pic: IPhotoAlbumPic);
  var
    iPrevThumbSize, iPrevFileSize: Integer;
    ThumbSize: TSize;
  begin
     // ���������� ������� ������� ������ � �����
    iPrevThumbSize := Length(Pic.ThumbnailData);
    iPrevFileSize  := Pic.FileSize;
     // ���������� ������������ ������� ������
    ThumbSize := FWizard.App.Project.ThumbnailSize;
    if Pic.Rotation in [pr90, pr270] then Swap(ThumbSize.cx, ThumbSize.cy); 
     // ������������� �����
    Pic.ReloadPicFileData(
      ThumbSize,
      TPhoaStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)),
      FWizard.App.Project.ThumbnailQuality);
     // ������������� �����
    FWizard.LogSuccess(
      'SLogEntry_ThumbRebuiltOK',
      [Pic.FileName, iPrevThumbSize, Length(Pic.ThumbnailData), iPrevFileSize, Pic.FileSize]);
    FChangesMade := True;
  end;

  procedure TFileOpThread.DoRepairFileLink(Pic: IPhotoAlbumPic);
  begin
    //#ToDo3: �������� repair routine
  end;

  procedure TFileOpThread.DoUpdateFileLink(Pic: IPhotoAlbumPic; const wsNewFileName: WideString);
  var wsPrevFileName: WideString;
  begin
     // ���������, ����� �� ��������� ����
    if not WideSameText(Pic.FileName, wsNewFileName) and (FWizard.App.Project.Pics.IndexOfFileName(wsNewFileName)>=0) then
      PhoaExceptionConst('SLogEntry_PicRelinkingError', [wsNewFileName]);
     // ���������� (���� ��� ���������� ������, �.�. ������� ����� ����������)
    wsPrevFileName := Pic.FileName;
    if wsPrevFileName<>wsNewFileName then begin
      Pic.FileName := wsNewFileName;
      FWizard.LogSuccess('SLogEntry_PicRelinkedOK', [wsPrevFileName, wsNewFileName]);
      FChangesMade := True;
    end;
  end;

  procedure TFileOpThread.Execute;
  var
    Pic: IPhotoAlbumPic;
    wsFileName: WideString;
  begin
    while not Terminated do begin
       // ������������ �����������
      Pic := FWizard.SelectedPics[0];
      wsFileName := Pic.FileName;
      FErrorOccured := False;
      FChangesMade := False;
      try
        case FWizard.FileOpKind of
          fokCopyFiles,
            fokMoveFiles:     DoCopyMovePic(Pic);
          fokDeleteFiles:     DoDelPicAndFile(Pic);
          fokRebuildThumbs:   DoRebuildThumb(Pic);
          fokRepairFileLinks: DoRepairFileLink(Pic);
        end;
      except
        on e: Exception do begin
          FErrorOccured := True;
          FWizard.LogFailure('SLogEntry_FileOpError', [wsFileName, GetWideExceptionMessage(e)]);
        end;
      end;
       // ������������ ���������
      Synchronize(FWizard.ThreadPicProcessed);
    end;
  end;

   //===================================================================================================================
   // TdFileOpsWizard
   //===================================================================================================================

  procedure TdFileOpsWizard.CreateExportedPhoa;
   // ������� ����������� ������ (�� �������; �������; �� �������, �� ������� ���� �� � ��������)
  type TGroupSelection = (gsNotSelected, gsSelected, gsChildSelected);

     // ���������� ����������� ������ � ������� (������ ��� ������ SelPicMode=fospmSelGroups)
    function GetGroupSelection(Group: IPhoaPicGroup): TGroupSelection;
    var i: Integer;
    begin
      if FSelectedGroups.IndexOfID(Group.ID)>=0 then
        Result := gsSelected
      else begin
        Result := gsNotSelected;
        for i := 0 to Group.Groups.Count-1 do
          if GetGroupSelection(Group.Groups[i])<>gsNotSelected then begin
            Result := gsChildSelected;
            Break;
          end;
      end;
    end;

     // ���������� ��������� ��������� ������ � ����������� (������ ��� ������ SelPicMode=fospmSelGroups)
    procedure AddGroup(TgtGroup, OwnerGroup, SrcGroup: IPhotoAlbumPicGroup; bUseTgtGroup: Boolean);
    var
      GS: TGroupSelection;
      i: Integer;
    begin
      GS := GetGroupSelection(SrcGroup);
       // ���� ������ ��� ��������� ������� - ��������� ������ � ��������
      if GS<>gsNotSelected then begin
         // ���� ��� �� �������� ������, ������ �����. target-������
        if not bUseTgtGroup then TgtGroup := NewPhotoAlbumPicGroup(OwnerGroup, 0);
         // �������� �������� �������� ������. ���� ������� ���� ������, ��������� � �� � ����������� �������� ������
        TgtGroup.Assign(SrcGroup, True, GS=gsSelected, False);
         // ��������� �� �� ��� ���� ��������
        for i := 0 to SrcGroup.Groups.Count-1 do AddGroup(nil, TgtGroup, SrcGroup.GroupsX[i], False);
      end;
    end;

     // ��������� ��������� ������ � ����������
    procedure AddSingleGroup(TgtGroup, SrcGroup: IPhotoAlbumPicGroup; bUseTgtAsOwnerGroup: Boolean);
    begin
       // ���� ��� �� �������� ������, ������ �����. target-������
      if bUseTgtAsOwnerGroup then TgtGroup := NewPhotoAlbumPicGroup(TgtGroup, 0);
       // �������� �������� �������� ������
      TgtGroup.Assign(SrcGroup, True, False, False);
       // ��������� ��������� �����������
      TgtGroup.PicsX.Add(FSelectedPics, True);
    end;

  begin
     // ������ ����������
    FExportedProject := NewPhotoAlbumProject;
     // �������� ���������
    FExportedProject.Assign(FApp.Project, False);
     // ����������� �����
    FExportedProject.Description := FCDOpt_PhoaDesc;
    FExportedProject.FileName    := IncludeTrailingPathDelimiter(FDestinationFolder)+FCDOpt_PhoaFileName;
     // �������� �����������
    FExportedProject.PicsX.DuplicatePics(FSelectedPics);
     // �������� ������ � ����������� � ���
    case SelPicMode of
      fospmSelPics:   AddSingleGroup(FExportedProject.RootGroupX, FApp.CurGroupX, FApp.CurGroup<>FApp.Project.RootGroup);
      fospmAll:       FExportedProject.RootGroupX.Assign(FApp.ProjectX.RootGroupX, True, True, True);
      fospmSelGroups: AddGroup(FExportedProject.RootGroupX, nil, FApp.ProjectX.RootGroupX, True);
    end;
     // �������� �������������
    if FCDOpt_IncludeViews then FExportedProject.ViewsX.Assign(FApp.Project.Views);
  end;

  procedure TdFileOpsWizard.DoCreate;
  var wsOptPageTitle: WideString;
  begin
    inherited DoCreate;
     // ������ ��������
    wsOptPageTitle := DKLangConstW('SWzPageFileOps_Options');
    Controller.CreatePage(TfrWzPageFileOps_SelTask,        IWzFileOpsPageID_SelTask,        IDH_intf_file_ops_seltask,   DKLangConstW('SWzPageFileOps_SelTask'));
    Controller.CreatePage(TfrWzPageFileOps_SelPics,        IWzFileOpsPageID_SelPics,        IDH_intf_file_ops_selpics,   DKLangConstW('SWzPageFileOps_SelPics'));
    Controller.CreatePage(TfrWzPageFileOps_SelFolder,      IWzFileOpsPageID_SelFolder,      IDH_intf_file_ops_selfolder, DKLangConstW('SWzPageFileOps_SelFolder'));
    Controller.CreatePage(TfrWzPageFileOps_MoveOptions,    IWzFileOpsPageID_MoveOptions,    IDH_intf_file_ops_moveopts,  wsOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_MoveOptions2,   IWzFileOpsPageID_MoveOptions2,   IDH_intf_file_ops_moveopts2, wsOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_CDOptions,      IWzFileOpsPageID_CDOptions,      IDH_intf_file_ops_cdopts,    wsOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_DelOptions,     IWzFileOpsPageID_DelOptions,     IDH_intf_file_ops_delopts,   wsOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_RepairOptions,  IWzFileOpsPageID_RepairOptions,  IDH_intf_file_ops_repropts,  wsOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_RepairSelLinks, IWzFileOpsPageID_RepairSelLinks, 0{#ToDo3: ������� HelpTopic}, DKLangConstW('SWzPageFileOps_RepairSelLinks'));
    Controller.CreatePage(TfrWzPage_Processing,            IWzFileOpsPageID_Processing,     IDH_intf_file_ops_process,   DKLangConstW('SWzPageFileOps_Processing'));
    Controller.CreatePage(TfrWzPage_Log,                   IWzFileOpsPageID_Log,            IDH_intf_file_ops_log,       DKLangConstW('SWzPageFileOps_Log'));
  end;

  procedure TdFileOpsWizard.DoSelectPictures;
  var i: Integer;
  begin
     // ��������� �����������
    FSelectedPics := NewPhotoAlbumPicList(True);
    case SelPicMode of
      fospmSelPics:   FSelectedPics.Assign(FApp.SelectedPics);
      fospmAll:       FSelectedPics.Assign(FApp.Project.Pics);
      fospmSelGroups: for i := 0 to FSelectedGroups.Count-1 do FSelectedPics.Add(FSelectedGroups[i].Pics, True);
      else            FSelectedPics := nil;
    end;
     // ������� [��]������������
    if FSelPicValidityFilter<>fospvfAny then
      for i := FSelectedPics.Count-1 downto 0 do
        if FileExists(FSelectedPics[i].FileName)<>(FSelPicValidityFilter=fospvfValidOnly) then FSelectedPics.Delete(i);
  end;

  procedure TdFileOpsWizard.ExecuteFinalize;
  begin
    FreeAndNil(FRepair_FileLinks);
    FExportedProject := nil;
    FSelectedPics    := nil;
    FSelectedGroups  := nil;
    FreeAndNil(FLog);
    inherited ExecuteFinalize;
  end;

  procedure TdFileOpsWizard.ExecuteInitialize;
  begin
    inherited ExecuteInitialize;
    FSelectedGroups := NewPhotoAlbumPicGroupList(nil);
     // ���� �� ������ ������� ������, ������� � � ������
    if FApp.CurGroup<>nil then FSelectedGroups.Add(FApp.CurGroup);
     // ����������� ����� ������ ����������� �� ���������
    if FSelPicsByDefault and (FApp.SelectedPics.Count>0) then FSelPicMode := fospmSelPics
    else if FSelectedGroups.Count>0 then                      FSelPicMode := fospmSelGroups
    else                                                      FSelPicMode := fospmAll;
     // �������������� �����
    FCDOpt_CopyExecutable        := True;
    FCDOpt_IncludeViews          := True;
    FCDOpt_CreatePhoa            := True;
    FCDOpt_CreateAutorun         := True;
    FCDOpt_CopyIniSettings       := True;
    FCDOpt_CopyLangFile          := True;
    FCDOpt_MediaLabel            := DKLangConstW('SPhotoAlbumNode');
    FCDOpt_PhoaDesc              := FApp.Project.Description;
    FCDOpt_PhoaFileName          := ExtractFileName(FApp.Project.FileName);
    FMoveFile_ReplaceChar        := '_';
    FMoveFile_FileNameFormat     := 'Image_{ID}';
    FMoveFile_DeleteToRecycleBin := True;
    FMoveFile_OverwriteMode      := fomfomPrompt;
    FMoveFile_UseCDOptions       := True;
    FDelFile_DeleteToRecycleBin  := True;
    FRepair_MatchFlags           := [formfName, formfSize];
    FRepair_LookSubfolders       := True;
  end;

  procedure TdFileOpsWizard.FinalizeProcessing;
  var wsDestPath: WideString;

    procedure SaveExportedProject;
    begin
      try
        FExportedProject.SaveToFile(FExportedProject.FileName, SProject_Generator, SProject_Remark, FExportedProject.FileRevision);
        LogSuccess('SLogEntry_PhoaSavedOK', [FExportedProject.FileName]);
      except
        on e: Exception do LogFailure('SLogEntry_PhoaSaveError', [FExportedProject.FileName, GetWideExceptionMessage(e)]);
      end;
    end;

    procedure CopyExecutable;
    begin
      if WideCopyFile(
          PWideChar(wsApplicationPath+SPhoaExecutableFileName),
          PWideChar(wsDestPath+SPhoaExecutableFileName),
          False) then
        LogSuccess('SLogEntry_ExecutableCopiedOK', [FDestinationFolder])
      else
        LogFailure('SLogEntry_ExecutableCopyingError', [FDestinationFolder, WideSysErrorMessage(GetLastError)]);
    end;

    procedure CopyLangFile;
    var
      pRes: PDKLang_LangResource;
      wsLangFile, wsDestLangFile: WideString;
    begin
       // ���� ���� ���������� �� ����� �� ���������
      if LangManager.LanguageID<>LangManager.DefaultLanguageID then begin
        pRes := LangManager.LanguageResources[LangManager.LanguageIndex];
         // ���� ������ - ��� �������� ����
        if pRes.Kind=dklrkFile then begin
           // ������� ����� ������
          wsLangFile     := pRes.wsName;
          wsDestLangFile := wsDestPath+SRelativeLangFilesPath+WideExtractFileName(wsLangFile);
           // ������ ������� �������� ������
          if WideForceDirectories(wsDestPath+SRelativeLangFilesPath) then
             // ��������
            if CopyFileW(PWideChar(wsLangFile), PWideChar(wsDestLangFile), False) then
              LogSuccess('SLogEntry_LangFileCopiedOK', [wsLangFile, wsDestLangFile])
            else
              LogFailure('SLogEntry_LangFileCopyingError', [wsLangFile, wsDestLangFile, WideSysErrorMessage(GetLastError)])
          else
            LogFailure('SErrCannotCreateFolder', [wsDestPath+SRelativeLangFilesPath]);
        end;
      end;
    end;

    procedure CreateAutorun;
    var fs: TFileStream;

      procedure FSWriteLine(const ws: WideString; const aParams: Array of const);
      var wsf: WideString;
      begin
        wsf := WideFormat(ws, aParams)+S_CRLF;
        fs.Write(wsf[1], Length(wsf)*2);
      end;

    begin
      try
        fs := TFileStream.Create(wsDestPath+'autorun.inf', fmCreate);
        try
          FSWriteLine(
            '[autorun]'+S_CRLF+
            'open=%s "%s"'+S_CRLF+
            'icon=%0:s,1',
            [SPhoaExecutableFileName, FCDOpt_PhoaFileName]);
          if FCDOpt_MediaLabel<>'' then FSWriteLine('label=%s', [FCDOpt_MediaLabel]);
        finally
          fs.Free;
        end;
        LogSuccess('SLogEntry_AutorunCreatedOK', []);
      except
        on e: Exception do LogFailure('SLogEntry_AutorunCreationError', [e.Message]);
      end;
    end;
    
  begin
     // ��������� ������ �� ���������� CD/DVD, ���� �����
    if (FFileOpKind in [fokCopyFiles, fokMoveFiles]) and FMoveFile_UseCDOptions then begin
      wsDestPath := WideIncludeTrailingPathDelimiter(FDestinationFolder);
       // ���� ���� ����������, ��������� ��� � ����
      if FExportedProject<>nil then SaveExportedProject;
       // �������� ���������
      if FCDOpt_CopyExecutable then begin
        CopyExecutable;
         // ���������� ������� ��������� � phoa.ini
        if FCDOpt_CopyIniSettings then IniSaveSettings(wsDestPath+SDefaultIniFileName);
         // ���������� ������� �������� ����
        if FCDOpt_CopyLangFile then CopyLangFile;
      end;
       // ������ autorun.inf
      if (FExportedProject<>nil) and FCDOpt_CreateAutorun then CreateAutorun;
    end;
     // ��������� ����� �������/���������� ��������
    if (FCountErrors=0) and SettingValueBool(ISettingID_Dlgs_FOW_LogOnErrOnly) then
      ModalResult := mrOK
    else
      Controller.SetVisiblePageID(IWzFileOpsPageID_Log, pcmNextBtn);
  end;

  function TdFileOpsWizard.GetNextPageID: Integer;
  begin
    Result := 0;
    case CurPageID of
      IWzFileOpsPageID_SelTask:          Result := IWzFileOpsPageID_SelPics;
      IWzFileOpsPageID_SelPics:
        case FFileOpKind of
          fokCopyFiles,
            fokMoveFiles,
            fokRepairFileLinks:          Result := IWzFileOpsPageID_SelFolder;
          fokDeleteFiles:                Result := IWzFileOpsPageID_DelOptions;
          fokRebuildThumbs:              Result := IWzFileOpsPageID_Processing;
        end;
      IWzFileOpsPageID_SelFolder:
        case FFileOpKind of
          fokCopyFiles,
            fokMoveFiles:                Result := IWzFileOpsPageID_MoveOptions;
          fokRepairFileLinks:            Result := IWzFileOpsPageID_RepairOptions;
        end;
      IWzFileOpsPageID_MoveOptions:      Result := IWzFileOpsPageID_MoveOptions2;
      IWzFileOpsPageID_MoveOptions2:     Result := iif(FMoveFile_UseCDOptions, IWzFileOpsPageID_CDOptions, IWzFileOpsPageID_Processing);
      IWzFileOpsPageID_RepairOptions:    Result := IWzFileOpsPageID_RepairSelLinks;
      IWzFileOpsPageID_CDOptions,
        IWzFileOpsPageID_DelOptions,
        IWzFileOpsPageID_RepairSelLinks: Result := IWzFileOpsPageID_Processing;
      IWzFileOpsPageID_Processing:       Result := IWzFileOpsPageID_Log;
    end;
  end;

  function TdFileOpsWizard.GetRelativeRegistryKey: AnsiString;
  begin
    Result := SRegFileOps_Root;
  end;

  function TdFileOpsWizard.GetStartPageID: Integer;
  begin
    Result := IWzFileOpsPageID_SelTask;
  end;

  procedure TdFileOpsWizard.InterruptProcessing;
  begin
    FProcessingInterrupted := True;
  end;

  function TdFileOpsWizard.IsBtnBackEnabled: Boolean;
  begin
     // �� �������� ��������� �������� ���, �� �������� ������ ��������� ����� ������ ���� ��� ���� �����
    Result :=
      inherited IsBtnBackEnabled and
      (CurPageID<>IWzFileOpsPageID_Processing) and
      ((CurPageID<>IWzFileOpsPageID_Log) or (FSelectedPics.Count>0));
  end;

  function TdFileOpsWizard.IsBtnCancelEnabled: Boolean;
  begin
    Result :=
      inherited IsBtnCancelEnabled and
      ((CurPageID<>IWzFileOpsPageID_Processing) or not FProcessing);
  end;

  function TdFileOpsWizard.IsBtnNextEnabled: Boolean;
  begin
    Result := inherited IsBtnNextEnabled;
    if Result then
      case CurPageID of
         // �� �������� ��������� ������ ����� ���� ������ ��� ������������� �������� � ������� ������� ���������
        IWzFileOpsPageID_Processing: Result := not FProcessing and (FLog<>nil);
      end;
  end;

  procedure TdFileOpsWizard.LogFailure(const ws: WideString; const aParams: array of const);
  begin
    Inc(FCountErrors);
    FLog.Add('[!] '+DKLangConstW(ws, aParams));
  end;

  function TdFileOpsWizard.LogPage_GetLog(iPageID: Integer): TWideStrings;
  begin
    Result := FLog;
  end;

  procedure TdFileOpsWizard.LogSuccess(const ws: WideString; const aParams: array of const);
  begin
    FLog.Add('[+] '+DKLangConstW(ws, aParams));
  end;

  procedure TdFileOpsWizard.PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
  begin
    inherited PageChanged(ChangeMethod, iPrevPageID);
    if (ChangeMethod=pcmNextBtn) and (CurPageID=IWzFileOpsPageID_Processing) then StartProcessing;
  end;

  function TdFileOpsWizard.PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
  begin
    Result := inherited PageChanging(ChangeMethod, iNewPageID);
    if Result and (ChangeMethod=pcmNextBtn) then begin
      case iNewPageID of
         // ��� ��������� �� �������� ������ ����������� ����������� ������, ������ ������� ���������
        IWzFileOpsPageID_SelPics: FSelectedPics := nil;
         // ��� ��������� �� �������� ����� �������������� ������ ����������� ������, ������ ������� �����
        IWzFileOpsPageID_RepairOptions: FreeAndNil(FRepair_FileLinks);
         // ��� ��������� �� �������� ������ ������ ������� ���������� ������� ������
        IWzFileOpsPageID_RepairSelLinks: Repair_SelectFiles;
         // ����� ������� ��������� ��������� ������������� �������������
        IWzFileOpsPageID_Processing: Result := PhoaConfirm(True, 'SConfirm_PerformFileOperation', aFileOpConfirmSettingIDs[FFileOpKind]);
      end;
      if Result then
        case CurPageID of
           // ����� ������ ������ ����������� ����� �� ���������
          IWzFileOpsPageID_SelTask: if FFileOpKind=fokRepairFileLinks then FSelPicValidityFilter := fospvfInvalidOnly;
           // ��� ����� �� �������� ������ ����������� ������ ������ �����������
          IWzFileOpsPageID_SelPics: DoSelectPictures;
           // ��� ����� �� �������� ����� �������������� ������ ������ ������ ������
          IWzFileOpsPageID_RepairOptions: Repair_SelectFiles;
        end;
    end;
  end;

  function TdFileOpsWizard.ProcPage_GetCurrentStatus: WideString;
  begin
     // ���� ������� �������, ���������� ��������
    if FProcessing then
      Result := DKLangConstW('SWzFileOps_Processing', [ProcPage_GetProgressCur+1, FInitialPicCount, FCountErrors, FSelectedPics[0].FileName])
     // ����� ����� ���������� � ����������� �����������
    else
      Result := DKLangConstW('SWzFileOps_Paused', [FCountSucceeded, FCountErrors]);
  end;

  function TdFileOpsWizard.ProcPage_GetProcessingActive: Boolean;
  begin
    Result := FProcessing;
  end;

  function TdFileOpsWizard.ProcPage_GetProgressCur: Integer;
  begin
    Result := FInitialPicCount-FSelectedPics.Count;
  end;

  function TdFileOpsWizard.ProcPage_GetProgressMax: Integer;
  begin
    Result := FInitialPicCount;
  end;

  procedure TdFileOpsWizard.ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
  begin
    if FSelectedPics.Count>0 then PaintThumbnail(FSelectedPics[0], Bitmap32);
  end;

  procedure TdFileOpsWizard.Repair_SelectFiles;

     // ��������� ������ ����� � FRepair_FileLinks � ������� � ���� ������ �� �����������, ������� �� �������� ��
     //   ������� �������� ���������
    procedure AddFile(const wsPath: WideString; const SRec: TSearchRecW);
    var
      FL: TFileLink;
      i: Integer;
      bMatches: Boolean;
      Pic: IPhoaPic;
    begin
      FL := nil;
       // ���������� ��� �����������, ������� ����������
      for i := 0 to FSelectedPics.Count-1 do begin
        Pic := FSelectedPics[i];
         // ��������� ���������� - ������� �� �������, ����� �� ����� ����� (��� �������)
        bMatches := True;
        if bMatches and (formfSize in FRepair_MatchFlags) then bMatches := SRec.Size=Pic.FileSize;
        if bMatches and (formfName in FRepair_MatchFlags) then bMatches := WideSameText(SRec.Name, WideExtractFileName(Pic.FileName));
         // ��������� ����������� �� "���������" ������ ������������
        if bMatches and not FRepair_RelinkFilesInUse      then bMatches := FApp.Project.Pics.IndexOfFileName(wsPath+SRec.Name)<0;
         // ���� ��������
        if bMatches then begin
           // ������ ����, ���� �� ��� �� ������
          if FL=nil then FL := FRepair_FileLinks.Add(SRec.Name, wsPath, SRec.Size, FileDateToDateTime(SRec.Time));
           // ��������� ��� ������
          FL.Pics.Add(Pic, True);
        end;
      end;
    end;

     // ���������� ��������� ������� sPath
    procedure AddFolder(const wsPath: WideString; bRecurse: Boolean);
    var
      sr: TSearchRecW;
      iRes: Integer;
    begin
      iRes := WideFindFirst(wsPath+'*.*', faAnyFile, sr);
      try
        while iRes=0 do begin
          if sr.Name[1]<>'.' then
             // ���� ������� - ���������� ���������
            if sr.Attr and faDirectory<>0 then begin
              if bRecurse then AddFolder(wsPath+sr.Name+'\', True);
             // ���� ���� � ���������� ��������� ���� - ��������� � ������ (implicit Unicode-to-Ansi conversion)
            end else if FileFormatList.GraphicFromExtension(WideExtractFileExt(sr.Name))<>nil then
              AddFile(wsPath, sr);
          iRes := WideFindNext(sr);
        end;
      finally
        WideFindClose(sr);
      end;
    end;

  begin
     // ������ ��� ������� ������ ������
    if FRepair_FileLinks=nil then FRepair_FileLinks := TFileLinks.Create else FRepair_FileLinks.Clear;
     // ���������� ��������� �����/�����
    AddFolder(IncludeTrailingPathDelimiter(FDestinationFolder), FRepair_LookSubfolders);
  end;

  procedure TdFileOpsWizard.SettingsInitialLoad(rif: TPhoaRegIniFile);
  begin
    inherited SettingsInitialLoad(rif);
    FDestinationFolder := rif.ReadString('', 'DestinationFolder', ''); 
  end;

  procedure TdFileOpsWizard.SettingsInitialSave(rif: TPhoaRegIniFile);
  begin
    inherited SettingsInitialSave(rif);
    rif.WriteString ('', 'DestinationFolder', FDestinationFolder);
  end;

  procedure TdFileOpsWizard.StartProcessing;
  begin
    FProcessing := True;
     // ������ ��������
    if FLog=nil then FLog := TTntStringList.Create;
     // ������ �������������� ����������
    if (FExportedProject=nil) and (FFileOpKind in [fokCopyFiles, fokMoveFiles]) and FMoveFile_UseCDOptions and FCDOpt_CreatePhoa then CreateExportedPhoa;
     // ���������� �������� ���������� ������
    FInitialPicCount := FSelectedPics.Count;
     // ��������� �������� ���������
    UpdateProgressInfo;
     // ��������� �����
    FProcessingInterrupted := False;
    FFileOpThread := TFileOpThread.Create(Self);
  end;

  procedure TdFileOpsWizard.ThreadPicProcessed;
  begin
     // ���������, ��� ��������� ��������
    if not FFileOpThread.ErrorOccured then Inc(FCountSucceeded);
     // ��������� ������ �������
    HasUpdates := True;
    if FFileOpThread.ChangesMade then FProjectChanged := True;
     // ������� ������������ �����������
    FSelectedPics.Delete(0);
     // ���� ��������� ���� ������, ��������� �����
    if (FSelectedPics.Count=0) or FProcessingInterrupted then begin
      FProcessing := False;
      FFileOpThread.Terminate;
      FFileOpThread := nil;
       // ���� ������ ����, ��������� ���������
      if FSelectedPics.Count=0 then FinalizeProcessing;
    end;
     // ���������� �������� ���������
    UpdateProgressInfo;
  end;

  procedure TdFileOpsWizard.UpdateProgressInfo;
  begin
    Controller.ItemsByID[IWzFileOpsPageID_Processing].Perform(WM_PAGEUPDATE, 0, 0);
    StateChanged;
  end;

end.


