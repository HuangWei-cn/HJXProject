{-----------------------------------------------------------------------------
 Unit Name: ufraDMTreePanel
 Author:    ��ΰ
 Date:      08-����-2016
 Purpose:   ��Ʋ�������
    ����Ԫ�ṩ����ʾ��Ƽ����б�����(Panel)����������ʾ���ɸ����û�����Ҫ
    ���в�ͬ�ķ��飬�簴���������͡����貿λ���ֲ�/��λ���̵ȡ�������ȡ�
    ����Ԫ����Ϊ���ʹ�á�
 History:
-----------------------------------------------------------------------------}

unit ufraDMTreePanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus;

type
  TfraDMTreePanel = class(TFrame)
    tvwDMList: TTreeView;
    pmFunc: TPopupMenu;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses
    uIAppServices;
{$R *.dfm}

end.
