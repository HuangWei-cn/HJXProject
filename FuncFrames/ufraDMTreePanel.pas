{-----------------------------------------------------------------------------
 Unit Name: ufraDMTreePanel
 Author:    黄伟
 Date:      08-九月-2016
 Purpose:   设计测点树面板
    本单元提供了显示设计监测点列表的面板(Panel)，以树形显示，可根据用户的需要
    进行不同的分组，如按照仪器类型、埋设部位、分部/单位工程等、监测断面等。
    本单元是作为插件使用。
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
