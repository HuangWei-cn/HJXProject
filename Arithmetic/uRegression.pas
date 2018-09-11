{-----------------------------------------------------------------------------
 Unit Name: uRegression
 Author:    Administrator
 Date:      30-十一月-2012
 Purpose:   回归计算单元
            源代码：源自http://blog.csdn.net/maozefa/article/details/1903204
            作者：阿发伯(maozefa@hotmail.com)

            注：未对原作进行任何修改。
 History:
-----------------------------------------------------------------------------}

unit uRegression;

interface

uses SysUtils;

type
    PEquationsData = ^TEquationsData;
    TEquationsData = array[0..0] of Double;
    // 线性回归
    TLinearRegression = class(TObject)
    private
        FData: PEquationsData;
        FAnswer: PEquationsData;
        FSquareSum: Double;
        FSurplusSum: Double;
        FRowCount: Integer;
        FColCount: Integer;
        FModify: Boolean;
        function GetAnswer(Index: Integer): Double;
        function GetItem(ARow, ACol: Integer): Double;
        procedure SetItem(ARow, ACol: Integer; const Value: Double);
        procedure SetColCount(const Value: Integer);
        procedure SetRowCount(const Value: Integer);
        procedure SetSize(const ARowCount, AColCount: Integer);
        procedure SetModify(const Value: Boolean);
        function GetCorrelation: Double;
        function GetDeviatSum: Double;
        function GetFTest: Double;
        function GetSurplus: Double;
        function GetVariance: Double;
        function GetStandardDiffer: Double;
        function GetEstimate(ARow: Integer): Double;
    public
        constructor Create(const AData; const ARowCount, AColCount: Integer);
            overload;
        destructor Destroy; override;
        // 计算回归方程
        procedure Calculation;
        // 设置回归数据
        // AData[ARowCount*AColCount]二维数组；X1i,X2i,...Xni,Yi (i=0 to ARowCount-1)
        // ARowCount：数据行数；AColCount数据列数
        procedure SetData(const AData; const ARowCount, AColCount: Integer);
        // 数据列数(自变量个数 + Y)
        property ColCount: Integer read FColCount write SetColCount;
        // 数据行数
        property RowCount: Integer read FRowCount write SetRowCount;
        // 原始数据
        property Data[ARow, ACol: Integer]: Double read GetItem write SetItem;
            default;
        property Modify: Boolean read FModify;
        // 回归系数数组(B0,B1...Bn)
        property Answer[Index: Integer]: Double read GetAnswer;
        // Y估计值
        property Estimate[ARow: Integer]: Double read GetEstimate;
        // 回归平方和
        property RegresSquareSum: Double read FSquareSum;
        // 剩余平方和
        property SurplusSquareSum: Double read FSurplusSum;
        // 离差平方和
        property DeviatSquareSum: Double read GetDeviatSum;
        // 回归方差
        property RegresVariance: Double read GetVariance;
        // 剩余方差
        property SurplusVariance: Double read GetSurplus;
        // 标准误差
        property StandardDiffer: Double read GetStandardDiffer;
        // 相关系数
        property Correlation: Double read GetCorrelation;
        // F 检验
        property F_Test: Double read GetFTest;
    end;

    // 解线性方程。AData[count*(count+1)]矩阵数组；count：方程元数；
    // Answer[count]：求解数组 。返回：True求解成功，否则无解或者无穷解
function LinearEquations(const AData; Count: Integer; var Answer: array of
    Double): Boolean;

implementation

const
    SMatrixSizeError = 'Regression data matrix can not be less than 2 * 2';
    SIndexOutOfRange = 'index out of range';
    SEquationNoSolution = 'Equation no solution or Infinite Solutions';

function LinearEquations(const AData; Count: Integer; var Answer: array of
    Double): Boolean;
var
    j, m, n, ColCount: Integer;
    tmp   : Double;
    Data, d: PEquationsData;
begin
    Result := False;
    if Count < 2 then Exit;

    ColCount := Count + 1;
    GetMem(Data, Count * ColCount * Sizeof(Double));
    GetMem(d, ColCount * Sizeof(Double));
    try
        Move(AData, Data^, Count * ColCount * Sizeof(Double));
        for m := 0 to Count - 2 do
        begin
            n := m + 1;
            // 如果主对角线元素为0，行交换
            while (n < Count) and (Data^[m * ColCount + m] = 0.0) do
            begin
                if Data^[n * ColCount + m] <> 0.0 then
                begin
                    Move(Data^[m * ColCount + m], d^, ColCount * Sizeof(Double));
                    Move(Data^[n * ColCount + m], Data^[m * ColCount + m], ColCount
                        * Sizeof(Double));
                    Move(d^, Data^[n * ColCount + m], ColCount * Sizeof(Double));
                end;
                Inc(n);
            end;
            // 行交换后，主对角线元素仍然为0，无解
            if Data^[m * ColCount + m] = 0.0 then Exit;
            // 消元
            for n := m + 1 to Count - 1 do
            begin
                tmp := Data^[n * ColCount + m] / Data^[m * ColCount + m];
                for j := m to Count do
                    Data^[n * ColCount + j] := Data^[n * ColCount + j] - tmp *
                        Data^[m * ColCount + j];
            end;
        end;
        FillChar(d^, Count * Sizeof(Double), 0);
        // 求得count - 1的元
        Answer[Count - 1] := Data^[(Count - 1) * ColCount + Count] /
            Data^[(Count - 1) * ColCount + Count - 1];
        // 逐行代入求各元
        for m := Count - 2 downto 0 do
        begin
            for j := Count - 1 downto m + 1 do
                d^[m] := d^[m] + Answer[j] * Data^[m * ColCount + j];
            Answer[m] := (Data^[m * ColCount + Count] - d^[m]) / Data^[m * ColCount
                + m];
        end;
        Result := True;
    finally
        FreeMem(d);
        FreeMem(Data);
    end;
end;

{ TLinearRegression }

procedure TLinearRegression.Calculation;
var
    m, n, i, Count: Integer;
    dat   : PEquationsData;
    a, b, d: Double;
begin
    if (FRowCount < 2) or (FColCount < 2) then
        raise Exception.Create(SMatrixSizeError);
    if not FModify then Exit;
    GetMem(dat, FColCount * (FColCount + 1) * Sizeof(Double));
    try
        Count := FColCount - 1;
        dat^[0] := FRowCount;
        for n := 0 to Count - 1 do
        begin
            a := 0.0;
            b := 0.0;
            for m := 0 to FRowCount - 1 do
            begin
                d := FData^[m * FColCount + n];
                a := a + d;
                b := b + d * d;
            end;
            dat^[n + 1] := a;
            dat^[(n + 1) * (FColCount + 1)] := a;
            dat^[(n + 1) * (FColCount + 1) + n + 1] := b;
            for i := n + 1 to Count - 1 do
            begin
                a := 0.0;
                for m := 0 to FRowCount - 1 do
                    a := a + FData^[m * FColCount + n] * FData^[m * FColCount +
                        i];
                dat^[(n + 1) * (FColCount + 1) + i + 1] := a;
                dat^[(i + 1) * (FColCount + 1) + n + 1] := a;
            end;
        end;
        b := 0.0;
        for m := 0 to FRowCount - 1 do
            b := b + FData^[m * FColCount + Count];
        dat^[FColCount] := b;
        for n := 0 to Count - 1 do
        begin
            a := 0.0;
            for m := 0 to FRowCount - 1 do
                a := a + FData^[m * FColCount + n] * FData^[m * FColCount +
                    Count];
            dat^[(n + 1) * (FColCount + 1) + FColCount] := a;
        end;
        if not LinearEquations(dat^, FColCount, FAnswer^) then
            raise Exception.Create(SEquationNoSolution);
        FSquareSum := 0.0;
        FSurplusSum := 0.0;
        b := b / FRowCount;
        for m := 0 to FRowCount - 1 do
        begin
            a := FAnswer^[0];
            for i := 1 to Count do
                a := a + FData^[m * FColCount + i - 1] * FAnswer[i];
            FSquareSum := FSquareSum + (a - b) * (a - b);
            d := FData^[m * FColCount + Count];
            FSurplusSum := FSurplusSum + (d - a) * (d - a);
        end;
        SetModify(False);
    finally
        FreeMem(dat);
    end;
end;

constructor TLinearRegression.Create(const AData; const ARowCount,
    AColCount: Integer);
begin
    SetData(AData, ARowCount, AColCount);
end;

destructor TLinearRegression.Destroy;
begin
    SetSize(0, 0);
end;

function TLinearRegression.GetAnswer(Index: Integer): Double;
begin
    if (Index < 0) or (Index >= FColCount) then
        raise Exception.Create(SIndexOutOfRange);
    if not Assigned(FAnswer) then
        Result := 0.0
    else
        Result := FAnswer^[Index];
end;

function TLinearRegression.GetCorrelation: Double;
begin
    Result := DeviatSquareSum;
    if Result <> 0.0 then
        Result := Sqrt(FSquareSum / Result);
end;

function TLinearRegression.GetDeviatSum: Double;
begin
    Result := FSquareSum + FSurplusSum;
end;

function TLinearRegression.GetEstimate(ARow: Integer): Double;
var
    i     : Integer;
begin
    if (ARow < 0) or (ARow >= FRowCount) then
        raise Exception.Create(SIndexOutOfRange);
    Result := Answer[0];
    for i := 1 to ColCount - 1 do
        Result := Result + FData^[ARow * FColCount + i - 1] * Answer[i];
end;

function TLinearRegression.GetFTest: Double;
begin
    Result := SurplusVariance;
    if Result <> 0.0 then
        Result := RegresVariance / Result;
end;

function TLinearRegression.GetItem(ARow, ACol: Integer): Double;
begin
    if (ARow < 0) or (ARow >= FRowCount) or (ACol < 0) or (ACol >= FColCount) then
        raise Exception.Create(SIndexOutOfRange);
    Result := FData^[ARow * FColCount + ACol];
end;

function TLinearRegression.GetStandardDiffer: Double;
begin
    Result := Sqrt(SurplusVariance);
end;

function TLinearRegression.GetSurplus: Double;
begin
    if FRowCount - FColCount < 1 then
        Result := 0.0
    else
        Result := FSurplusSum / (FRowCount - FColCount);
end;

function TLinearRegression.GetVariance: Double;
begin
    if FColCount < 2 then
        Result := 0.0
    else
        Result := FSquareSum / (FColCount - 1);
end;

procedure TLinearRegression.SetColCount(const Value: Integer);
begin
    if Value < 2 then
        raise Exception.Create(SMatrixSizeError);
    SetSize(FRowCount, Value);
end;

procedure TLinearRegression.SetData(const AData; const ARowCount, AColCount:
    Integer);
begin
    if (ARowCount < 2) or (AColCount < 2) then
        raise Exception.Create(SMatrixSizeError);
    SetSize(ARowCount, AColCount);
    Move(AData, FData^, FRowCount * FColCount * Sizeof(Double));
end;

procedure TLinearRegression.SetItem(ARow, ACol: Integer; const Value: Double);
begin
    if (ARow < 0) or (ARow >= FRowCount) or (ACol < 0) or (ACol >= FColCount) then
        raise Exception.Create(SIndexOutOfRange);
    if FData^[ARow * (FColCount) + ACol] <> Value then
    begin
        FData^[ARow * (FColCount) + ACol] := Value;
        SetModify(True);
    end;
end;

procedure TLinearRegression.SetModify(const Value: Boolean);
begin
    if FModify <> Value then
    begin
        FModify := Value;
        if FModify then
        begin
            FillChar(FAnswer^, FColCount * Sizeof(Double), 0);
            FSquareSum := 0.0;
            FSurplusSum := 0.0;
        end;
    end;
end;

procedure TLinearRegression.SetRowCount(const Value: Integer);
begin
    if Value < 2 then
        raise Exception.Create(SMatrixSizeError);
    SetSize(Value, FColCount);
end;

procedure TLinearRegression.SetSize(const ARowCount, AColCount: Integer);
begin
    if (FRowCount = ARowCount) and (FColCount = AColCount) then
        Exit;
    if Assigned(FData) then
    begin
        FreeMem(FData);
        FData := nil;
        FreeMem(FAnswer);
        FAnswer := nil;
        FModify := False;
    end;

    FRowCount := ARowCount;
    FColCount := AColCount;

    if (FRowCount = 0) or (FColCount = 0) then Exit;

    GetMem(FData, FRowCount * FColCount * Sizeof(Double));
    FillChar(FData^, FRowCount * FColCount * Sizeof(Double), 0);
    GetMem(FAnswer, FColCount * Sizeof(Double));
    SetModify(True);
end;

end.


{ 下面是调用代码的示例 }
//program LinearRegression;
//
//{$APPTYPE CONSOLE}
//
//uses
//  SysUtils,
//  Regression in '....pasRegression.pas';
//
//const
//  data1: array[1..12, 1..2] of Double = (
////    X      Y
//    ( 187.1, 25.4 ),
//    ( 179.5, 22.8 ),
//    ( 157.0, 20.6 ),
//    ( 197.0, 21.8 ),
//    ( 239.4, 32.4 ),
//    ( 217.8, 24.4 ),
//    ( 227.1, 29.3 ),
//    ( 233.4, 27.9 ),
//    ( 242.0, 27.8 ),
//    ( 251.9, 34.2 ),
//    ( 230.0, 29.2 ),
//    ( 271.8, 30.0 )
//);
//
//  data: array[1..15, 1..5] of Double = (
////   X1   X2    X3   X4    Y
//  ( 316, 1536, 874, 981, 3894 ),
//  ( 385, 1771, 777, 1386, 4628 ),
//  ( 299, 1565, 678, 1672, 4569 ),
//  ( 326, 1970, 785, 1864, 5340 ),
//  ( 441, 1890, 785, 2143, 5449 ),
//  ( 460, 2050, 709, 2176, 5599 ),
//  ( 470, 1873, 673, 1769, 5010 ),
//  ( 504, 1955, 793, 2207, 5694 ),
//  ( 348, 2016, 968, 2251, 5792 ),
//  ( 400, 2199, 944, 2390, 6126 ),
//  ( 496, 1328, 749, 2287, 5025 ),
//  ( 497, 1920, 952, 2388, 5924 ),
//  ( 533, 1400, 1452, 2093, 5657 ),
//  ( 506, 1612, 1587, 2083, 6019 ),
//  ( 458, 1613, 1485, 2390, 6141 )
//);
//
//procedure Display(s: string; R: TLinearRegression);
//var
//  i: Integer;
//  v, o: Double;
//begin
//    Writeln(s);
//    Writeln('回归方程式: ');
//    Write('   Y = ', R.Answer[0]:1:5);
//    for i := 1 to R.ColCount - 1 do
//        Write(' + ', R.Answer[i]:1:5, '*X', i);
//    Writeln;
//    Writeln('回归显著性检验: ');
//    Writeln('回归平方和：', R.RegresSquareSum:12:4, '  回归方差：', R.RegresVariance:12:4);
//    Writeln('剩余平方和：', R.SurplusSquareSum:12:4, '  剩余方差：', R.SurplusVariance:12:4);
//    Writeln('离差平方和：', R.DeviatSquareSum:12:4, '  标准误差：', R.StandardDiffer:12:4);
//    Writeln('F   检  验：', R.F_Test:12:4, '  相关系数：', R.Correlation:12:4);
//    Writeln('剩余分析: ');
//    Writeln('      观察值      估计值      剩余值    剩余平方 ');
//    for i := 0 to R.RowCount - 1 do
//    begin
//      o := R[i, R.ColCount - 1];
//      v := o - R.Estimate[i];
//      Writeln(o:12:2, R.Estimate[i]:12:2, v:12:2, v * v:12:2);
//    end;
//    Readln;
//end;
//
//var
//  R: TLinearRegression;
//begin
//  try
//    { TODO -oUser -cConsole Main : Insert code here }
//    R := TLinearRegression.Create(data1, 12, 2);
//    try
//      R.Calculation;
//      Display('一元线性回归演示', R);
//      R.SetData(data, 15, 5);
//      R.Calculation;
//      Display('多元线性回归演示', R);
//    finally
//      R.Free;
//    end;
//  except
//    on E:Exception do
//      Writeln(E.Classname, ': ', E.Message);
//  end;
//end.}program LinearRegression;
//
//{$APPTYPE CONSOLE}
//
//uses
//  SysUtils,
//  Regression in '....pasRegression.pas';
//
//const
//  data1: array[1..12, 1..2] of Double = (
////    X      Y
//    ( 187.1, 25.4 ),
//    ( 179.5, 22.8 ),
//    ( 157.0, 20.6 ),
//    ( 197.0, 21.8 ),
//    ( 239.4, 32.4 ),
//    ( 217.8, 24.4 ),
//    ( 227.1, 29.3 ),
//    ( 233.4, 27.9 ),
//    ( 242.0, 27.8 ),
//    ( 251.9, 34.2 ),
//    ( 230.0, 29.2 ),
//    ( 271.8, 30.0 )
//);
//
//  data: array[1..15, 1..5] of Double = (
////   X1   X2    X3   X4    Y
//  ( 316, 1536, 874, 981, 3894 ),
//  ( 385, 1771, 777, 1386, 4628 ),
//  ( 299, 1565, 678, 1672, 4569 ),
//  ( 326, 1970, 785, 1864, 5340 ),
//  ( 441, 1890, 785, 2143, 5449 ),
//  ( 460, 2050, 709, 2176, 5599 ),
//  ( 470, 1873, 673, 1769, 5010 ),
//  ( 504, 1955, 793, 2207, 5694 ),
//  ( 348, 2016, 968, 2251, 5792 ),
//  ( 400, 2199, 944, 2390, 6126 ),
//  ( 496, 1328, 749, 2287, 5025 ),
//  ( 497, 1920, 952, 2388, 5924 ),
//  ( 533, 1400, 1452, 2093, 5657 ),
//  ( 506, 1612, 1587, 2083, 6019 ),
//  ( 458, 1613, 1485, 2390, 6141 )
//);
//
//procedure Display(s: string; R: TLinearRegression);
//var
//  i: Integer;
//  v, o: Double;
//begin
//    Writeln(s);
//    Writeln('回归方程式: ');
//    Write('   Y = ', R.Answer[0]:1:5);
//    for i := 1 to R.ColCount - 1 do
//        Write(' + ', R.Answer[i]:1:5, '*X', i);
//    Writeln;
//    Writeln('回归显著性检验: ');
//    Writeln('回归平方和：', R.RegresSquareSum:12:4, '  回归方差：', R.RegresVariance:12:4);
//    Writeln('剩余平方和：', R.SurplusSquareSum:12:4, '  剩余方差：', R.SurplusVariance:12:4);
//    Writeln('离差平方和：', R.DeviatSquareSum:12:4, '  标准误差：', R.StandardDiffer:12:4);
//    Writeln('F   检  验：', R.F_Test:12:4, '  相关系数：', R.Correlation:12:4);
//    Writeln('剩余分析: ');
//    Writeln('      观察值      估计值      剩余值    剩余平方 ');
//    for i := 0 to R.RowCount - 1 do
//    begin
//      o := R[i, R.ColCount - 1];
//      v := o - R.Estimate[i];
//      Writeln(o:12:2, R.Estimate[i]:12:2, v:12:2, v * v:12:2);
//    end;
//    Readln;
//end;
//
//var
//  R: TLinearRegression;
//begin
//  try
//    { TODO -oUser -cConsole Main : Insert code here }
//    R := TLinearRegression.Create(data1, 12, 2);
//    try
//      R.Calculation;
//      Display('一元线性回归演示', R);
//      R.SetData(data, 15, 5);
//      R.Calculation;
//      Display('多元线性回归演示', R);
//    finally
//      R.Free;
//    end;
//  except
//    on E:Exception do
//      Writeln(E.Classname, ': ', E.Message);
//  end;
//end.
