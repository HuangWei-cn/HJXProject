unit uHJX.ExcelDataAccess;

interface

uses
    uHJX.Excel.DataQuery,  // IClientFunction�ӿڵ�ʵ��
    uHJX.Excel.InitParams, // ���ز��������ֳ�ʼ��
    uHJX.Excel.IO,         // Excel���ʹ���
    uHJX.Excel.Meters;     // ��TMeterDefine��TMeters�ľ���

procedure OpenConfig(Afile: string);

implementation

procedure OpenConfig(Afile: string);
begin
    // call LoadProjectConfig@uHJX.Excel.InitParams.pas
    LoadProjectConfig(Afile);
end;

end.
