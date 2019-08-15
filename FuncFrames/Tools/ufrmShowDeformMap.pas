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
    // 添加所有测点的所有数据，即显示所有测点的轨迹
    procedure ShowDeformPoints;
    // 添加所有测点，显示最新测值
    procedure ShowLastData;
    // 显示指定时间段内的变形数据
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
  { todo: 这里另一个问题，在添加测点时，应不急于显示结果，而是应当添加完所有测点后，设置好
  两轴比例，再一次性显示出来。 }
  // 逐一列出所有有效变形监测点
  try
    DS := TClientDataSet.Create(self);

    for iMeter := 0 to ExcelMeters.Count - 1 do
    begin
      Meter := ExcelMeters.Items[iMeter];
      if (Meter.Params.MeterType = '平面位移测点') and (Meter.DataSheet <> '') then
      begin
        // 取最后一次数据，根据SDX和SDY反算出原始坐标
        if Assigned(IAppServices) then
          if Assigned(IAppServices.ClientDatas) then
            if IAppServices.ClientDatas.GetAllPDDatas(Meter.DesignName, DS) then
            begin
              // 若只有一条记录，则画不出箭头来，所以就跳过
              if DS.RecordCount <= 1 then Continue;

              i := 0;
              DS.First;
              while not DS.Eof do
              begin
                // 判断是否X，Y为空，若不为空，则可以添加数据
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
  { todo: 这里另一个问题，在添加测点时，应不急于显示结果，而是应当添加完所有测点后，设置好
  两轴比例，再一次性显示出来。 }
  // 逐一列出所有有效变形监测点
  for iMeter := 0 to ExcelMeters.Count - 1 do
  begin
    Meter := ExcelMeters.Items[iMeter];
    if (Meter.Params.MeterType = '平面位移测点') and (Meter.DataSheet <> '') then
    begin
      // 取最后一次数据，根据SDX和SDY反算出原始坐标
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
              // 注意：Values[7]、Values[8]是Sdx和Sdy，单位是毫米，Values[1]、Values[2]单位是米，
              // 因此Values[7]、Values[8]需要除以1000，换算为米。
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
  { todo: 这里另一个问题，在添加测点时，应不急于显示结果，而是应当添加完所有测点后，设置好
  两轴比例，再一次性显示出来。 }
  // 逐一列出所有有效变形监测点
  try
    DS := TClientDataSet.Create(self);

    for iMeter := 0 to ExcelMeters.Count - 1 do
    begin
      Meter := ExcelMeters.Items[iMeter];
      if (Meter.Params.MeterType = '平面位移测点') and (Meter.DataSheet <> '') then
      begin
        // 取最后一次数据，根据SDX和SDY反算出原始坐标
        if Assigned(IAppServices) then
          if Assigned(IAppServices.ClientDatas) then
            if IAppServices.ClientDatas.GetPDDatasInPeriod(Meter.DesignName, dtpStart.Date,
              dtpEnd.Date, DS) then
            begin
              // 若只有一条记录，则画不出箭头来，所以就跳过
              if DS.RecordCount <= 1 then Continue;

              i := 0;
              DS.First;
              while not DS.Eof do
              begin
                // 判断是否X，Y为空，若不为空，则可以添加数据
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
