//**********************************************************************************************************************
//  $Id: phPluginUsage.pas,v 1.11 2007-07-03 13:37:40 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phPluginUsage;

interface
uses
  Windows, SysUtils, Classes,
  TntWindows, TntSysUtils, phIntf, phAppIntf, phMutableIntf, phNativeIntf;

type

   //===================================================================================================================
   // ��������� ������ ����������� ������-�������
   //===================================================================================================================

  IPhoaPluginModules = interface(IInterface)
    ['{A96A3A43-3A4B-4514-86FF-40876AA9B508}']
     // �������� Initialize ��� ������� ������
    procedure InitializeAll(App: IPhoaApp);
     // �������� Finalize ��� ������� ������
    procedure FinalizeAll;
     // ������ ������� ���������� ���� � ��������� �� � ������ Plugins
    procedure CreatePlugins(Kinds: TPhoaPluginKinds);
     // ������� ������� ���������� ���� �� ������ Plugins
    procedure ReleasePlugins(Kinds: TPhoaPluginKinds);
     // Prop handlers
    function  GetModuleCount: Integer;
    function  GetModules(Index: Integer): IPhoaPluginModule;
    function  GetPluginCount: Integer;
    function  GetPlugins(Index: Integer): IPhoaPlugin;
     // Props
     // -- ���������� ������� � ������
    property ModuleCount: Integer read GetModuleCount;
     // -- ������ �� �������
    property Modules[Index: Integer]: IPhoaPluginModule read GetModules; default;
     // -- ���������� ��������� ��������
    property PluginCount: Integer read GetPluginCount;
     // -- ��������� ������� �� �������
    property Plugins[Index: Integer]: IPhoaPlugin read GetPlugins;
  end;

var
   // ���������� ������ ������ ������������������ ������-�������
  PluginModules: IPhoaPluginModules;

   // ������ PluginModules � ��������� ������� ��������, ����������� � ��� ���������
  procedure PluginsInitialize;
   // ��������� ��� �������
  procedure PluginsFinalize;

implementation
uses phUtils, phMsgBox, ConsVars, udAbout;

type

   //===================================================================================================================
   // ������ ������-������
   //===================================================================================================================

  P_PluginModuleInfo = ^T_PluginModuleInfo;
  T_PluginModuleInfo = record
    hLib: HINST;               // Handle ����������� ����������
    Module: IPhoaPluginModule; // ����������� ������
  end;

   //===================================================================================================================
   // ������ ������ � ������-�������
   //===================================================================================================================

  T_PluginModuleInfoList = class(TList)
  private
     // Prop handlers
    function GetItems(Index: Integer): P_PluginModuleInfo;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    function  Add(hLib: HINST; Module: IPhoaPluginModule): Integer;
     // ������������ ������. ���������� True, ���� ��������� ���� ������������� �������� ������-�����������
    function  RegisterPluginLib(const wsPluginLib: WideString): Boolean;
     // Props
     // -- ������ �� �������
    property Items[Index: Integer]: P_PluginModuleInfo read GetItems; default;
  end;

  function T_PluginModuleInfoList.Add(hLib: HINST; Module: IPhoaPluginModule): Integer;
  var p: P_PluginModuleInfo;
  begin
    New(p);
    Result := inherited Add(p);
    p.hLib   := hLib;
    p.Module := Module;
  end;

  constructor T_PluginModuleInfoList.Create;

     // ����������� ��������� ������������ ��������
    procedure ScanPluginDir(const wsDir: WideString);
    var
      wsPath: WideString;
      SRec: TSearchRecW;
    begin
      wsPath := WideIncludeTrailingPathDelimiter(wsDir);
      if WideFindFirst(wsPath+'*.*', faAnyFile, SRec)=0 then
        try
          repeat
             // ����, �������� ������
            if SRec.Attr and faDirectory=0 then begin
              if WideUpperCase(WideExtractFileExt(SRec.Name))='.DLL' then RegisterPluginLib(wsPath+SRec.Name);
             // �������
            end else if SRec.Name[1]<>'.' then
              ScanPluginDir(wsPath+SRec.Name);
          until WideFindNext(SRec)<>0;
        finally
          WideFindClose(SRec);
        end;
    end;

  begin
    inherited Create;
     // ��������� ������� ��������
    ScanPluginDir(wsApplicationPath+SRelativePluginPath);
  end;

  function T_PluginModuleInfoList.GetItems(Index: Integer): P_PluginModuleInfo;
  begin
    Result := Get(Index);
  end;

  procedure T_PluginModuleInfoList.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action=lnDeleted then begin
       // ����������� ��������� ������
      P_PluginModuleInfo(Ptr).Module := nil;
       // ��������� ����������
      FreeLibrary(P_PluginModuleInfo(Ptr).hLib);
       // ����������� ������
      Dispose(P_PluginModuleInfo(Ptr));
    end;
  end;

  function T_PluginModuleInfoList.RegisterPluginLib(const wsPluginLib: WideString): Boolean;
  var
    hLib: HINST;
    GetRevisionProc: TPhoaGetPluginSubsystemRevision;
    GetModuleProc: TPhoaGetPluginModuleProc;
  begin
    Result := False;
     // ������ ����������
    ShowProgressInfo('SMsg_LoadingPlugin', [WideExtractFileName(wsPluginLib)]);
    hLib := Tnt_LoadLibraryW(PWideChar(wsPluginLib));
    if hLib<>0 then begin
      try
         // �������� �������� ������� ��������� ������ ����������
        GetRevisionProc := GetProcAddress(hLib, 'PhoaGetPluginSubsystemRevision');
         // ���� �������, � ������ ������ ��, ��� ����
        if Assigned(GetRevisionProc) and (GetRevisionProc=IPhoaPluginSubsystemRevision) then begin
           // �������� �������� ���������
          GetModuleProc := GetProcAddress(hLib, 'PhoaGetPluginModule');
           // ���� ������� - ������������ ������
          if Assigned(GetModuleProc) then begin
            Add(hLib, GetModuleProc);
            Result := True;
          end;
        end;
      except
        on e: Exception do PhoaError('SErrCreatingPluginModule', [wsPluginLib, GetWideExceptionMessage(e)]);
      end;
       // ��� ������� ��������� ���������
      if not Result then FreeLibrary(hLib);
    end else
      PhoaError('SErrLoadingPluginModule', [wsPluginLib, WideSysErrorMessage(GetLastError)]);
  end;

   //===================================================================================================================
   // TPhoaPluginModules - ���������� IPhoaPluginModules
   //===================================================================================================================
type
  TPhoaPluginModules = class(TInterfacedObject, IPhoaPluginModules)
  private
     // ������ �������
    FModuleList: T_PluginModuleInfoList;
     // ������ ��������� ��������
    FPlugins: IInterfaceList; 
     // IPhoaPluginModules
    procedure InitializeAll(App: IPhoaApp);
    procedure FinalizeAll;
    procedure CreatePlugins(Kinds: TPhoaPluginKinds);
    procedure ReleasePlugins(Kinds: TPhoaPluginKinds);
    function  GetModuleCount: Integer;
    function  GetModules(Index: Integer): IPhoaPluginModule;
    function  GetPluginCount: Integer;
    function  GetPlugins(Index: Integer): IPhoaPlugin;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  constructor TPhoaPluginModules.Create;
  begin
    inherited Create;
    FModuleList := T_PluginModuleInfoList.Create;
    FPlugins    := TInterfaceList.Create;
  end;

  procedure TPhoaPluginModules.CreatePlugins(Kinds: TPhoaPluginKinds);
  var
    iModule, iClass: Integer;
    Module: IPhoaPluginModule;
    PClass: IPhoaPluginClass;
    Plugin: IPhoaPlugin;
  begin
     // ���� �� �������
    for iModule := 0 to FModuleList.Count-1 do begin
      Module := FModuleList[iModule].Module;
       // ���� �� ������� �������� ������
      for iClass := 0 to Module.PluginClassCount-1 do begin
        PClass := Module.PluginClasses[iClass];
         // ���� ��� ������� ��������, ������ � ������������ ������
        if PClass.Kind in Kinds then begin
          Plugin := PClass.CreatePlugin;
          FPlugins.Add(Plugin);
        end;
      end;
    end;
  end;

  destructor TPhoaPluginModules.Destroy;
  begin
    FPlugins := nil;
    FModuleList.Free;
    inherited Destroy;
  end;

  procedure TPhoaPluginModules.FinalizeAll;
  var i: Integer;
  begin
    for i := 0 to FModuleList.Count-1 do FModuleList[i].Module.Finalize;
  end;

  function TPhoaPluginModules.GetModuleCount: Integer;
  begin
    Result := FModuleList.Count;
  end;

  function TPhoaPluginModules.GetModules(Index: Integer): IPhoaPluginModule;
  begin
    Result := FModuleList[Index].Module;
  end;

  function TPhoaPluginModules.GetPluginCount: Integer;
  begin
    Result := FPlugins.Count;
  end;

  function TPhoaPluginModules.GetPlugins(Index: Integer): IPhoaPlugin;
  begin
    Result := IPhoaPlugin(FPlugins[Index]);
  end;

  procedure TPhoaPluginModules.InitializeAll(App: IPhoaApp);
  var i: Integer;
  begin
    for i := 0 to FModuleList.Count-1 do FModuleList[i].Module.Initialize(App);
  end;

  procedure TPhoaPluginModules.ReleasePlugins(Kinds: TPhoaPluginKinds);
  var i: Integer;
  begin
    for i := FPlugins.Count-1 downto 0 do
      if IPhoaPlugin(FPlugins[i]).PluginClass.Kind in Kinds then FPlugins.Delete(i);
  end;

   //===================================================================================================================

  procedure PluginsInitialize;
  begin
    PluginModules := TPhoaPluginModules.Create;
  end;

  procedure PluginsFinalize;
  begin
    PluginModules := nil;
  end;

end.
 
