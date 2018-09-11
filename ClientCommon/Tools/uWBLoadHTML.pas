{-----------------------------------------------------------------------------
 Unit Name: uWBLoadHTML
 Author:    Administrator
 Date:      03-十一月-2012
 Purpose:   本单元操作TWebBrowser
 History:
-----------------------------------------------------------------------------}

unit uWBLoadHTML;

interface
uses
    Classes, Forms, ActiveX, ShDocVw;

{ 直接将HTMLCode写入WebBrowser，不需要临时文件过渡 }
procedure WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);

implementation
{-----------------------------------------------------------------------------
  Procedure:    WB_LoadHTML
  Description:  本过程直接将HTMLCODE写入WebBrowser.Document中，直接显示，不
                需要通过磁盘文件进行过渡。	 
-----------------------------------------------------------------------------}
procedure WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);
var
    sl    : TStringList;
    ms    : TMemoryStream;
begin
    WebBrowser.Navigate('about:blank');
    while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
        Application.ProcessMessages;
    if Assigned(WebBrowser.Document) then
    begin
        sl := TStringList.Create;
        try
            ms := TMemoryStream.Create;
            try
                sl.Text := HTMLCode;
                sl.SaveToStream(ms);
                ms.Seek(0, 0);
                (WebBrowser.Document as
                    IPersistStreamInit).Load(TStreamAdapter.Create(ms));
            finally
                ms.Free;
            end;
        finally
            sl.Free;
        end;
    end;
end;

end.

