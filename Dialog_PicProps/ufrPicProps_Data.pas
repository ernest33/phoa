//**********************************************************************************************************************
//  $Id: ufrPicProps_Data.pas,v 1.4 2007-06-30 10:36:21 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_Data;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phWizard,
  phPicPropsDlgPage, DKLang, Mask, ToolEdit, TntStdCtrls, StdCtrls;

type
   // ��������� �������� �������������� �������� �����������
  TPicEditorPropValueState = (
    pvsUnassigned, // �������� ��� �� ��������������
    pvsUniform,    // �������� �������� ��������� � ���� ��������� �����������
    pvsVarious,    // �������� �������� �������� � ��������� �����������
    pvsModified);  // �������� �������� ���� �������������� �������������

   // �������� �������������� �������� �����������
  PPicEditorPropValue = ^TPicEditorPropValue;
  TPicEditorPropValue = record
    State:   TPicEditorPropValueState; // ��������� �������� ��������
    vValue:  Variant;                  // �������� �������� ��� State=[pvsUniform, pvsModified]
    Control: TWinControl;              // [��������] �������, ���������� �� �������������� ��������
  end;

  TPicEditorPropValues = Array[TPicProperty] of TPicEditorPropValue;

  TfrPicProps_Data = class(TPicPropsDialogPage)
    cbAuthor: TTntComboBox;
    cbFilmNumber: TTntComboBox;
    cbMedia: TTntComboBox;
    cbPlace: TTntComboBox;
    dklcMain: TDKLanguageController;
    eDate: TDateEdit;
    eFrameNumber: TTntEdit;
    eTime: TMaskEdit;
    lAuthor: TTntLabel;
    lDate: TTntLabel;
    lDesc: TTntLabel;
    lFilmNumber: TTntLabel;
    lFrameNumber: TTntLabel;
    lMedia: TTntLabel;
    lNotes: TTntLabel;
    lPlace: TTntLabel;
    lTime: TTntLabel;
    mDesc: TTntMemo;
    mNotes: TTntMemo;
    procedure PicPropEditorChange(Sender: TObject);
  private
     // ���� ����, ��� �������� �� �������� �������������������
    FInitialized: Boolean;
     // ������� �������� �������
    FPropVals: TPicEditorPropValues;
     // ���� ��������������� ��������� �������� � ��������
    FForcingCtlVal: Boolean;
     // ��������� � �������� ������ �����������
    procedure LoadPicControls;
     // ������������� �������� �������� � ��������������� ��������� � ��� ���������. ��� bStateOnly=True ������ ������
     //   ���������
    procedure SetPropEditor(Prop: TPicProperty; bStateOnly: Boolean);
     // ���������� � ������ ����������� ������������� �������� �������� Prop
    procedure PropValEdited(Prop: TPicProperty);
  protected
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
  public
    function  CanApply: Boolean; override;
    procedure Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams); override;
  end;

implementation
{$R *.dfm}
uses phUtils, TypInfo, phPhoa;

const
   // ������������� ��������
  EditablePicProps: TPicProperties = [
    ppDate, ppTime, ppPlace, ppFilmNumber, ppFrameNumber, ppAuthor, ppDescription, ppNotes, ppMedia];

  procedure TfrPicProps_Data.Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams);
  var
    ChgList: IPhoaPicPropertyChangeList;
    Prop: TPicProperty;
  begin
     // ���� �������� ����������
    if FInitialized then begin
       // ���������� ������ ���������
      ChgList := NewPhoaPicPropertyChangeList;
      for Prop := Low(Prop) to High(Prop) do
        if (Prop in EditablePicProps) and (FPropVals[Prop].State=pvsModified) then ChgList.Add(FPropVals[Prop].vValue, Prop);
       // ���� ���� ��������� - ���������� ��������� �����������
      if ChgList.Count>0 then begin
        wsOpParamName := 'EditDataOpParams';
        OpParams      := NewPhoaOperationParams(['Pics', EditedPics, 'ChangeList', ChgList]);
      end;
    end;
  end;

  procedure TfrPicProps_Data.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    if not FInitialized then begin
       // ��������� ������ ����, �����, �������, ���������
      StringsLoadPFAM(App.Project, cbPlace.Items, cbFilmNumber.Items, cbAuthor.Items, cbMedia.Items);
       // ��������� ������ ����������� � ��������
      LoadPicControls;
      FInitialized := True;
    end;
  end;

  function TfrPicProps_Data.CanApply: Boolean;
  var d: TDateTime;
  begin
     // ���� ������ ����������, ��������� ���� � �����
    Result := not FInitialized or (CheckMaskedDateTime(eDate.Text, False, d) and CheckMaskedDateTime(eTime.Text, True, d));
  end;

  procedure TfrPicProps_Data.LoadPicControls;

     // ��������� ������ FPropVals[], ��������� ���������
    procedure FillPropVals;
    var
      i: Integer;
      Pic: IPhotoAlbumPic;
      Prop: TPicProperty;
    begin
       // ���� �� ������������
      for i := 0 to EditedPics.Count-1 do begin
        Pic := EditedPics[i];
         // ������������ ��� ������������� �������� � ���������� pvsUnassigned ��� pvsUniform
        for Prop := Low(Prop) to High(Prop) do
          if Prop in EditablePicProps then
            with FPropVals[Prop] do
              case State of
                 // �������� ��� �� �������������, ��� ����� ������ ���������
                pvsUnassigned: begin
                  State  := pvsUniform;
                  vValue := Pic.PropValues[Prop];
                end;
                 // �������� ��� ����, ������� �������. ���� �� ������� - ������ ������������� pvsVarious
                pvsUniform: if not VarSameValue(vValue, Pic.PropValues[Prop]) then State  := pvsVarious;
              end;
      end;
    end;

     // ����������� ��������, �������� � ��� ��������
    procedure AdjustControls;
    var Prop: TPicProperty;
    begin
      for Prop := Low(Prop) to High(Prop) do
        if Prop in EditablePicProps then SetPropEditor(Prop, False);
    end;

  begin
     // �������������� FPropVals[]
    FPropVals[ppDate].Control        := eDate;
    FPropVals[ppTime].Control        := eTime;
    FPropVals[ppPlace].Control       := cbPlace;
    FPropVals[ppFilmNumber].Control  := cbFilmNumber;
    FPropVals[ppFrameNumber].Control := eFrameNumber;
    FPropVals[ppAuthor].Control      := cbAuthor;
    FPropVals[ppDescription].Control := mDesc;
    FPropVals[ppNotes].Control       := mNotes;
    FPropVals[ppMedia].Control       := cbMedia;
     // ���������, ����� �������� ���������, � ����� ���
    FillPropVals;
     // ����������� ��������
    AdjustControls;
  end;

  procedure TfrPicProps_Data.PicPropEditorChange(Sender: TObject);
  var Prop: TPicProperty;
  begin
    if FForcingCtlVal then Exit;
     // ������� �������
    for Prop := Low(Prop) to High(Prop) do
      if (Prop in EditablePicProps) and (FPropVals[Prop].Control=Sender) then begin
         // ������������ ���������
        PropValEdited(Prop);
        Break;
      end;
  end;

  procedure TfrPicProps_Data.PropValEdited(Prop: TPicProperty);
  var
    pv: PPicEditorPropValue;
    dt: TDateTime;
  begin
    pv := @FPropVals[Prop];
    case Prop of
      ppDate: if TryStrToDate(eDate.Text, dt, AppFormatSettings) then pv.vValue := DateToPhoaDate(dt) else pv.vValue := Null;
      ppTime:
        if TryStrToTime(ChangeTimeSeparator(eTime.Text, False), dt, AppFormatSettings) then
          pv.vValue := TimeToPhoaTime(dt)
        else
          pv.vValue := Null;
      ppPlace,
        ppFilmNumber,
        ppFrameNumber,
        ppAuthor,
        ppMedia: pv.vValue := GetStrProp(pv.Control, 'Text');
      ppDescription,
        ppNotes: pv.vValue := (pv.Control as TTntMemo).Text;
    end;
    pv.State := pvsModified;
    SetPropEditor(Prop, True);
    Modified;
  end;

  procedure TfrPicProps_Data.SetPropEditor(Prop: TPicProperty; bStateOnly: Boolean);
  var pv: PPicEditorPropValue;
  begin
    FForcingCtlVal := True;
    try
      pv := @FPropVals[Prop];
       // ����������� ��������
      if not bStateOnly then
        case Prop of
          ppDate: if VarIsNull(pv.vValue) then eDate.Clear else eDate.Date := PhoaDateToDate(pv.vValue);
          ppTime:
            if VarIsNull(pv.vValue) then
              eTime.Clear
            else
              eTime.Text := ChangeTimeSeparator(TimeToStr(PhoaTimeToTime(pv.vValue), AppFormatSettings), True);
          ppPlace,
            ppFilmNumber,
            ppFrameNumber,
            ppAuthor,
            ppMedia: SetStrProp(pv.Control, 'Text', VarToStr(pv.vValue));
          ppDescription,
            ppNotes: (pv.Control as TTntMemo).Text := VarToStr(pv.vValue);
        end;
       // ����������� ����
      SetOrdProp(pv.Control, 'Color', iif(pv.State=pvsVarious, clBtnFace, clWindow));
    finally
      FForcingCtlVal := False;
    end;
  end;

end.

