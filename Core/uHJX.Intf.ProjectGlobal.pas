{-----------------------------------------------------------------------------
 Unit Name: uIProjectGlobal
 Author:    Administrator
 Date:      10-十二月-2012
 Purpose:
 History:
        2018-05-23
            本单元源自大岗山系统的uIProjectGlobal.pas。
            暂时注释掉用不到的内容，以便于先期运行调试
-----------------------------------------------------------------------------}

unit uHJX.Intf.ProjectGlobal;

interface
uses
    Classes{, uBaseTypes, uIMeters};

type
    IHJXProject = interface(IInterface)
        ['{7440E64C-1ABF-4C0F-85EE-67AA1A8BE347}']
        //function GetDesignPoints: IDesignPoints;
        //function GetMeters
        //function GetConherents: IConherentUnits;
        //function GetBidSections: IBidSections;
        //function GetIMeters: IMeters;
        //function GetMeters: TObject;
    end;

    IHJXProjectGlobalDatas = interface(IInterface)
        ['{74FB7E11-D6DB-4055-A841-454CA6A6FF85}']
        //function GetMntTypes: IMonitoringTypes;
        //function GetMntItems: IMonitoringItems;
        //function GetMeterType: IMeterTypes;
        //function GetMeterTemplates: IMeterTemplates;
        //function GetUnitRoles: IUnitRoles;
        //function GetWorkModes: IWorkModes;
        //function GetVendors: IVendors;
    end;

implementation

end.
