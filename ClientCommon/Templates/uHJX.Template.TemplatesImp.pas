{ 本单元是对象TTemplates的子类和方法实现，父类是抽象方法，用于在插件体系中传递，类似接口。
    uHJX.Classes.Templates单元中的类要么没有方法，要么是抽象对象。
}
unit uHJX.Template.TemplatesImp;

interface

uses
    System.Classes, System.Generics.Collections, System.SysUtils,
    uHJX.IntfImp.AppServices, uHJX.Classes.Templates;

type
    /// <summary>TTemplates的子类和各方法的实现。</summary>
    /// <remarks>本类应被主工程所引用，以便于创建对象并赋给AppServices。
    /// </remarks>
    TTemplatesImp = class(TTemplates)
    private
        FCTList: TList<ThjxTemplate>;
        FWGList: TList<ThjxTemplate>;
        FXLList: TList<ThjxTemplate>;
    protected
        function GetCount: Integer; override;
        function GetChartTemplateCount: Integer; override;
        function GetWGTemplateCount: Integer; override;
        function GetXLTemplateCount: Integer; override;
        function GetItemByName(AName: string): ThjxTemplate; override;
        function GetCT(Index: Integer): ThjxTemplate; override;
        function GetWG(Index: Integer): ThjxTemplate; override;
        function GetXL(Index: Integer): ThjxTemplate; override;
    public
        constructor Create;
        destructor Destroy; override;

        procedure ClearAll; override;
        function AddChartTemplate(ChrtTmplClass: TTemplateClass): ThjxTemplate; override;
        function AddWGTemplate(WGTmplClass: TTemplateClass): ThjxTemplate; override;
        function AddXLTemplate(XLTmplClass: TTemplateClass): ThjxTemplate; override;

    end;

var
    HJXTemplates: TTemplatesImp;

implementation

constructor TTemplatesImp.Create;
begin
    inherited;
    FCTList := TList<ThjxTemplate>.Create;
    FWGList := TList<ThjxTemplate>.Create;
    FXLList := TList<ThjxTemplate>.Create;
end;

destructor TTemplatesImp.Destroy;
begin
    ClearAll;
    FCTList.Free;
    FWGList.Free;
    FXLList.Free;
    inherited;
end;

procedure TTemplatesImp.ClearAll;
var
    T: ThjxTemplate;
begin
    for T in FCTList do T.Free;
    for T in FWGList do T.Free;
    for T in FXLList do T.Free;

    FCTList.Clear;
    FWGList.Clear;
    FXLList.Clear;
end;

function TTemplatesImp.GetCount: Integer;
begin
    Result := FCTList.Count + FWGList.Count + FXLList.Count;
end;

function TTemplatesImp.GetChartTemplateCount: Integer;
begin
    Result := FCTList.Count;
end;

function TTemplatesImp.GetWGTemplateCount: Integer;
begin
    Result := FWGList.Count;
end;

function TTemplatesImp.GetXLTemplateCount: Integer;
begin
    Result := FXLList.Count;
end;

function TTemplatesImp.GetItemByName(AName: string): ThjxTemplate;
    function SameText(str1, str2: string): boolean;
    begin
        Result := UpperCase(str1) = UpperCase(str2);
    end;

begin
    for Result in FCTList do
        if SameText(Result.TemplateName, AName) then Exit;
    for Result in FWGList do
        if SameText(Result.TemplateName, AName) then Exit;
    for Result in FXLList do
        if SameText(Result.TemplateName, AName) then Exit;

    Result := nil;
end;

function TTemplatesImp.GetCT(Index: Integer): ThjxTemplate;
begin
    Result := FCTList.Items[index];
end;

function TTemplatesImp.GetWG(Index: Integer): ThjxTemplate;
begin
    Result := FWGList.Items[index];
end;

function TTemplatesImp.GetXL(Index: Integer): ThjxTemplate;
begin
    Result := FXLList.Items[index];
end;

function TTemplatesImp.AddChartTemplate(ChrtTmplClass: TTemplateClass): ThjxTemplate;
begin
    Result := ChrtTmplClass.Create;
    FCTList.Add(Result);
    Result.Category := tplChart;
end;

function TTemplatesImp.AddWGTemplate(WGTmplClass: TTemplateClass): ThjxTemplate;
begin
    Result := WGTmplClass.Create;
    FWGList.Add(Result);
    Result.Category := tplWebGrid;
end;

function TTemplatesImp.AddXLTemplate(XLTmplClass: TTemplateClass): ThjxTemplate;
begin
    Result := XLTmplClass.Create;
    Result.Category := tplXLGrid;
    FXLList.Add(Result);
end;

initialization

HJXTemplates := TTemplatesImp.Create;
HJXAppServices.SetTemplates(HJXTemplates);

finalization

HJXTemplates.Free;

end.
