{-----------------------------------------------------------------------------
 Unit Name: uWBLoadHTML
 Author:    Administrator
 Date:      03-ʮһ��-2012
 Purpose:   ����Ԫ����TWebBrowser
 History:
-----------------------------------------------------------------------------}

unit uWBLoadHTML;

interface
uses
    Classes, Forms, ActiveX, ShDocVw;

{ ֱ�ӽ�HTMLCodeд��WebBrowser������Ҫ��ʱ�ļ����� }
procedure WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);

implementation
{-----------------------------------------------------------------------------
  Procedure:    WB_LoadHTML
  Description:  ������ֱ�ӽ�HTMLCODEд��WebBrowser.Document�У�ֱ����ʾ����
                ��Ҫͨ�������ļ����й��ɡ�	 
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

