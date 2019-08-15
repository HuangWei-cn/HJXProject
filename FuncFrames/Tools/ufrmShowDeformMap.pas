unit ufrmShowDeformMap;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uHJX.Intf.AppServices, uHJX.Classes.Meters, uHJX.Intf.Datas, uHJX.Data.Types, ufraDeformMap,
  Vcl.StdCtrls, Vcl.ExtCtrls, Datasnap.DBClient, Vcl.ComCtrls;

type
  TfrmShowDeformPoints = class(TForm)
    Panel1: TPanel;
    btnShowLastData: TButton;
    btnShowTrace: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    btnPeriodDeform: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnShowLastDataClick(Sender: TObject);
    procedure btnShowTraceClick(Sender: TObject);
    procedure btnPeriodDeformClick(Sender: TObject);
  private
    { Private declarations }
    FMap: TfraDeformMap;
    // ������в����������ݣ�����ʾ���в��Ĺ켣
    procedure ShowDeformPoints;
    // ������в�㣬��ʾ���²�ֵ
    procedure ShowLastData;
    // ��ʾָ��ʱ����ڵı�������
    procedure ShowPeriod;
  public
    { Public declarations }
  end;

var
  frmShowDeformPoints: TfrmShowDeformPoints;

implementation

{$R *.dfm}


procedure TfrmShowDeformPoints.btnPeriodDeformClick(Sender: TObject);
begin
  ShowPeriod;
end;

procedure TfrmShowDeformPoints.btnShowLastDataClick(Sender: TObject);
begin
  // ShowDeformPoints;
  ShowLastData;
end;

procedure TfrmShowDeformPoints.btnShowTraceClick(Sender: TObject);
begin
  ShowDeformPoints;
end;

procedure TfrmShowDeformPoints.FormCreate(Sender: TObject);
begin
  FMap := TfraDeformMap.Create(self);
  FMap.Align := alClient;
  FMap.Parent := self;
  dtpEnd.Date := Now;
end;

procedure TfrmShowDeformPoints.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMap);
end;

procedure TfrmShowDeformPoints.ShowDeformPoints;
var
  iMeter, i : Integer;
  Meter     : TMeterDefine;
  Coodinates: DPCoodinates;
  DS        : TClientDataSet;
begin
  FMap.Clear;
  if ExcelMeters.Count = 0 then Exit;
  { todo: ������һ�����⣬����Ӳ��ʱ��Ӧ��������ʾ���������Ӧ����������в������ú�
  �����������һ������ʾ������ }
  // ��һ�г�������Ч���μ���
  try
    DS := TClientDataSet.Create(self);

    for iMeter := 0 to ExcelMeters.Count - 1 do
    begin
      Meter := ExcelMeters.Items[iMeter];
      if (Meter.Params.MeterType = 'ƽ��λ�Ʋ��') and (Meter.DataSheet <> '') then
      begin
        // ȡ���һ�����ݣ�����SDX��SDY�����ԭʼ����
        if Assigned(IAppServices) then
          if Assigned(IAppServices.ClientDatas) then
            if IAppServices.ClientDatas.GetAllPDDatas(Meter.DesignName, DS) then
            begin
              // ��ֻ��һ����¼���򻭲�����ͷ�������Ծ�����
              if DS.RecordCount <= 1 then Continue;

              i := 0;
              DS.First;
              while not DS.Eof do
              begin
                // �ж��Ƿ�X��YΪ�գ�����Ϊ�գ�������������
                if not(DS.Fields[1].IsNull or DS.Fields[2].IsNull) then
                begin
                  Setlength(Coodinates, i + 1);
                  Coodinates[i].DTScale := DS.Fields[0].AsDateTime;
                  Coodinates[i].North := DS.Fields[1].AsFloat;
                  Coodinates[i].East := DS.Fields[2].AsFloat;
                  inc(i);
                end;
                DS.Next;
              end;
              FMap.AddDP(Meter.DesignName, Coodinates);
            end;
      end;
    end;

  finally
    FreeAndNil(DS);
  end;

end;

procedure TfrmShowDeformPoints.ShowLastData;
var
  iMeter, i : Integer;
  Meter     : TMeterDefine;
  Coodinates: DPCoodinates;
  Values    : TVariantDynArray;
  v         : Variant;
  hasNull   : Boolean;
begin
  FMap.Clear;
  if ExcelMeters.Count = 0 then Exit;
  { todo: ������һ�����⣬����Ӳ��ʱ��Ӧ��������ʾ���������Ӧ����������в������ú�
  �����������һ������ʾ������ }
  // ��һ�г�������Ч���μ���
  for iMeter := 0 to ExcelMeters.Count - 1 do
  begin
    Meter := ExcelMeters.Items[iMeter];
    if (Meter.Params.MeterType = 'ƽ��λ�Ʋ��') and (Meter.DataSheet <> '') then
    begin
      // ȡ���һ�����ݣ�����SDX��SDY�����ԭʼ����
      if Assigned(IAppServices) then
        if Assigned(IAppServices.ClientDatas) then
          if IAppServices.ClientDatas.GetLastPDDatas(Meter.DesignName, Values) then
          begin
            hasNull := False;
            for v in Values do
              if VarIsNull(v) then
              begin
                hasNull := True;
                break;
              end;
            if hasNull then Continue;

            try
              Setlength(Coodinates, 2);
              Coodinates[1].DTScale := Values[0];
              Coodinates[1].North := Values[1];
              Coodinates[1].East := Values[2];
              Coodinates[0].DTScale := 0;
              // ע�⣺Values[7]��Values[8]��Sdx��Sdy����λ�Ǻ��ף�Values[1]��Values[2]��λ���ף�
              // ���Values[7]��Values[8]��Ҫ����1000������Ϊ�ס�
              Coodinates[0].North := Values[1] - Values[7] / 1000;
              Coodinates[0].East := Values[2] - Values[8] / 1000;
              FMap.AddDP(Meter.DesignName, Coodinates);
            finally
              Setlength(Coodinates, 0);
            end;
          end;
    end;
  end;
end;

procedure TfrmShowDeformPoints.ShowPeriod;
var
  iMeter, i : Integer;
  Meter     : TMeterDefine;
  Coodinates: DPCoodinates;
  DS        : TClientDataSet;
begin
  FMap.Clear;
  if ExcelMeters.Count = 0 then Exit;
  { todo: ������һ�����⣬����Ӳ��ʱ��Ӧ��������ʾ���������Ӧ����������в������ú�
  �����������һ������ʾ������ }
  // ��һ�г�������Ч���μ���
  try
    DS := TClientDataSet.Create(self);

    for iMeter := 0 to ExcelMeters.Count - 1 do
    begin
      Meter := ExcelMeters.Items[iMeter];
      if (Meter.Params.MeterType = 'ƽ��λ�Ʋ��') and (Meter.DataSheet <> '') then
      begin
        // ȡ���һ�����ݣ�����SDX��SDY�����ԭʼ����
        if Assigned(IAppServices) then
          if Assigned(IAppServices.ClientDatas) then
            if IAppServices.ClientDatas.GetPDDatasInPeriod(Meter.DesignName, dtpStart.Date,
              dtpEnd.Date, DS) then
            begin
              // ��ֻ��һ����¼���򻭲�����ͷ�������Ծ�����
              if DS.RecordCount <= 1 then Continue;

              i := 0;
              DS.First;
              while not DS.Eof do
              begin
                // �ж��Ƿ�X��YΪ�գ�����Ϊ�գ�������������
                if not(DS.Fields[1].IsNull or DS.Fields[2].IsNull) then
                begin
                  Setlength(Coodinates, i + 1);
                  Coodinates[i].DTScale := DS.Fields[0].AsDateTime;
                  Coodinates[i].North := DS.Fields[1].AsFloat;
                  Coodinates[i].East := DS.Fields[2].AsFloat;
                  inc(i);
                end;
                DS.Next;
              end;
              FMap.AddDP(Meter.DesignName, Coodinates);
            end;
      end;
    end;

  finally
    FreeAndNil(DS);
  end;
end;

end.
