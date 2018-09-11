{ -----------------------------------------------------------------------------
  Unit Name: uMyUtils.CopyHTML2Clipbrd
  Author:    黄伟
  Date:      12-四月-2017
  Purpose:   将已生成好的HTML代码拷贝到剪贴板
  本程序参考MSDN中的c++代码写成。之前曾通过WebBrowser实现过类似功能，这个更直接、
  也更专业一些。
  History:
  ----------------------------------------------------------------------------- }

unit uMyUtils.CopyHTML2Clipbrd;

interface

uses
    Winapi.Windows,System.Classes, system.SysUtils, Vcl.Clipbrd;

procedure CopyHTMLToClipboard(AHTMLStr: string); overload;
procedure CopyHTMLToClipboard(Stream: TStream); overload;

implementation

procedure CopyHTMLToClipboard(AHTMLStr: string);
var
    u8s, s : AnsiString;
    cf_html: integer;
    ts     : TStringStream;
    iLen   : integer;
    i1, i2 : integer;
    Data: THandle;
    DataPtr: Pointer;
    Buffer:Pointer;
begin
    ts := TStringStream.Create;
    try
        u8s := UTF8Encode(AHTMLStr);
        ilen := Length(u8s);
        i1 := Pos('<body>', u8s) +6;
        i2 := Pos('</body>',u8s);
        S := Format('Version:0.9'#13#10+
                    'StartHTML:%08u'#13#10 +
                    'EndHTML:%08u'#13#10 +
                    'StartFragment:%08u'#13#10 +
                    'EndFragment:%08u'#13#10 +
                    '%s'#13#10 , [97,97+ilen,97+i1,97+i2,u8s]);
        cf_html := RegisterClipboardFormat('HTML Format');
        ts.WriteString(s);
        Buffer := ts.Memory;
        clipboard.Open;
        try
            Data := GlobalAlloc(GMEM_MOVEABLE+gmem_ddeshare, ts.Size);
            try
                DataPtr := GlobalLock(Data) ;
                try
                    Move(buffer^, dataptr^,ts.Size);
                    Clipboard.SetAsHandle(cf_html, Data);
                finally
                    GlobalUnlock(Data);
                end;
            except
                GlobalFree(data);
            end;
        finally
            Clipboard.Close;
        end;
        
    finally
        ts.Free;
    end;
end;

procedure CopyHTMLToClipboard(Stream: TStream);
var
    Strs: TStrings;
begin
    Strs := TStringList.Create;
    try
        Stream.Position := 0;
        strs.LoadFromStream(stream);
        CopyHTMLToClipboard(strs.Text);
    finally
        Strs.Free;
    end;
end;

end.
