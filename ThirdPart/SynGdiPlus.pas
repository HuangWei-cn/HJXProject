/// GDI+ library API access
// - adds GIF, TIF, PNG and JPG pictures read/write support as standard TGraphic
// - make available most useful GDI+ drawing methods
// - allows Antialiased rending of any EMF file using GDI+
// - this unit is a part of the freeware Synopse framework,
// licensed under a MPL/GPL/LGPL tri-license; version 1.15
unit SynGdiPlus;

{
    This file is part of Synopse framework.

    Synopse framework. Copyright (C) 2011 Arnaud Bouchez
      Synopse Informatique - http://synopse.info

  *** BEGIN LICENSE BLOCK *****
  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the License.

  The Original Code is Synopse framework.

  The Initial Developer of the Original Code is Arnaud Bouchez.

  Portions created by the Initial Developer are Copyright (C) 2011
  the Initial Developer. All Rights Reserved.

  Contributor(s):
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

  ***** END LICENSE BLOCK *****

  Version 1.6a
   - first public release on http://synopse.info blog

  Version 1.6b
   - new TGDIPlusFull with most usefull GDI+ primitives (ancestor TGDIPLus only
     handles pictures)
   - TGDIPlusFull loads dynamicaly the latest GDI+ version available on the system,
     i.e. the 1.1 version bundled with Office 2003/2007 (all the other pascal
     GDI+ units use static linking, therefore only link to the OS version, even
     if a newer one if available within the Office folder)
   - draw an EMF created from GDI commands into a GDI+ Antialiased canvas
     (this unit can work without the GDI+ library, e.g. under Windows 98 or 2000,
      but won't use new pictures format nor antialiasing)

   Version 1.8
   - small modifications to better handling Jpeg saving

   Version 1.9
   - small enhancements for framework Main Demo release (RectNotBiggerThan and
     MaxPixelsForBiggestSide parameter in SaveAs function e.g.)

   Version 1.10
   - code modifications to compile with Delphi 6 compiler

   Version 1.12
   - added code for error handling, via new TGdipStatus enumeration type
   - now GDI+ handles are stored using THandle instead of plain integer type
     (in order to prepare a 64 bit version of the unit)
   - fixed a problem in rendering bitmaps, e.g. as created in SQLite3Pages
   - fixed a problem in rendering underlined text (GDI+ DrawDriverString doesn't
     handle underlined or stroken out fonts as expected)

   Version 1.13
   - code modifications to compile with Delphi 5 compiler
   - handle TCanvas.DrawCurve() method in TMetaFile enumeration
   - suppress GDI+ library back thread which may hang up application when using
     this unit in a DLL - manual hook and unhook is done at statup/shutdown
     see http://mikevdm.com/BlogEntry/Key/GdiplusShutdown-Hangs-Mysteriously

   Version 1.15
   - unit now tested with Delphi XE2 (32 Bit)
   - handle TIFF saving with diverse compression methods

}

{$I Synopse.inc} // define HASINLINE USETYPEINFO CPU32 CPU64 OWNNORMTOUPPER

interface

uses
    Windows, Classes, SysUtils,
{$IFDEF ISDELPHIXE2}
    VCL.Graphics,
{$ELSE}
    Graphics,
{$ENDIF}
    ActiveX;

{.$define USEENCODERS}
{ if defined, the GDI+ encoder list will be used - seems not necessary }

{.$define USEDPI}
{ if defined, the DrawAt() method is available, which respect dpi on drawing
  - should not be usefull on most applications }

{$DEFINE NOTSYNPICTUREREGISTER}
{ if NOT defined, the TSynPicture type is registered to handle PNG JPG TIF in TGraphic }

{$MINENUMSIZE 4}

type
{$IFDEF DELPHI5OROLDER}
    // Delphi 5 doesn't have those base types defined :(
    PPointer = ^Pointer;
    PPChar = ^PChar;
    IntegerArray = array[0..$EFFFFFF] of Integer;
    PIntegerArray = ^IntegerArray;
{$ENDIF}

    /// GDI+ line drawing smoothing types
    TSmoothingMode = (
        smDefault, smHighSpeed, smHighQuality, smNone, smAntiAlias);

    /// GDI+ text rendering smoothing types
    TTextRenderingHint = (
        trhDefault, trhSingleBitPerPixelGridFit, trhSingleBitPerPixel,
        trhAntiAliasGridFit, trhAntiAlias, trhClearTypeGridFit);

    /// GDI+ available coordinates units
    TUnit = (
        uWorld, uDisplay, uPixel, uPoint, uInch, uDocument, uMillimeter, uGdi);

    /// GDI+ types of conversion from EMF to EMF+
    TEmfType = (
        etEmf0, etEmf1, etEmf2, { for Delphi 5: no etEmfOnly=3 syntax }
        etEmfOnly, etEmfPlusOnly, etEmfPlusDual);

    /// GDI+ available filling modes
    TFillMode = (
        fmAlternate, fmWinding);

    /// GDI+ lock mode for GdipFull.BitmapLockBits
    TLockModeOption = (
        lmRead, lmWrite, lmUserInputBuf);

    /// GDI+ error codes
    TGdipStatus = (
        stOk,
        stGenericError,
        stInvalidParameter,
        stOutOfMemory,
        stObjectBusy,
        stInsufficientBuffer,
        stNotImplemented,
        stWin32Error,
        stWrongState,
        stAborted,
        stFileNotFound,
        stValueOverflow,
        stAccessDenied,
        stUnknownImageFormat,
        stFontFamilyNotFound,
        stFontStyleNotFound,
        stNotTrueTypeFont,
        stUnsupportedGdiplusVersion,
        stGdiplusNotInitialized,
        stPropertyNotFound,
        stPropertyNotSupported);

    PGdipRect = ^TGdipRect;

    /// GDI+ integer coordinates rectangles
    // - use width and height instead of right and bottom
    TGdipRect = packed record
        X, Y, Width, Height: Integer;
    end;
    PGdipRectF = ^TGdipRectF;

    /// GDI+ floating point coordinates rectangles
    // - use width and height instead of right and bottom
    TGdipRectF = packed record
        X, Y, Width, Height: Single;
    end;
    PGdipPointF = ^TGdipPointF;

    /// GDI+ floating point coordinates for a point
    TGdipPointF = packed record
        X, Y: Single;
    end;
    PGdipPointFArray = ^TGdipPointFArray;

    /// GDI+ floating point coordinates for an array of points
    TGdipPointFArray = array[0..1000] of TGdipPointF;

    /// data as retrieved by GdipFull.BitmapLockBits
    TGdipBitmapData = packed record
        Width: Cardinal;
        Height: Cardinal;
        Stride: Integer;
        PixelFormat: Integer;
        Scan0: Pointer;
        Reserved: Cardinal;
    end;
    PGdipBitmapData = ^TGdipBitmapData;

type
    /// an object wrapper to load dynamically a library
    TSynLibrary = class
    protected
        fHandle: HMODULE;
        /// helper to load all needed procedure entries from a dynamic library
        // - return the HMODULE on success, i.e. if all procedure Names were found
        // - procedure definitions must be defined in inherited, and pointer-aligned,
        // i.e. the object must be bounded by {$A-} {$A+} compiler directives
        class function Load(const aDllFileName: TFileName; Addr: PPointer;
            Names: PPChar): HMODULE;
        /// unload the library
        procedure UnLoad;
    public
        /// return TRUE if the library and all procedures were found
        function Exists: boolean;
    end;

    TGDIPlusHookProc = function(out token: THandle): Integer; stdcall;
    TGDIPlusUnhookProc = procedure(token: THandle); stdcall;

{$A-} { all stdcall pointers in protected section below must be pointer-aligned }
    /// handle picture related GDI+ library calls
    TGDIPlus = class(TSynLibrary)
    protected
        Startup: function(var token: THandle; var Input, Output): TGdipStatus; stdcall;
        Shutdown: procedure(token: THandle); stdcall;
        DeleteGraphics: function(Graphics: THandle): TGdipStatus; stdcall;
        CreateFromHDC: function(hdc: hdc; out Graphics: THandle): TGdipStatus; stdcall;
        LoadImageFromStream: function(stream: IStream; out image: THandle): TGdipStatus; stdcall;
        LoadImageFromFile: function(filename: PWideChar; out image: THandle): TGdipStatus; stdcall;
        DrawImageRect: function(Graphics, image: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        DrawImageRectRect: function(Graphics, image: THandle; xd, yd, wd, hd, xs, ys, ws, hs:
            Integer;
            u: TUnit = uPixel; imageAttributes: Integer = 0; callback: Pointer = nil;
            calldata: Pointer = nil): TGdipStatus; stdcall;
{$IFDEF USEDPI}
        DrawImage: function(Graphics, image: THandle; X, Y: Integer): TGdipStatus; stdcall;
{$ENDIF}
        DisposeImage: function(image: THandle): TGdipStatus; stdcall;
        GetImageRawFormat: function(image: THandle; var format: TGUID): TGdipStatus; stdcall;
        GetImageWidth: function(image: THandle; var Width: Cardinal): TGdipStatus; stdcall;
        GetImageHeight: function(image: THandle; var Height: Cardinal): TGdipStatus; stdcall;
        SaveImageToStream: function(image: THandle; stream: IStream;
            clsidEncoder: PGUID; encoderParams: Pointer): TGdipStatus; stdcall;
{$IFDEF USEENCODERS}
        GetImageEncodersSize: function(out numEncoders: Cardinal;
            out size: Cardinal): TGdipStatus; stdcall;
        GetImageEncoders: function(numEncoders, size: Cardinal;
            encoders: Pointer): TGdipStatus; stdcall;
{$ENDIF}
        CreateBitmapFromHBITMAP: function(hbm: HBITMAP; hpal: HPALETTE;
            out bitmap: THandle): TGdipStatus; stdcall;
        CreateBitmapFromGdiDib: function(bmi, bits: Pointer; out bitmap: THandle): TGdipStatus;
            stdcall;
    protected
        fToken: THandle;
        fStartupHook: packed record
            Hook: TGDIPlusHookProc;
            Unhook: TGDIPlusUnhookProc;
        end;
        fStartupHookToken: THandle;
    public
        /// load the GDI+ library and all needed procedures
        // - returns TRUE on success
        // - library is loaded dynamically, therefore the executable is able
        // to launch before Windows XP, but GDI + functions (e.g. GIF, PNG, TIFF
        // and JPG pictures support) won't be available in such case
        constructor Create(const aDllFileName: TFileName); reintroduce;
        // Registers the .jpg .jpeg .gif .png .tif .tiff file extensions to the program
        // - TPicture can now load such files
        // - you can just launch Gdip.RegisterPictures to initialize the GDI+ library
        procedure RegisterPictures;
        /// draw the corresponding EMF metafile into a given device context
        // - this default implementation uses GDI drawing only
        // - use TGDIPlusFull overriden method for true GDI+ AntiAliaised drawing
        procedure DrawAntiAliased(Source: TMetafile; Dest: hdc; R: TRect;
            aSmoothing: TSmoothingMode = smAntiAlias;
            aTextRendering: TTextRenderingHint = trhClearTypeGridFit); overload; virtual;
        /// draw the corresponding EMF metafile into a bitmap created by the method
        // - this default TGDIPlus implementation uses GDI drawing only
        // - use a TGDIPlusFull instance for true GDI+ AntiAliaised drawing
        // - you can specify a zoom factor by the ScaleX and ScaleY parameters in
        // percent: e.g. 100 means 100%, i.e. no scaling
        function DrawAntiAliased(Source: TMetafile; ScaleX: Integer = 100; ScaleY: Integer = 100;
            aSmoothing: TSmoothingMode = smAntiAlias;
            aTextRendering: TTextRenderingHint = trhClearTypeGridFit): TBitmap; overload;
        /// unload the GDI+ library
        destructor Destroy; override;
    end;
{$A+}

    /// allowed types for image saving
    TGDIPPictureType = (gptGIF, gptPNG, gptJPG, gptBMP, gptTIF);

    /// the optional TIFF compression levels
    // - use e.g. ord(evCompressionCCITT4) to save a TIFF picture as CCITT4
    TGDIPPEncoderValue = (
        evColorTypeCMYK,
        evColorTypeYCCK,
        evCompressionLZW,
        evCompressionCCITT3,
        evCompressionCCITT4,
        evCompressionRle,
        evCompressionNone,
        evScanMethodInterlaced,
        evScanMethodNonInterlaced,
        evVersionGif87,
        evVersionGif89,
        evRenderProgressive,
        evRenderNonProgressive,
        evTransformRotate90,
        evTransformRotate180,
        evTransformRotate270,
        evTransformFlipHorizontal,
        evTransformFlipVertical,
        evMultiFrame,
        evLastFrame,
        evFlush,
        evFrameDimensionTime,
        evFrameDimensionResolution,
        evFrameDimensionPage);

    /// GIF, PNG, TIFF and JPG pictures support using GDI+ library
    // - cf @http://msdn.microsoft.com/en-us/library/ms536393(VS.85).aspx
    // for all available image formats
    TSynPicture = class(TGraphic)
    protected
        fHasContent: boolean;
        fHeight,
            fWidth: Cardinal;
        fImage: THandle;
        fStream: IStream;
        fGlobal: THandle;
        fGlobalLen: Integer;
        fAssignedFromBitmap: boolean;
        function GetEmpty: boolean; override;
        function GetHeight: Integer; override;
        function GetWidth: Integer; override;
        procedure SetHeight(Value: Integer); override;
        procedure SetWidth(Value: Integer); override;
        procedure fImageSet;
    public
        constructor Create; override;
        destructor Destroy; override;
        procedure Clear; //我把这个方法移到public组中了，原为protected组
        procedure Assign(Source: TPersistent); override;
        //这个方法只能会出1:1大小的图像，而不能缩放
        procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
{$IFDEF USEDPI}
        /// since method use dpi -> can drop content if drawing with different dpi
        procedure DrawAt(ACanvas: TCanvas; X, Y: Integer);
{$ENDIF}
        function LoadFromIStream(stream: IStream): TGdipStatus;
        procedure LoadFromStream(stream: TStream); override;
        procedure LoadFromFile(const filename: string); override;
        procedure SaveToStream(stream: TStream); override;
        procedure SaveInternalToStream(stream: TStream);
        procedure LoadFromResourceName(Instance: THandle; const ResName: string);
        procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
            APalette: HPALETTE); override;
        procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
            var APalette: HPALETTE); override;
        /// save the picture into any GIF/PNG/JPG/TIFF format
        // - CompressionQuality is used for gptJPG format saving
        // and is expected to be from 0 to 100; for gptTIF format, use
        // ord(TGDIPPEncoderValue) to define the parameter; by default, will use
        // ord(evCompressionLZW) to save the TIFF picture with LZW - for gptTIF,
        // only valid values are ord(evCompressionLZW), ord(evCompressionCCITT3),
        // ord(evCompressionCCITT4), ord(evCompressionRle) and ord(evCompressionNone)
        function SaveAs(stream: TStream; format: TGDIPPictureType;
            CompressionQuality: Integer = 80): TGdipStatus;
        /// create a bitmap from the corresponding picture
        function ToBitmap: TBitmap;
        /// guess the picture type from its internal format
        // - return gptBMP if no format is found
        function GetImageFormat: TGDIPPictureType;
        /// return TRUE if the supplied filename is a picture handled by
        // TSynPicture
        class function IsPicture(const filename: TFileName): TGraphicClass;
        /// calculate a TRect which fit the specified maximum pixel number
        // - if any side of the picture is bigger than the specified pixel number,
        // the TRect is sized down in order than the biggest size if this value
        function RectNotBiggerThan(MaxPixelsForBiggestSide: Integer): TRect;
        /// return the GDI+ native image handle
        property NativeImage: THandle read fImage;
    end;

    /// sub class to handle .PNG file extension
    TPngImage = class(TSynPicture)
    end;

    /// sub class to handle .JPG file extension
    TJpegImage = class(TSynPicture)
    protected
        fCompressionQuality: Integer;
    public
        constructor Create; override;
        /// implements the saving feature
        procedure SaveToStream(stream: TStream); override;
        /// the associated encoding quality (from 0 to 100)
        // - set to 80 by default
        property CompressionQuality: Integer read fCompressionQuality write fCompressionQuality;
    end;

    /// sub class to handle .GIF file extension
    TGifImage = class(TSynPicture)
    end;

    /// sub class to handle .TIF file extension
    // - GDI + seems not able to load all Tiff file formats
    TTiffImage = class(TSynPicture)
    end;

{$A-}
    /// handle most GDI+ library calls
    // - an instance of this object is initialized by this unit: you don't have
    // to create a new instance
    TGDIPlusFull = class(TGDIPlus)
    protected
        DrawLine: function(Graphics, pen: THandle; x1, y1, x2, y2: Integer): TGdipStatus; stdcall;
        CreatePen: function(color: Cardinal; Width: Single; units: TUnit; out pen: THandle):
            TGdipStatus; stdcall;
        DeletePen: function(pen: THandle): TGdipStatus; stdcall;
        Flush: function(Graphics: THandle; intention: Integer = 0): TGdipStatus; stdcall;
        SetSmoothingMode: function(Graphics: THandle; mode: TSmoothingMode): TGdipStatus; stdcall;
        SetTextRenderingHint: function(Graphics: THandle; mode: TTextRenderingHint): TGdipStatus;
            stdcall;
        SetPenBrushFill: function(pen, Brush: THandle): TGdipStatus; stdcall;
        SetPenColor: function(pen: THandle; color: Cardinal): TGdipStatus; stdcall;
        SetPenWidth: function(pen: THandle; Width: Single): TGdipStatus; stdcall;
        DeleteBrush: function(Brush: THandle): TGdipStatus; stdcall;
        CreateSolidFill: function(color: Cardinal; var Brush: THandle): TGdipStatus; stdcall;
        FillRectangle: function(Graphics, Brush: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        FillEllipse: function(Graphics, Brush: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        DrawEllipse: function(Graphics, pen: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        DrawCurve: function(Graphics, pen: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        GraphicsClear: function(Graphics: THandle; color: Cardinal): TGdipStatus; stdcall;
        SetPageUnit: function(Graphics: THandle; units: TUnit): TGdipStatus; stdcall;
        DrawRectangle: function(Graphics, pen: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        SetPenDashStyle: function(pen: THandle; dashStyle: Integer): TGdipStatus; stdcall;
        DrawPolygon: function(Graphics, pen: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        FillPolygon: function(Graphics, Brush: THandle; Points: Pointer; Count: Integer; fillMode:
            TFillMode): TGdipStatus; stdcall;
        SetWorldTransform: function(Graphics, matrix: THandle): TGdipStatus; stdcall;
        GetWorldTransform: function(Graphics, matrix: THandle): TGdipStatus; stdcall;
        CreateMatrix: function(out matrix: THandle): TGdipStatus; stdcall;
        CreateMatrix2: function(m11, m12, m21, m22, dx, dy: Single; out matrix: THandle):
            TGdipStatus; stdcall;
        DeleteMatrix: function(matrix: THandle): TGdipStatus; stdcall;
        SetMatrixElements: function(matrix: THandle; m11, m12, m21, m22, dx, dy: Single):
            TGdipStatus; stdcall;
        MultiplyMatrix: function(matrix, matrix2: THandle; order: Integer = 0): TGdipStatus;
            stdcall;
        ScaleMatrix: function(matrix: THandle; ScaleX, ScaleY: Single; order: Integer = 0):
            TGdipStatus; stdcall;
        TranslateMatrix: function(matrix: THandle; offsetX, offsetY: Single; order: Integer = 0):
            TGdipStatus; stdcall;
        DrawLines: function(Graphics, pen: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        RecordMetafile: function(DC: hdc; emfType: TEmfType; frameRect: PGdipRect;
            frameUnit: TUnit; description: PWideChar; var out_metafile: THandle): TGdipStatus;
                stdcall;
        RecordMetafileStream: function(strm: IStream; DC: hdc; emfType: TEmfType; const frameRect:
            TGdipRect;
            frameUnit: TUnit; description: PWideChar; var out_metafile: THandle): TGdipStatus;
                stdcall;
        PlayRecord: function(metafile: THandle; RecType, flags, RecSize: Cardinal; Rec: Pointer):
            TGdipStatus; stdcall;
        EnumerateMetaFile: function(Graphics, metafile: THandle; Dest: PGdipRect;
            callback, data: Pointer; imageAttributes: Integer = 0): TGdipStatus; stdcall;
        ResetWorldTransform: function(Graphics: THandle): TGdipStatus; stdcall;
        RotateTransform: function(Graphics: THandle; angle: Single; order: Integer = 0): TGdipStatus;
            stdcall;
        TranslateTransform: function(Graphics: THandle; dx, dy: Single; order: Integer = 0):
            TGdipStatus; stdcall;
        CreateFromImage: function(image: THandle; out Graphics: THandle): TGdipStatus; stdcall;
        CreateFontFrom: function(aHDC: hdc; out font: THandle): TGdipStatus; stdcall;
        DeleteFont: function(font: THandle): TGdipStatus; stdcall;
        CreateFontFromLogfont: function(hdc: hdc; logfont: PLOGFONTW; out font: THandle):
            TGdipStatus; stdcall;
        DrawString: function(Graphics: THandle; text: PWideChar; length: Integer; font: THandle;
            Dest: PGdipRectF; format, Brush: THandle): TGdipStatus; stdcall;
        MeasureString: function(Graphics: THandle; text: PWideChar; length: Integer; font: THandle;
            Dest: PGdipRectF; format: THandle; bound: PGdipRectF;
            codepointsFitted, linesFilled: PInteger): TGdipStatus; stdcall;
        DrawDriverString: function(Graphics: THandle; text: PWideChar;
            length: Integer; font, Brush: THandle; positions: PGdipPointFArray; flag: Integer;
                matrix: THandle): TGdipStatus; stdcall;
        CreatePath: function(brushmode: TFillMode; var path: THandle): TGdipStatus; stdcall;
        DeletePath: function(path: THandle): TGdipStatus; stdcall;
        DrawPath: function(Graphics, pen, path: THandle): TGdipStatus; stdcall;
        FillPath: function(Graphics, Brush, path: THandle): TGdipStatus; stdcall;
        AddPathLine: function(path: THandle; x1, y1, x2, y2: Integer): TGdipStatus; stdcall;
        AddPathLines: function(path: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        AddPathArc: function(path: THandle; X, Y, Width, Height: Integer; StartAndle, SweepAngle:
            Single): TGdipStatus; stdcall;
        AddPathCurve: function(path: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        AddPathClosedCurve: function(): TGdipStatus; stdcall;
        AddPathEllipse: function(path: THandle; X, Y, Width, Height: Integer): TGdipStatus; stdcall;
        AddPathPolygon: function(path: THandle; Points: Pointer; Count: Integer): TGdipStatus;
            stdcall;
        AddPathRectangle: function(path: THandle; X, Y, Width, Height: Integer): TGdipStatus;
            stdcall;
        ClosePath: function(path: THandle): TGdipStatus; stdcall;
        DrawArc: function(Graphics, pen: THandle; X, Y, Width, Height: Integer; StartAndle,
            SweepAngle: Single): TGdipStatus; stdcall;
        DrawBezier: function(Graphics, pen: THandle; x1, y1, x2, y2, X3, Y3, X4, Y4: Integer):
            TGdipStatus; stdcall;
        DrawPie: function(Graphics, pen: THandle; X, Y, Width, Height: Integer; StartAndle,
            SweepAngle: Single): TGdipStatus; stdcall;
        CreateBitmapFromScan0: function(Width, Height, Stride, format: Integer; Scan0: PByte;
            out bitmap: THandle): TGdipStatus; stdcall;
        BitmapLockBits: function(bitmap: THandle; const Rect: PGdipRect;
            flags: TLockModeOption; format: Integer; out LockedBitmapData: TGdipBitmapData):
                TGdipStatus; stdcall;
        BitmapUnlockBits: function(bitmap: THandle; const LockedBitmapData: TGdipBitmapData):
            TGdipStatus; stdcall;
    protected
        /// this function is available only with GDI+ version 1.1
        fConvertToEmfPlus: function(Graphics, image: THandle; var flag: BOOL;
            emfType: TEmfType; description: PWideChar; var out_metafile: Integer): TGdipStatus;
                stdcall;
        fConvertToEmfPlusTested: boolean;
        fForceInternalConvertToEmfPlus: boolean;
        function getNativeConvertToEmfPlus: boolean;
    public
        /// load the GDI+ library and all needed procedures
        // - returns TRUE on success
        // - library is loaded dynamically, therefore the executable is able
        // to launch before Windows XP, but GDI + functions (e.g. GIF, PNG, TIFF
        // and JPG pictures support or AntiAliased drawing) won't be available
        // - if no GdiPlus.dll file name is available, it will search the system
        // for the most recent version of GDI+ (either GDIPLUS.DLL in the current
        // directory, either the Office 2003 version, either the OS version - 1.1 is
        // available only since Vista and Seven; XP only shipped with version 1.1)
        constructor Create(aDllFileName: TFileName = '');
        /// draw the corresponding EMF metafile into a given device context
        // - this overriden implementation handles GDI+ AntiAliased drawing
        // - if GDI+ is not available, it will use default GDI32 function
        procedure DrawAntiAliased(Source: TMetafile; Dest: hdc; R: TRect;
            aSmoothing: TSmoothingMode = smAntiAlias;
            aTextRendering: TTextRenderingHint = trhClearTypeGridFit); override;
        /// convert a supplied EMF metafile into a EMF+ (i.e. GDI+ metafile)
        // - i.e. allows antialiased drawing of the EMF metafile
        // - if GDI+ is not available or conversion failed, return 0
        // - return a metafile handle, to be released after use (e.g. with
        // DrawImageRect) by DisposeImage()
        function ConvertToEmfPlus(Source: TMetafile; Dest: hdc;
            aSmoothing: TSmoothingMode = smAntiAlias;
            aTextRendering: TTextRenderingHint = trhClearTypeGridFit): THandle;
        /// internal method used for GDI32 metafile loading
        function MetaFileToStream(Source: TMetafile; out hGlobal: THandle): IStream;
        /// return true if DrawAntiAliased() method
        // will use native GDI+ conversion, i.e. if GDI+ installed version is 1.1
        property NativeConvertToEmfPlus: boolean read getNativeConvertToEmfPlus;
        /// can be set to true if to force DrawAntiAliased() method NOT to use
        //  native GDI+ 1.1 conversion, even if available
        // - we found out that GDI+ 1.1 was not as good as our internal conversion
        // function written in Delphi, e.g. for underlined fonts
        // - programs can set this property to true to avoid using GDI+ 1.1
        property ForceInternalConvertToEmfPlus: boolean
            read fForceInternalConvertToEmfPlus write fForceInternalConvertToEmfPlus;
    end;
{$A+}

const
    /// the corresponding file extension for every saving format type
    GDIPPictureExt: array[TGDIPPictureType] of TFileName =
    ('.gif', '.png', '.jpg', '.bmp', '.tif');

    /// retrieve a ready to be displayed name of the supplied Graphic Class
function PictureName(Pic: TGraphicClass): string;

/// helper to save a specified graphic into GIF/PNG/JPG/TIFF format
// - CompressionQuality is only used for gptJPG format saving
// and is expected to be from 0 to 100
// - if MaxPixelsForBiggestSide is set to something else than 0, the resulting
// picture biggest side won't exceed this pixel number
procedure SaveAs(Graphic: TPersistent; stream: TStream;
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0); overload;

/// helper to save a specified graphic into GIF/PNG/JPG/TIFF format
// - CompressionQuality is only used for gptJPG format saving
// and is expected to be from 0 to 100
// - if MaxPixelsForBiggestSide is set to something else than 0, the resulting
// picture biggest side won't exceed this pixel number
procedure SaveAs(Graphic: TPersistent; const filename: TFileName;
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0); overload;

/// helper to save a specified graphic into GIF/PNG/JPG/TIFF format
// - CompressionQuality is only used for gptJPG format saving
// and is expected to be from 0 to 100
// - if MaxPixelsForBiggestSide is set to something else than 0, the resulting
// picture biggest side won't exceed this pixel number
procedure SaveAsRawByteString(Graphic: TPersistent;
    out data: {$IFDEF UNICODE}RawByteString{$ELSE}AnsiString{$ENDIF};
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0);

/// helper to load a specified graphic from GIF/PNG/JPG/TIFF format content
function LoadFromRawByteString(const Picture:
    {$IFDEF UNICODE}RawByteString{$ELSE}AnsiString{$ENDIF}): TBitmap;

/// helper function to create a bitmap from any GIF/PNG/JPG/TIFF/EMF/WMF file
// - if file extension if .EMF, the file is drawn with a special antialiased
// GDI+ drawing method (if the global Gdip var is a TGDIPlusFull instance)
function LoadFrom(const filename: TFileName): TBitmap; overload;

/// helper function to create a bitmap from any EMF content
// - the file is drawn with a special antialiased
// GDI+ drawing method (if the global Gdip var is a TGDIPlusFull instance)
function LoadFrom(const metafile: TMetafile): TBitmap; overload;

/// draw the specified GDI TMetaFile (emf) using the GDI-plus antialiaised engine
procedure DrawEmfGdip(aHDC: hdc; Source: TMetafile; var R: TRect;
    ForceInternalAntiAliased: boolean);

var
    /// GDI+ library instance
    // - only initialized at program startup if the NOTSYNPICTUREREGISTER is NOT
    // defined (which is not the default)
    // - Gdip.Exists return FALSE if the GDI+ library is not available in this
    // operating system (e.g. on Windows 2000) nor the current executable folder
    Gdip: TGDIPlus = nil;

    /// test function
procedure GdipTest(const JpegFile: TFileName);

implementation

{
// Common GDI+ color constants
const
  aclAliceBlue            = $FFF0F8FF;
  aclAntiqueWhite         = $FFFAEBD7;
  aclAqua                 = $FF00FFFF;
  aclAquamarine           = $FF7FFFD4;
  aclAzure                = $FFF0FFFF;
  aclBeige                = $FFF5F5DC;
  aclBisque               = $FFFFE4C4;
  aclBlack                = $FF000000;
  aclBlanchedAlmond       = $FFFFEBCD;
  aclBlue                 = $FF0000FF;
  aclBlueViolet           = $FF8A2BE2;
  aclBrown                = $FFA52A2A;
  aclBurlyWood            = $FFDEB887;
  aclCadetBlue            = $FF5F9EA0;
  aclChartreuse           = $FF7FFF00;
  aclChocolate            = $FFD2691E;
  aclCoral                = $FFFF7F50;
  aclCornflowerBlue       = $FF6495ED;
  aclCornsilk             = $FFFFF8DC;
  aclCrimson              = $FFDC143C;
  aclCyan                 = $FF00FFFF;
  aclDarkBlue             = $FF00008B;
  aclDarkCyan             = $FF008B8B;
  aclDarkGoldenrod        = $FFB8860B;
  aclDarkGray             = $FFA9A9A9;
  aclDarkGreen            = $FF006400;
  aclDarkKhaki            = $FFBDB76B;
  aclDarkMagenta          = $FF8B008B;
  aclDarkOliveGreen       = $FF556B2F;
  aclDarkOrange           = $FFFF8C00;
  aclDarkOrchid           = $FF9932CC;
  aclDarkRed              = $FF8B0000;
  aclDarkSalmon           = $FFE9967A;
  aclDarkSeaGreen         = $FF8FBC8B;
  aclDarkSlateBlue        = $FF483D8B;
  aclDarkSlateGray        = $FF2F4F4F;
  aclDarkTurquoise        = $FF00CED1;
  aclDarkViolet           = $FF9400D3;
  aclDeepPink             = $FFFF1493;
  aclDeepSkyBlue          = $FF00BFFF;
  aclDimGray              = $FF696969;
  aclDodgerBlue           = $FF1E90FF;
  aclFirebrick            = $FFB22222;
  aclFloralWhite          = $FFFFFAF0;
  aclForestGreen          = $FF228B22;
  aclFuchsia              = $FFFF00FF;
  aclGainsboro            = $FFDCDCDC;
  aclGhostWhite           = $FFF8F8FF;
  aclGold                 = $FFFFD700;
  aclGoldenrod            = $FFDAA520;
  aclGray                 = $FF808080;
  aclGreen                = $FF008000;
  aclGreenYellow          = $FFADFF2F;
  aclHoneydew             = $FFF0FFF0;
  aclHotPink              = $FFFF69B4;
  aclIndianRed            = $FFCD5C5C;
  aclIndigo               = $FF4B0082;
  aclIvory                = $FFFFFFF0;
  aclKhaki                = $FFF0E68C;
  aclLavender             = $FFE6E6FA;
  aclLavenderBlush        = $FFFFF0F5;
  aclLawnGreen            = $FF7CFC00;
  aclLemonChiffon         = $FFFFFACD;
  aclLightBlue            = $FFADD8E6;
  aclLightCoral           = $FFF08080;
  aclLightCyan            = $FFE0FFFF;
  aclLightGoldenrodYellow = $FFFAFAD2;
  aclLightGray            = $FFD3D3D3;
  aclLightGreen           = $FF90EE90;
  aclLightPink            = $FFFFB6C1;
  aclLightSalmon          = $FFFFA07A;
  aclLightSeaGreen        = $FF20B2AA;
  aclLightSkyBlue         = $FF87CEFA;
  aclLightSlateGray       = $FF778899;
  aclLightSteelBlue       = $FFB0C4DE;
  aclLightYellow          = $FFFFFFE0;
  aclLime                 = $FF00FF00;
  aclLimeGreen            = $FF32CD32;
  aclLinen                = $FFFAF0E6;
  aclMagenta              = $FFFF00FF;
  aclMaroon               = $FF800000;
  aclMediumAquamarine     = $FF66CDAA;
  aclMediumBlue           = $FF0000CD;
  aclMediumOrchid         = $FFBA55D3;
  aclMediumPurple         = $FF9370DB;
  aclMediumSeaGreen       = $FF3CB371;
  aclMediumSlateBlue      = $FF7B68EE;
  aclMediumSpringGreen    = $FF00FA9A;
  aclMediumTurquoise      = $FF48D1CC;
  aclMediumVioletRed      = $FFC71585;
  aclMidnightBlue         = $FF191970;
  aclMintCream            = $FFF5FFFA;
  aclMistyRose            = $FFFFE4E1;
  aclMoccasin             = $FFFFE4B5;
  aclNavajoWhite          = $FFFFDEAD;
  aclNavy                 = $FF000080;
  aclOldLace              = $FFFDF5E6;
  aclOlive                = $FF808000;
  aclOliveDrab            = $FF6B8E23;
  aclOrange               = $FFFFA500;
  aclOrangeRed            = $FFFF4500;
  aclOrchid               = $FFDA70D6;
  aclPaleGoldenrod        = $FFEEE8AA;
  aclPaleGreen            = $FF98FB98;
  aclPaleTurquoise        = $FFAFEEEE;
  aclPaleVioletRed        = $FFDB7093;
  aclPapayaWhip           = $FFFFEFD5;
  aclPeachPuff            = $FFFFDAB9;
  aclPeru                 = $FFCD853F;
  aclPink                 = $FFFFC0CB;
  aclPlum                 = $FFDDA0DD;
  aclPowderBlue           = $FFB0E0E6;
  aclPurple               = $FF800080;
  aclRed                  = $FFFF0000;
  aclRosyBrown            = $FFBC8F8F;
  aclRoyalBlue            = $FF4169E1;
  aclSaddleBrown          = $FF8B4513;
  aclSalmon               = $FFFA8072;
  aclSandyBrown           = $FFF4A460;
  aclSeaGreen             = $FF2E8B57;
  aclSeaShell             = $FFFFF5EE;
  aclSienna               = $FFA0522D;
  aclSilver               = $FFC0C0C0;
  aclSkyBlue              = $FF87CEEB;
  aclSlateBlue            = $FF6A5ACD;
  aclSlateGray            = $FF708090;
  aclSnow                 = $FFFFFAFA;
  aclSpringGreen          = $FF00FF7F;
  aclSteelBlue            = $FF4682B4;
  aclTan                  = $FFD2B48C;
  aclTeal                 = $FF008080;
  aclThistle              = $FFD8BFD8;
  aclTomato               = $FFFF6347;
  aclTransparent          = $00FFFFFF;
  aclTurquoise            = $FF40E0D0;
  aclViolet               = $FFEE82EE;
  aclWheat                = $FFF5DEB3;
  aclWhite                = $FFFFFFFF;
  aclWhiteSmoke           = $FFF5F5F5;
  aclYellow               = $FFFFFF00;
  aclYellowGreen          = $FF9ACD32;
}

{ TSynLibrary }

function TSynLibrary.Exists: boolean;
begin
    result := (self <> nil) and (fHandle <> 0);
end;

function ProcLoad(H: HMODULE; Addr: PPointer; Names: PPChar): boolean;
begin
    result := false;
    if Names <> nil then
        repeat
            Addr^ := GetProcAddress(H, Names^);
            if Addr^ = nil then
                exit;
            inc(Addr);
            inc(Names);
        until Names^ = nil;
    result := true;
end;

class function TSynLibrary.Load(const aDllFileName: TFileName; Addr: PPointer;
    Names: PPChar): HMODULE;
var
    H: HMODULE;
begin
    result := 0;
    H := SafeLoadLibrary(aDllFileName);
    if (H <> 0) and ProcLoad(H, Addr, Names) then
        result := H;
end;

procedure TSynLibrary.UnLoad;
begin
    if fHandle = 0 then
        exit;
    FreeLibrary(fHandle);
    fHandle := 0;
end;

{ TGDIPlus }

{$IFDEF USEENCODERS}
type
    ImageCodecInfo = packed record
        Clsid: TGUID;
        FormatID: TGUID;
        CodecName: PWCHAR;
        DllName: PWCHAR;
        FormatDescription: PWCHAR;
        FilenameExtension: PWCHAR;
        MimeType: PWCHAR;
        flags: DWORD;
        Version: DWORD;
        SigCount: DWORD;
        SigSize: DWORD;
        SigPattern: PByte;
        SigMask: PByte;
    end;
    TImageCodecInfo = ImageCodecInfo;
    PImageCodecInfo = ^TImageCodecInfo;

function StrWCompAnsi(Str1: PWideChar; Str2: PAnsiChar): Integer; assembler;
asm // to avoid widestring usage + compatibility with Delphi 2009/2010/XE
        MOV     ECX,EAX
        XOR     EAX,EAX
        CMP     ECX,EDX
        JE      @Exit2  // same string or both nil
        OR      ECX,ECX
        MOV     AL,1
        JZ      @Exit2  // Str1=''
        OR      EDX,EDX
        JE      @min
@1:     MOV     AL,[ECX] // Ansi compare value of PWideChar
        ADD     ECX,2
        MOV     AH,[EDX]
        INC     EDX
        TEST    AL,AL
        JE      @Exit
        CMP     AL,AH
        JE      @1
@Exit:  XOR     EDX,EDX
        XCHG    AH,DL
        SUB     EAX,EDX
@Exit2: RET
@min:   OR      EAX,-1
end;

function GetEncoderClsid(format: PAnsiChar; out pClsid: TGUID): Integer;
var
    num, size: Cardinal;
    ImageCodecInfo: AnsiString;
    P: PImageCodecInfo;
begin
    num := 0; // number of image encoders
    size := 0; // size of the image encoder array in bytes
    result := -1;
    if not Gdip.Exists then
        exit;
    if (Gdip.GetImageEncodersSize(num, size) <> stOk) or (size = 0) then
        exit;
    SetLength(ImageCodecInfo, size);
    P := Pointer(ImageCodecInfo);
    if Gdip.GetImageEncoders(num, size, P)) <> stOk then
    exit;
    for result := 0 to num - 1 do
        if StrWCompAnsi(P^.MimeType, format) = 0 then
        begin
            pClsid := P^.Clsid;
            exit;
        end
        else
            inc(P);
    result := -1;
end;

const
    MimeTypes: array[TGDIPPictureType] of PAnsiChar =
    ('image/gif', 'image/png', 'image/jpeg', 'image/bmp', 'image/tiff');

var
    encoders: array[TGDIPPictureType] of TGUID;

{$ELSE}

const
    encoders: array[TGDIPPictureType] of TGUID =
    ('{557CF402-1A04-11D3-9A73-0000F81EF32E}',
        '{557CF406-1A04-11D3-9A73-0000F81EF32E}',
        '{557CF401-1A04-11D3-9A73-0000F81EF32E}',
        '{557CF400-1A04-11D3-9A73-0000F81EF32E}',
        '{557CF405-1A04-11D3-9A73-0000F81EF32E}');

{$ENDIF}

const
    GdiPProcNames: array[0..15{$IFDEF USEDPI} + 1{$ENDIF}
{$IFDEF USEENCODERS} + 2{$ENDIF}] of PChar =
    ('GdiplusStartup', 'GdiplusShutdown',
        'GdipDeleteGraphics', 'GdipCreateFromHDC',
        'GdipLoadImageFromStream', 'GdipLoadImageFromFile',
        'GdipDrawImageRectI', 'GdipDrawImageRectRectI',
{$IFDEF USEDPI} 'GdipDrawImageI', {$ENDIF}
        'GdipDisposeImage', 'GdipGetImageRawFormat',
        'GdipGetImageWidth', 'GdipGetImageHeight', 'GdipSaveImageToStream',
{$IFDEF USEENCODERS} 'GdipGetImageEncodersSize', 'GdipGetImageEncoders', {$ENDIF}
        'GdipCreateBitmapFromHBITMAP', 'GdipCreateBitmapFromGdiDib',
        nil);

constructor TGDIPlus.Create(const aDllFileName: TFileName);
var
    Input: packed record
        Version: Integer; // Must be one
        DebugEventCallback: Pointer; // Only for debug builds
        SuppressBackgroundThread: BOOL; // True if replacing GDI+ background processing
        SuppressExternalCodecs: BOOL; // True if only using internal codecs
    end;
{$IFDEF USEENCODERS}
    format: TGDIPPictureType;
{$ENDIF}
begin
    if fHandle = 0 then
    begin
        fHandle := Load(aDllFileName, @@Startup, @GdiPProcNames);
        if fHandle = 0 then
            exit;
    end;
    fillchar(Input, sizeof(Input), 0);
    Input.Version := 1;
    // see http://mikevdm.com/BlogEntry/Key/GdiplusShutdown-Hangs-Mysteriously
    Input.SuppressBackgroundThread := true;
    if Startup(fToken, Input, fStartupHook) <> stOk then
    begin
        fToken := 0;
        UnLoad;
        exit;
    end;
    fStartupHook.Hook(fStartupHookToken);
{$IFDEF USEENCODERS}
    for format := low(format) to high(format) do
        GetEncoderClsid(MimeTypes[format], encoders[format]);
{$ENDIF}
end;

procedure TGDIPlus.DrawAntiAliased(Source: TMetafile; Dest: hdc; R: TRect;
    aSmoothing: TSmoothingMode; aTextRendering: TTextRenderingHint);
begin
    dec(R.Right);
    dec(R.Bottom); // Metafile rect includes right and bottom coords
    PlayEnhMetaFile(Dest, Source.Handle, R); // use GDI drawing by default
end;

function TGDIPlus.DrawAntiAliased(Source: TMetafile; ScaleX, ScaleY: Integer;
    aSmoothing: TSmoothingMode; aTextRendering: TTextRenderingHint): TBitmap;
var
    R: TRect;
begin
    result := nil;
    if Source = nil then // self=nil is OK below
        exit;
    R.Left := 0;
    R.Right := (Source.Width * ScaleX) div 100;
    R.Top := 0;
    R.Bottom := (Source.Height * ScaleY) div 100;
    result := TBitmap.Create;
    result.Width := R.Right;
    result.Height := R.Bottom;
    if self = nil then
    begin // no GDI+ available -> use GDI drawing
        dec(R.Right); // Metafile rect includes right and bottom coords
        dec(R.Bottom);
        PlayEnhMetaFile(result.Canvas.Handle, Source.Handle, R);
    end
    else
        DrawAntiAliased(Source, result.Canvas.Handle, R, aSmoothing, aTextRendering);
end;

destructor TGDIPlus.Destroy;
begin
    if fToken <> 0 then
    begin
        fStartupHook.Unhook(fStartupHookToken);
        Shutdown(fToken);
        fToken := 0;
    end;
    UnLoad;
end;

const
    PicturesExt: array[0..5] of TFileName =
    ('jpg', 'jpeg', 'png', 'gif', 'tif', 'tiff');
    PictureClasses: array[0..5] of TGraphicClass =
    (TJpegImage, TJpegImage, TPngImage, TGifImage, TTiffImage, TTiffImage);

function PictureName(Pic: TGraphicClass): string;
var
    i: Integer;
begin
    result := '';
    if Pic <> nil then
        if Pic.InheritsFrom(TIcon) or Pic.InheritsFrom(TBitmap) or
            Pic.InheritsFrom(TMetafile) then
            result := copy(Pic.ClassName, 2, maxInt)
        else
            for i := 0 to high(PictureClasses) do
                if Pic.InheritsFrom(PictureClasses[i]) then
                    result := copy(Pic.ClassName, 2, length(Pic.ClassName) - 6);
end;

procedure TGDIPlus.RegisterPictures;
var
    i: Integer;
begin
    // launch Gdip.RegisterPictures to initialize the GDI+ library if necessary
    if (self = nil) and (Gdip = nil) then
        Gdip := TGDIPlus.Create('gdiplus.dll');
    // register JPG and PNG pictures as TGraphic
    if GetClass('TTiffImage') = nil then
    begin
        RegisterClass(TJpegImage);
        RegisterClass(TPngImage);
        RegisterClass(TGifImage);
        RegisterClass(TTiffImage);
        for i := 0 to high(PicturesExt) do
            TPicture.RegisterFileFormat(PicturesExt[i],
                PictureName(PictureClasses[i]), PictureClasses[i]);
    end;
end;

{ TSynPicture }

procedure TSynPicture.Assign(Source: TPersistent);
var
    S: TMemoryStream;
begin
    if (Source <> nil) and Source.InheritsFrom(TPicture) then
        Source := TPicture(Source).Graphic;
    if (Source = nil) or not Gdip.Exists or
        (Source.InheritsFrom(TSynPicture) and not TSynPicture(Source).fHasContent) then
        Clear
    else if Source.InheritsFrom(TBitmap) then
    begin // direct bitmap creation
        Clear;
        with TBitmap(Source) do
            if Gdip.CreateBitmapFromHBITMAP(Handle, Palette, fImage) <> stOk then
            begin
                Clear;
                exit;
            end;
        fAssignedFromBitmap := true;
        fImageSet;
    end
    else if Source.InheritsFrom(TGraphic) then
    begin // loading from a temp stream
        S := TMemoryStream.Create;
        try
            TGraphic(Source).SaveToStream(S);
            S.Seek(0, soFromBeginning);
            LoadFromStream(S);
        finally
            S.Free;
        end;
    end
    else
        Clear;
end;

procedure TSynPicture.Clear;
begin
    fHasContent := false;
    fAssignedFromBitmap := false;
    fWidth := 0;
    fHeight := 0;
    if fImage <> 0 then
    begin
        Gdip.DisposeImage(fImage);
        fImage := 0;
    end;
    fStream := nil;
    if fGlobal <> 0 then
    begin
        GlobalFree(fGlobal);
        fGlobal := 0;
    end;
    fGlobalLen := 0;
end;

constructor TSynPicture.Create;
begin
    inherited;
end;

destructor TSynPicture.Destroy;
begin
    Clear;
    inherited;
end;

procedure TSynPicture.Draw(ACanvas: TCanvas; const Rect: TRect);
var
    Graphics: THandle;
begin
    if (self = nil) or not fHasContent or (fImage = 0) or (ACanvas = nil) or
        not Gdip.Exists then
        exit;
    if (Gdip.CreateFromHDC(ACanvas.Handle, Graphics) = stOk) and (Graphics <> 0) then
    try
        Gdip.DrawImageRect(Graphics, fImage,
            Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
    finally
        Gdip.DeleteGraphics(Graphics);
    end;
end;

{$IFDEF USEDPI}

procedure TSynPicture.DrawAt(ACanvas: TCanvas; X, Y: Integer);
var
    Graphics: THandle;
begin
    if (self = nil) or not fHasContent or (fImage = 0) or (ACanvas = nil) or
        not Gdip.Exists then
        exit;
    Graphics := 0;
    Gdip.SetStatus(Gdip.CreateFromHDC(ACanvas.Handle, Graphics));
    if Graphics <> 0 then
    try
        Gdip.SetStatus(Gdip.DrawImage(Graphics, fImage, X, Y));
    finally
        Gdip.SetStatus(Gdip.DeleteGraphics(Graphics));
    end;
end;
{$ENDIF}

procedure TSynPicture.fImageSet;
begin
    if fImage = 0 then
        exit;
    if (Gdip.GetImageWidth(fImage, fWidth) <> stOk) or
        (Gdip.GetImageHeight(fImage, fHeight) <> stOk) or
        (fWidth = 0) or (fHeight = 0) then
        Clear
    else
        fHasContent := true;
end;

function TSynPicture.GetEmpty: boolean;
begin
    result := not fHasContent;
end;

function TSynPicture.GetHeight: Integer;
begin
    result := fHeight;
end;

function TSynPicture.GetImageFormat: TGDIPPictureType;
const // only the TGUID.D1 is relevant here
    RawFormat: array[TGDIPPictureType] of Cardinal =
    ($B96B3CB0, $B96B3CAF, $B96B3CAE, $B96B3CAB, $B96B3CB1);
var
    id: TGUID;
begin
    if Gdip.Exists and fHasContent and (fImage <> 0) and
        (Gdip.GetImageRawFormat(fImage, id) = stOk) then
        for result := low(result) to high(result) do
            if id.D1 = RawFormat[result] then
                exit;
    result := gptBMP; // by default, returns bitmap
end;

function TSynPicture.GetWidth: Integer;
begin
    result := fWidth;
end;

class function TSynPicture.IsPicture(const filename: TFileName): TGraphicClass;
var
    Ext: TFileName;
    i: Integer;
begin
    result := nil;
    Ext := ExtractFileExt(filename);
    if Ext = '' then
        exit;
    Delete(Ext, 1, 1); // '.bmp' -> 'bmp'
    if SameText(Ext, 'BMP') then
        result := TBitmap
    else if SameText(Ext, 'EMF') then
        result := TMetafile
    else if SameText(Ext, 'WMF') then
        result := TMetafile
    else if SameText(Ext, 'ICO') then
        result := TIcon
    else
        for i := 0 to high(PicturesExt) do
            if SameText(Ext, PicturesExt[i]) then
            begin
                result := PictureClasses[i];
                exit;
            end;
end;

procedure TSynPicture.LoadFromClipboardFormat(AFormat: Word;
    AData: THandle; APalette: HPALETTE);
begin // not implemented
end;

procedure TSynPicture.LoadFromFile(const filename: string);
var
    FS: TFileStream;
begin // don't use direct GDI+ file oriented API: it's better having a local
    // copy of the untouched data in memory (e.g. for further jpeg saving)
    Clear;
    if not Gdip.Exists or not FileExists(filename) then
        exit;
    FS := TFileStream.Create(filename, fmOpenRead or fmShareDenyNone);
    try
        LoadFromStream(FS);
    finally
        FS.Free;
    end;
end;

procedure TSynPicture.LoadFromResourceName(Instance: THandle;
    const ResName: string);
var
    stream: TCustomMemoryStream;
begin
    if FindResource(Instance, PChar(ResName), RT_RCDATA) <> 0 then
    begin
        stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
        try
            LoadFromStream(stream);
        finally
            stream.Free;
        end;
    end
    else
        Clear;
end;

function TSynPicture.LoadFromIStream(stream: IStream): TGdipStatus;
begin
    if not Gdip.Exists then
    begin
        result := stInvalidParameter;
        exit;
    end;
    result := Gdip.LoadImageFromStream(stream, fImage);
    if result = stOk then
    begin
        fStream := stream;
        fImageSet;
    end
    else
        Clear;
end;

procedure TSynPicture.LoadFromStream(stream: TStream);
var
    P: Pointer;
begin
    Clear;
    if not Gdip.Exists or (stream = nil) then
        exit;
    fGlobalLen := stream.size;
    if fGlobalLen = 0 then
        exit;
    stream.Seek(0, soFromBeginning);
    fGlobal := GlobalAlloc(GMEM_MOVEABLE, fGlobalLen);
    if fGlobal = 0 then
        exit;
    P := GlobalLock(fGlobal);
    stream.Read(P^, fGlobalLen);
    GlobalUnlock(fGlobal);
    CreateStreamOnHGlobal(fGlobal, true, fStream); // now fStream = data
    LoadFromIStream(fStream);
end;

function TSynPicture.RectNotBiggerThan(MaxPixelsForBiggestSide: Integer): TRect;
begin
    result.Left := 0;
    result.Top := 0;
    result.Bottom := fHeight;
    result.Right := fWidth;
    if not fHasContent or (result.Bottom = 0) or (result.Right = 0) then
        exit;
    if result.Right > result.Bottom then
    begin
        if result.Right > MaxPixelsForBiggestSide then
        begin
            result.Bottom := (result.Bottom * MaxPixelsForBiggestSide) div result.Right;
            result.Right := MaxPixelsForBiggestSide;
        end;
    end
    else if result.Bottom > MaxPixelsForBiggestSide then
    begin
        result.Right := (result.Right * MaxPixelsForBiggestSide) div result.Bottom;
        result.Bottom := MaxPixelsForBiggestSide;
    end;
end;

type
    EncoderParameter = packed record
        Guid: TGUID; // GUID of the parameter
        NumberOfValues: ULONG; // Number of the parameter values
        Type_: ULONG; // Value type, like ValueTypeLONG  etc.
        Value: Pointer; // A pointer to the parameter values
    end;
    TEncoderParameter = EncoderParameter;
    PEncoderParameter = ^TEncoderParameter;
    EncoderParameters = packed record
        Count: UINT; // Number of parameters in this structure
        Parameter: array[0..0] of TEncoderParameter; // Parameter values
    end;
    TEncoderParameters = EncoderParameters;
    PEncoderParameters = ^TEncoderParameters;

const
    EncoderParameterValueTypeLong = 4; // 32-bit unsigned int
    EncoderQuality: TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}';
    EncoderCompression: TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}';

function TSynPicture.SaveAs(stream: TStream; format: TGDIPPictureType;
    CompressionQuality: Integer): TGdipStatus;
var
    fStream: IStream;
    Len, Dummy: Int64;
    tmp: Pointer;
    Params: TEncoderParameters;
    PParams: Pointer;
    MS: TMemoryStream absolute stream;
begin
    if not Gdip.Exists or (stream = nil) or (fImage = 0) then
    begin
        result := stInvalidParameter;
        exit;
    end;
    Params.Count := 1;
    Params.Parameter[0].Type_ := EncoderParameterValueTypeLong;
    Params.Parameter[0].NumberOfValues := 1;
    Params.Parameter[0].Value := @CompressionQuality;
    PParams := nil;
    case format of
        gptJPG: if CompressionQuality >= 0 then
            begin
                Params.Parameter[0].Guid := EncoderQuality;
                PParams := @Params;
            end;
        gptTIF:
            begin
                if not (TGDIPPEncoderValue(CompressionQuality) in [
                    evCompressionLZW, evCompressionCCITT3, evCompressionCCITT4,
                        evCompressionRle, evCompressionNone]) then
                    // default tiff compression is LZW
                    CompressionQuality := ord(evCompressionLZW);
                Params.Parameter[0].Guid := EncoderCompression;
                PParams := @Params;
            end;
    end;
    CreateStreamOnHGlobal(0, true, fStream);
    try
        result := Gdip.SaveImageToStream(fImage, fStream, @encoders[format], PParams);
        if result <> stOk then
            exit;
        fStream.Seek(0, STREAM_SEEK_END, Len);
        fStream.Seek(0, STREAM_SEEK_SET, Dummy);
        Getmem(tmp, Len);
        try
            fStream.Read(tmp, Len, nil);
            stream.Write(tmp^, Len);
        finally
            Freemem(tmp);
        end;
    finally
        fStream := nil; // release memory
    end;
end;

procedure TSynPicture.SaveInternalToStream(stream: TStream);
var
    P: Pointer;
    F: TGDIPPictureType;
begin
    if not Gdip.Exists or (stream = nil) or (fImage = 0) then
        exit;
    if (fGlobal <> 0) and not fAssignedFromBitmap then
    begin
        // e.g. for a true .jpg file -> just save as it was loaded :)
        P := GlobalLock(fGlobal);
        stream.Write(P^, fGlobalLen);
        GlobalUnlock(fGlobal);
    end
    else
    begin
        // should come from a bitmap -> save in the expected format
        if InheritsFrom(TJpegImage) then
            F := gptJPG
        else if InheritsFrom(TGifImage) then
            F := gptGIF
        else if InheritsFrom(TPngImage) then
            F := gptPNG
        else if InheritsFrom(TTiffImage) then
            F := gptTIF
        else
            F := GetImageFormat;
        SaveAs(stream, F);
    end;
end;

procedure TSynPicture.SaveToClipboardFormat(var AFormat: Word;
    var AData: THandle; var APalette: HPALETTE);
begin // not implemented
end;

procedure TSynPicture.SaveToStream(stream: TStream);
begin
    SaveInternalToStream(stream);
end;

procedure TSynPicture.SetHeight(Value: Integer);
begin // not implemented
end;

procedure TSynPicture.SetWidth(Value: Integer);
begin // not implemented
end;

function TSynPicture.ToBitmap: TBitmap;
begin
    if not fHasContent then
        result := nil
    else
    begin
        result := TBitmap.Create;
        result.Width := Width;
        result.Height := Height;
        result.Canvas.Draw(0, 0, self);
    end;
end;

{ TJpegImage }

constructor TJpegImage.Create;
begin
    inherited;
    fCompressionQuality := 80; // default quality
end;

procedure TJpegImage.SaveToStream(stream: TStream);
begin
    SaveAs(stream, gptJPG, fCompressionQuality);
end;

procedure SaveAs(Graphic: TPersistent; stream: TStream;
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0); overload;
var
    Bmp: TBitmap;
    R: TRect;
    Pic: TSynPicture;
begin
    if Graphic.InheritsFrom(TSynPicture) then
        Pic := TSynPicture(Graphic)
    else
        Pic := TSynPicture.Create;
    try
        if Pic <> Graphic then
            Pic.Assign(Graphic); // will do the conversion
        if (MaxPixelsForBiggestSide = 0) or
            ((Pic.fWidth <= MaxPixelsForBiggestSide) and (Pic.fHeight <= MaxPixelsForBiggestSide))
                then
            // no resize necessary
            Pic.SaveAs(stream, format, CompressionQuality)
        else
        begin
            // resize to the maximum side specified parameter
            Bmp := TBitmap.Create;
            try
                R := Pic.RectNotBiggerThan(MaxPixelsForBiggestSide);
                Bmp.Width := R.Right;
                Bmp.Height := R.Bottom;
                Pic.Draw(Bmp.Canvas, R);
                SynGdiPlus.SaveAs(Bmp, stream, format, CompressionQuality, 0);
            finally
                Bmp.Free;
            end;
        end;
    finally
        if Pic <> Graphic then
            Pic.Free;
    end;
end;

procedure SaveAs(Graphic: TPersistent; const filename: TFileName;
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0); overload;
var
    stream: TStream;
begin
    stream := TFileStream.Create(filename, fmCreate);
    try
        SaveAs(Graphic, stream, format, CompressionQuality, MaxPixelsForBiggestSide);
    finally
        stream.Free;
    end;
end;

procedure SaveAsRawByteString(Graphic: TPersistent;
    out data: {$IFDEF UNICODE}RawByteString{$ELSE}AnsiString{$ENDIF};
    format: TGDIPPictureType; CompressionQuality: Integer = 80;
    MaxPixelsForBiggestSide: Cardinal = 0); overload;
var
    stream: TMemoryStream;
begin
    stream := TMemoryStream.Create;
    try
        SaveAs(Graphic, stream, format, CompressionQuality, MaxPixelsForBiggestSide);
        SetString(data, PAnsiChar(stream.Memory), stream.Seek(0, soFromCurrent));
    finally
        stream.Free;
    end;
end;

function LoadFromRawByteString(const Picture:
    {$IFDEF UNICODE}RawByteString{$ELSE}AnsiString{$ENDIF}): TBitmap;
var
    ST: TStringStream;
begin
    result := nil;
    if Picture = '' then
        exit;
    ST := TStringStream.Create(Picture);
    try
        with TSynPicture.Create do
        try
            LoadFromStream(ST);
            result := ToBitmap;
        finally
            Free;
        end;
    finally
        ST.Free;
    end;
end;

function LoadFrom(const filename: TFileName): TBitmap;
var
    P: TSynPicture;
    MF: TMetafile;
begin
    if FileExists(filename) then
        if SameText(ExtractFileExt(filename), '.EMF') then
        begin
            // EMF will be loaded and rendered using GDI+ anti-aliasing
            MF := TMetafile.Create;
            try
                MF.LoadFromFile(filename);
                result := LoadFrom(MF);
            finally
                MF.Free;
            end;
        end
        else
        begin
            // non vectorial pictures will be loaded via GDI+
            P := TSynPicture.Create;
            try
                P.LoadFromFile(filename);
                result := P.ToBitmap;
            finally
                P.Free;
            end;
        end
    else
        result := nil;
end;

function LoadFrom(const metafile: TMetafile): TBitmap; overload;
begin
    if (Gdip <> nil) and not Gdip.InheritsFrom(TGDIPlusFull) then
        FreeAndNil(Gdip); // we need the TGDIPlusFull features
    if Gdip = nil then
        // if specific gdiplus11.dll is not available then load OS default
        Gdip := TGDIPlusFull.Create;
    TGDIPlusFull(Gdip).ForceInternalConvertToEmfPlus := true;
    result := TGDIPlusFull(Gdip).DrawAntiAliased(metafile);
end;

procedure DrawEmfGdip(aHDC: hdc; Source: TMetafile; var R: TRect;
    ForceInternalAntiAliased: boolean);
begin
    if (Gdip <> nil) and not Gdip.InheritsFrom(TGDIPlusFull) then
        FreeAndNil(Gdip); // we need the TGDIPlusFull features
    if Gdip = nil then
        // if specific gdiplus11.dll is not available then load OS default
        Gdip := TGDIPlusFull.Create;
    if Gdip.InheritsFrom(TGDIPlusFull) then
        TGDIPlusFull(Gdip).ForceInternalConvertToEmfPlus := ForceInternalAntiAliased;
    Gdip.DrawAntiAliased(Source, aHDC, R);
end;

procedure GdipTest(const JpegFile: TFileName);
var
    B: TBitmap;
    FN: TFileName;
    P: TSynPicture;
    F: TGDIPPictureType;
begin
    FN := ExtractFilePath(paramstr(0)) + 'GdipTest\';
{$IFNDEF DELPHI5OROLDER}
    if not DirectoryExists(FN) then
        CreateDirectory(Pointer(FN), nil);
{$ENDIF}
    B := LoadFrom(JpegFile);
    B.SaveToFile(FN + 'Original.bmp');
    FN := FN + 'Test';
    for F := low(F) to high(F) do
        SaveAs(B, FN + GDIPPictureExt[F], F);
    B.Free;
    P := TSynPicture.Create;
    try
        for F := low(F) to high(F) do
        begin
            P.LoadFromFile(FN + GDIPPictureExt[F]);
            P.SaveToFile(FN + '-copy' + GDIPPictureExt[F]);
            B := P.ToBitmap;
            if B <> nil then
            try
                B.SaveToFile(FN + GDIPPictureExt[F] + '.bmp');
            finally
                B.Free;
            end;
        end;
    finally
        P.Free;
    end;
end;

{ TGDIPlusFull }

function ReadRegString(Key: THandle; const path, Value: string): string;
var
    size, typ: DWORD;
    tmp: array[byte] of char;
    k: HKey;
begin
    result := '';
    if RegOpenKeyEx(Key, Pointer(path), 0, KEY_QUERY_VALUE, k) = ERROR_SUCCESS then
    try
        size := 250;
        typ := REG_SZ;
        if RegQueryValueEx(k, Pointer(Value), nil, @typ, @tmp, @size) = ERROR_SUCCESS then
            result := tmp;
    finally
        RegCloseKey(k);
    end;
end;

{$IFDEF DELPHI6OROLDER}

function GetFileVersion(const AFileName: string): Cardinal;
var
    filename: string;
    InfoSize, Wnd: THandle;
    VerBuf: Pointer;
    FI: PVSFixedFileInfo;
    VerSize: Cardinal;
begin
    result := Cardinal(-1);
    // GetFileVersionInfo modifies the filename parameter data while parsing.
    // Copy the string const into a local variable to create a writeable copy.
    filename := AFileName;
    UniqueString(filename);
    InfoSize := GetFileVersionInfoSize(PChar(filename), Wnd);
    if InfoSize <> 0 then
    begin
        Getmem(VerBuf, InfoSize);
        try
            if GetFileVersionInfo(PChar(filename), Wnd, InfoSize, VerBuf) then
                if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
                    result := FI.dwFileVersionMS;
        finally
            Freemem(VerBuf);
        end;
    end;
end;
{$ENDIF}

constructor TGDIPlusFull.Create(aDllFileName: TFileName);
const
    GdiPFullProcNames: array[0..64] of PChar =
    ('GdipDrawLineI', 'GdipCreatePen1', 'GdipDeletePen', 'GdipFlush',
        'GdipSetSmoothingMode', 'GdipSetTextRenderingHint',
        'GdipSetPenBrushFill', 'GdipSetPenColor', 'GdipSetPenWidth',
        'GdipDeleteBrush', 'GdipCreateSolidFill',
        'GdipFillRectangleI', 'GdipFillEllipseI', 'GdipDrawEllipseI',
        'GdipDrawCurveI', 'GdipGraphicsClear',
        'GdipSetPageUnit', 'GdipDrawRectangleI', 'GdipSetPenDashStyle',
        'GdipDrawPolygonI', 'GdipFillPolygonI',
        'GdipSetWorldTransform', 'GdipGetWorldTransform',
        'GdipCreateMatrix', 'GdipCreateMatrix2', 'GdipDeleteMatrix',
        'GdipSetMatrixElements', 'GdipMultiplyMatrix',
        'GdipScaleMatrix', 'GdipTranslateMatrix',
        'GdipDrawLinesI', 'GdipRecordMetafileI', 'GdipRecordMetafileStreamI',
        'GdipPlayMetafileRecord', 'GdipEnumerateMetafileDestRectI',
        'GdipResetWorldTransform', 'GdipRotateWorldTransform',
        'GdipTranslateWorldTransform',
        'GdipGetImageGraphicsContext',
        'GdipCreateFontFromDC', 'GdipDeleteFont', 'GdipCreateFontFromLogfontW',
        'GdipDrawString', 'GdipMeasureString', 'GdipDrawDriverString',
        'GdipCreatePath', 'GdipDeletePath', 'GdipDrawPath', 'GdipFillPath',
        'GdipAddPathLineI', 'GdipAddPathLine2I', 'GdipAddPathArcI', 'GdipAddPathCurveI',
        'GdipAddPathClosedCurveI', 'GdipAddPathEllipseI', 'GdipAddPathPolygonI',
        'GdipAddPathRectangleI', 'GdipClosePathFigure',
        'GdipDrawArcI', 'GdipDrawBezierI', 'GdipDrawPieI',
        'GdipCreateBitmapFromScan0', 'GdipBitmapLockBits', 'GdipBitmapUnlockBits',
        nil);
    Office2003Version = $B0000; // Office 2003 = Office 11 ($B)
var
    i: Integer;
begin
    if (aDllFileName = '') or not FileExists(aDllFileName) then
    begin
        // first search gdiplus11.dll / gdiplus.dll in the same directory
        aDllFileName := ExtractFilePath(paramstr(0)) + 'gdiplus11.dll';
        if not FileExists(aDllFileName) then
            aDllFileName := ExtractFilePath(paramstr(0)) + 'gdiplus.dll';
        // if not available in the excutable folder, search for Office 2003/2007
        if not FileExists(aDllFileName) then
        begin
            aDllFileName := ReadRegString(HKEY_CLASSES_ROOT,
                'Applications\Winword.exe\shell\edit\command', '');
            if aDllFileName <> '' then
            begin
                Delete(aDllFileName, 1, 1);
                i := pos('"', aDllFileName);
                if i > 0 then
                    SetLength(aDllFileName, i - 1); // 'WinWord.exe' with full path
                if GetFileVersion(aDllFileName) < Office2003Version then
                    aDllFileName := ''
                else
                begin // no GDI+ 1.1 available in oldest Office
                    aDllFileName := ExtractFilePath(aDllFileName) + 'gdiplus.dll';
                    if not FileExists(aDllFileName) then
                        aDllFileName := '';
                end;
            end;
        end;
    end;
    if aDllFileName = '' then
        aDllFileName := 'gdiplus.dll'; // load default OS version
    fHandle := Load(aDllFileName, @@Startup, @GdiPProcNames);
    if fHandle <> 0 then
        if not ProcLoad(fHandle, @@DrawLine, @GdiPFullProcNames) then
            UnLoad
        else
            inherited Create(aDllFileName);
end;

function ColorRefToARGB(rgb: COLORREF): Cardinal;
{$IFDEF PUREPASCAL}
begin
    if Integer(rgb) < 0 then
        rgb := GetSysColor(rgb and $FF);
    //  result := TCOLORREF(rgb).B+TCOLORREF(rgb).G shl 8+TCOLORREF(rgb).R shl 16+$FF000000;
    result := (rgb shr 16) or (rgb and $FF00) or (rgb and $FF) shl 16 or $FF000000;
end;
{$ELSE}
asm
    test eax,eax
    jnl @n
    and eax,$ff
    push eax
    call GetSysColor
@n: bswap eax
    mov al,$ff
    ror eax,8
end;
{$ENDIF}

procedure Points16To32(PW: PWordArray; var PI: PIntegerArray; n: Integer);
var
    i: Integer;
begin
    Getmem(PI, n * 8);
    for i := 0 to n * 2 - 1 do
        PI^[i] := PW^[i];
end;

{ TGDIPlusEnum }

type
    /// expected font specifications
    TFontSpec = packed record
        angle: smallint; // -360..+360
        ascent, descent: Word;
        underline: boolean;
        strikeout: boolean;
    end;

    /// one DC state properties
    TGDIPlusEnumState = object
        pen, Brush, font: THandle;
        move: TPoint;
        WinSize, ViewSize: TSize;
        WinOrg, ViewOrg: TPoint;
        fontColor, fontAlign: Integer;
        fontSpec: TFontSpec;
        BkMode, BkColor: Cardinal;
    end;

    /// internal data used by EnumEMFFunc() callback function
    TGDIPlusEnum = object
        Gdip: TGDIPlusFull;
        Graphics: THandle;
        //metafile: integer;
        destDC: hdc;
        destMatrix: THandle;
        // contains the GDI+ objects, corresponding to the GDI32 THandleTable
        obj: array of packed record
            // GDI+ handle
            Handle: THandle;
            // either OBJ_PEN, OBJ_FONT or OBJ_BRUSH
            kind: Integer;
        end;
        // caching pens could make drawing somewhat faster
        CachedPen: array of packed record
            color: Cardinal;
            Width: Cardinal;
            Handle: THandle;
        end;
        // caching brushes could make drawing somewhat faster
        CachedBrush: array of packed record
            color: Cardinal;
            Handle: THandle;
        end;
        // caching fonts could make drawing somewhat faster
        CachedFont: array of packed record
            Handle: THandle;
            objfont: TFontSpec;
            logfont: TLogFontW;
        end;
        // the DC states, as stored by SaveDC / RestoreDC methods
        nDC: Integer;
        DC: array[0..10] of TGDIPlusEnumState;
        procedure SaveDC;
        procedure RestoreDC;
        procedure ScaleMatrix(matrixOrg: THandle);
        procedure CreatePenObj(index: Integer; color, Width, Style: Cardinal);
        procedure DeleteObj(index: Integer);
        procedure EnumerateEnd;
        function GetCachedPen(color, Width: Cardinal): THandle;
        function GetCachedSolidBrush(color: Cardinal): THandle;
        function GetCachedFontIndex(aLogFont: PLOGFONTW): Integer;
        procedure SetCachedFontSpec(aHandle: THandle; var aObjFont: TFontSpec);
        /// helper function do draw directly a bitmap from *s to *d
        procedure DrawBitmap(xs, ys, ws, hs, xd, yd, wd, hd: Integer; bmi, bits: Pointer);
    end;

const
    GdipRectFNull: TGdipRectF = (X: 0; Y: 0; Width: 0; Height: 0);

function DXTextWidth(dx: PIntegerArray; n: Integer): Integer;
var
    i: Integer;
begin
    result := 0;
    for i := 0 to n - 1 do
        inc(result, dx^[i]);
end;

procedure SetPositions(X, Y: Single; D: PGdipPointFArray; dx: PIntegerArray; n: Integer);
var
    i: Integer;
begin
    for i := 0 to n - 1 do
    begin
        D^[i].X := X;
        D^[i].Y := Y;
        X := X + dx^[i];
    end;
end;

procedure NormalizeRect(var Rect: TRect);
var
    tmp: Integer;
begin // GDI+ can't draw twisted rects -> normalize such values
    if Rect.Right < Rect.Left then
    begin
        tmp := Rect.Left;
        Rect.Left := Rect.Right;
        Rect.Right := tmp;
    end;
    if Rect.Bottom < Rect.Top then
    begin
        tmp := Rect.Top;
        Rect.Top := Rect.Bottom;
        Rect.Bottom := tmp;
    end;
end;

// var tempWC: PWideChar; // for debug

/// EMF enumeration callback function, called from GDI
// - draw most content with GDI+ functions

function EnumEMFFunc(DC: hdc; var Table: THandleTable; Rec: PEnhMetaRecord;
    NumObjects: DWORD; var Ref: TGDIPlusEnum): LongBool; stdcall;
var
    X: TXForm;
    P: TPoint;
    matrix, matrixOrg, path: THandle;
    P32: PIntegerArray;
    F32: PGdipPointFArray;
    RF: TGdipRectF;
    aDC: hdc;
    i, flags: Integer;
    Siz: TSize;
begin
    result := true;
    with Ref.DC[Ref.nDC] do
        case Rec^.iType of
            EMR_HEADER:
                begin
                    if Pointer(Ref.obj) = nil then
                        SetLength(Ref.obj, PEnhMetaHeader(Rec)^.nHandles);
                    GetWorldTransform(Ref.destDC, X);
                    Ref.Gdip.CreateMatrix2(X.eM11, X.eM12, X.eM21, X.eM22, X.eDx, X.eDy,
                        Ref.destMatrix);
                end;
            EMR_SAVEDC:
                Ref.SaveDC;
            EMR_RESTOREDC:
                Ref.RestoreDC;
            EMR_SETWINDOWEXTEX:
                WinSize := PEMRSetWindowExtEx(Rec)^.szlExtent;
            EMR_SETWINDOWORGEX:
                WinOrg := PEMRSetWindowOrgEx(Rec)^.ptlOrigin;
            EMR_SETVIEWPORTEXTEX:
                ViewSize := PEMRSetViewPortExtEx(Rec)^.szlExtent;
            EMR_SETVIEWPORTORGEX:
                ViewOrg := PEMRSetViewPortOrgEx(Rec)^.ptlOrigin;
            EMR_SETBKMODE:
                BkMode := PEMRSetBkMode(Rec)^.iMode;
            EMR_SETBKCOLOR:
                BkColor := PEMRSetBkColor(Rec)^.crColor;
            EMR_SETWORLDTRANSFORM:
                begin
                    with PEMRSetWorldTransform(Rec)^.xform do
                        Ref.Gdip.CreateMatrix2(eM11, eM12, eM21, eM22, eDx, eDy, matrixOrg);
                    Ref.ScaleMatrix(matrixOrg);
                    Ref.Gdip.DeleteMatrix(matrixOrg);
                end;
            EMR_EXTCREATEFONTINDIRECTW:
                with PEMRExtCreateFontIndirect(Rec)^ do
                begin
                    Ref.DeleteObj(ihFont - 1);
                    with Ref.obj[ihFont - 1] do
                    begin
                        kind := OBJ_FONT;
                        with Ref.CachedFont[Ref.GetCachedFontIndex(@elfw.elfLogFont)] do
                        begin
                            font := Handle;
                            fontSpec := objfont;
                        end;
                        Handle := font;
                    end;
                end;
            EMR_CREATEPEN:
                with PEMRCreatePen(Rec)^ do
                begin
                    Ref.DeleteObj(ihPen - 1);
                    Ref.CreatePenObj(ihPen - 1, lopn.lopnColor, lopn.lopnWidth.X, lopn.lopnStyle);
                end;
            EMR_CREATEBRUSHINDIRECT:
                with PEMRCreateBrushIndirect(Rec)^ do
                begin
                    Ref.DeleteObj(ihBrush - 1);
                    with Ref.obj[ihBrush - 1] do
                    begin
                        kind := OBJ_BRUSH;
                        if lb.lbStyle = BS_NULL then
                            Brush := 0
                        else
                        begin
                            Handle := Ref.GetCachedSolidBrush(lb.lbColor);
                            Brush := Handle;
                        end;
                    end;
                end;
            EMR_DELETEOBJECT:
                Ref.DeleteObj(PEMRDeleteObject(Rec)^.ihObject - 1);
            EMR_SELECTOBJECT:
                if Integer(PEMRSelectObject(Rec)^.ihObject) < 0 then // stock object?
                    case PEMRSelectObject(Rec)^.ihObject and $7FFFFFFF of
                        NULL_BRUSH: Brush := 0;
                        NULL_PEN: pen := 0;
                    end
                else
                    with Ref.obj[PEMRSelectObject(Rec)^.ihObject - 1] do
                        case kind of
                            OBJ_PEN: pen := Handle;
                            OBJ_BRUSH: Brush := Handle;
                            OBJ_FONT:
                                begin
                                    font := Handle;
                                    Ref.SetCachedFontSpec(Handle, fontSpec);
                                end;
                        end;
            EMR_SETTEXTCOLOR:
                fontColor := PEMRSetTextColor(Rec)^.crColor;
            EMR_SETTEXTALIGN:
                fontAlign := PEMRSetTextAlign(Rec)^.iMode;
            EMR_EXTTEXTOUTW:
                begin
                    with PEMRExtTextOut(Rec)^ do
                    begin
                        // tempWC := PWideChar(cardinal(Rec)+emrtext.offString);
                        Getmem(F32, emrtext.nChars * sizeof(TGdipPointF));
                        if emrtext.offDx = 0 then
                        begin // if emf content is not correct -> best guess
                            Ref.Gdip.MeasureString(Ref.Graphics, PWideChar(Cardinal(Rec) +
                                emrtext.offString),
                                emrtext.nChars, font, @GdipRectFNull, 0, @RF, nil, nil);
                            Siz.cx := Trunc(RF.Width);
                            flags := 5; // RealizedAdvance is set -> F32 = 1st glyph position
                        end
                        else
                        begin
                            Siz.cx := DXTextWidth(Pointer(Cardinal(Rec) + emrtext.offDx),
                                emrtext.nChars);
                            flags := 1; // F32 is an array of every individual glyph position
                        end;
                        RF.X := emrtext.ptlReference.X;
                        if fontAlign and TA_CENTER = TA_CENTER then
                            RF.X := RF.X - Siz.cx / 2
                        else if fontAlign and TA_RIGHT <> 0 then
                            RF.X := RF.X - Siz.cx;
                        if fontAlign and TA_BASELINE <> 0 then
                            RF.Y := emrtext.ptlReference.Y
                        else if fontAlign and TA_BOTTOM <> 0 then
                            RF.Y := emrtext.ptlReference.Y - fontSpec.descent
                        else
                            RF.Y := emrtext.ptlReference.Y + fontSpec.ascent;
                        if emrtext.offDx = 0 then
                            PGdipPointF(F32)^ := PGdipPointF(@RF)^
                        else
                            SetPositions(RF.X, RF.Y, F32, Pointer(Cardinal(Rec) + emrtext.offDx),
                                emrtext.nChars);
                        if fontSpec.angle <> 0 then
                        begin // manual rotate text -> GDI+ does not work :(
                            Ref.Gdip.CreateMatrix(matrixOrg);
                            Ref.Gdip.GetWorldTransform(Ref.Graphics, matrixOrg);
                            Ref.Gdip.TranslateTransform(Ref.Graphics,
                                emrtext.ptlReference.X, emrtext.ptlReference.Y);
                            Ref.Gdip.RotateTransform(Ref.Graphics, -fontSpec.angle);
                            Ref.Gdip.TranslateTransform(Ref.Graphics,
                                -emrtext.ptlReference.X, -emrtext.ptlReference.Y);
                        end;
                        if (emrtext.fOptions and ETO_OPAQUE <> 0) then
                        begin
                            // don't handle BkMode, since global to the page, but only specific text
                            NormalizeRect(rclBounds);
                            Ref.Gdip.FillRectangle(Ref.Graphics, Ref.GetCachedSolidBrush(BkColor),
                                rclBounds.Left, rclBounds.Top,
                                rclBounds.Right - rclBounds.Left, rclBounds.Bottom - rclBounds.Top);
                        end;
                        Ref.Gdip.DrawDriverString(Ref.Graphics, PWideChar(Cardinal(Rec) +
                            emrtext.offString),
                            emrtext.nChars, font, Ref.GetCachedSolidBrush(fontColor), F32, flags,
                                0);
                        if fontSpec.angle <> 0 then
                        begin
                            Ref.Gdip.SetWorldTransform(Ref.Graphics, matrixOrg); // restore previous
                            Ref.Gdip.DeleteMatrix(matrixOrg);
                        end
                        else
                            {// DrawDriverString doesn't handle those -> GDI+ does not work :(} if
                                fontSpec.underline or fontSpec.strikeout then
                            begin
                                Siz.cy := fontSpec.ascent shr 4;
                                if Siz.cy < 1 then
                                    Siz.cy := 1;
                                P.X := Trunc(RF.X);
                                P.Y := Trunc(RF.Y);
                                if fontSpec.strikeout then
                                    dec(P.Y, (fontSpec.ascent * 6) shr 4)
                                else
                                    inc(P.Y, Siz.cy);
                                if Siz.cy < 4 then
                                    Siz.cy := 1
                                else
                                    Siz.cy := Siz.cy shr 1;
                                Ref.Gdip.DrawLine(Ref.Graphics, Ref.GetCachedPen(fontColor, Siz.cy),
                                    P.X, P.Y, P.X + Siz.cx - 1, P.Y);
                            end;
                        Freemem(F32);
                    end;
                end;
            EMR_MOVETOEX:
                move := PEMRMoveToEx(Rec)^.ptl;
            EMR_LINETO:
                begin
                    with PEMRLineTo(Rec)^.ptl do
                        Ref.Gdip.DrawLine(Ref.Graphics, pen, move.X, move.Y, X, Y);
                    move := PEMRLineTo(Rec)^.ptl;
                end;
            EMR_RECTANGLE:
                begin
                    NormalizeRect(PEMRRectangle(Rec)^.rclBox);
                    if Brush <> 0 then
                        with PEMRRectangle(Rec)^.rclBox do
                            Ref.Gdip.FillRectangle(Ref.Graphics, Brush, Left, Top, Right - Left,
                                Bottom - Top);
                    with PEMRRectangle(Rec)^.rclBox do
                        Ref.Gdip.DrawRectangle(Ref.Graphics, pen, Left, Top, Right - Left, Bottom -
                            Top);
                end;
            EMR_ROUNDRECT: // perform RoundRect by hand -> just say: GDI+ does not work!
                with PEMRRoundRect(Rec)^ do
                begin
                    NormalizeRect(rclBox);
                    P.X := szlCorner.cx shr 1;
                    P.Y := szlCorner.cy shr 1;
                    Siz.cx := rclBox.Right - szlCorner.cx;
                    Siz.cy := rclBox.Bottom - szlCorner.cy;
                    Ref.Gdip.CreatePath(fmAlternate, path);
                    Ref.Gdip.AddPathLine(path, rclBox.Left + P.X, rclBox.Top, rclBox.Right - P.X,
                        rclBox.Top);
                    Ref.Gdip.AddPathArc(path, Siz.cx, rclBox.Top, szlCorner.cx, szlCorner.cy, 270,
                        90);
                    Ref.Gdip.AddPathLine(path, rclBox.Right, rclBox.Top + P.Y, rclBox.Right,
                        rclBox.Bottom - P.Y);
                    Ref.Gdip.AddPathArc(path, Siz.cx, Siz.cy, szlCorner.cx, szlCorner.cy, 0, 90);
                    Ref.Gdip.AddPathLine(path, rclBox.Right - P.X, rclBox.Bottom, rclBox.Left + P.X,
                        rclBox.Bottom);
                    Ref.Gdip.AddPathArc(path, rclBox.Left, Siz.cy, szlCorner.cx, szlCorner.cy, 90,
                        90);
                    Ref.Gdip.AddPathLine(path, rclBox.Left, rclBox.Bottom - P.Y, rclBox.Left,
                        rclBox.Top + P.Y);
                    Ref.Gdip.AddPathArc(path, rclBox.Left, rclBox.Top, szlCorner.cx, szlCorner.cy,
                        180, 90);
                    if Brush <> 0 then
                        Ref.Gdip.FillPath(Ref.Graphics, Brush, path);
                    if pen <> 0 then
                        Ref.Gdip.DrawPath(Ref.Graphics, pen, path);
                    Ref.Gdip.DeletePath(path);
                end;
            EMR_ELLIPSE:
                begin
                    NormalizeRect(PEMREllipse(Rec)^.rclBox);
                    if Brush <> 0 then
                        with PEMREllipse(Rec)^.rclBox do
                            Ref.Gdip.FillEllipse(Ref.Graphics, Brush, Left, Top, Right - Left, Bottom
                                - Top);
                    with PEMREllipse(Rec)^.rclBox do
                        Ref.Gdip.DrawEllipse(Ref.Graphics, pen, Left, Top, Right - Left, Bottom -
                            Top);
                end;
            EMR_POLYGON:
                with PEMRPolygon(Rec)^ do
                begin
                    if Brush <> 0 then
                        Ref.Gdip.FillPolygon(Ref.Graphics, Brush, @aptl, cptl, fmAlternate);
                    if pen <> 0 then
                        Ref.Gdip.DrawPolygon(Ref.Graphics, pen, @aptl, cptl);
                end;
            EMR_POLYGON16:
                with PEMRPolygon16(Rec)^ do
                begin
                    Points16To32(@apts, P32, cpts);
                    if Brush <> 0 then
                        Ref.Gdip.FillPolygon(Ref.Graphics, Brush, P32, cpts, fmAlternate);
                    if pen <> 0 then
                        Ref.Gdip.DrawPolygon(Ref.Graphics, pen, P32, cpts);
                    Freemem(P32);
                end;
            EMR_POLYLINE:
                with PEMRPolyLine(Rec)^ do
                begin
                    Ref.Gdip.DrawLines(Ref.Graphics, pen, @aptl, cptl);
                    move := aptl[cptl - 1];
                end;
            EMR_POLYLINE16:
                with PEMRPolyLine16(Rec)^ do
                begin
                    Points16To32(@apts, P32, cpts);
                    Ref.Gdip.DrawLines(Ref.Graphics, pen, P32, cpts);
                    move := PPoint(Cardinal(P32) + (cpts - 1) * 8)^;
                    Freemem(P32);
                end;
            EMR_POLYBEZIER:
                with PEMRPolyBezier(Rec)^ do
                begin
                    Ref.Gdip.DrawCurve(Ref.Graphics, pen, @aptl, cptl);
                    move := aptl[cptl - 1];
                end;
            EMR_POLYBEZIER16:
                with PEMRPolyBezier16(Rec)^ do
                begin
                    Points16To32(@apts, P32, cpts);
                    Ref.Gdip.DrawCurve(Ref.Graphics, pen, P32, cpts);
                    move := PPoint(Cardinal(P32) + (cpts - 1) * 8)^;
                    Freemem(P32);
                end;
            EMR_BITBLT:
                begin
                    NormalizeRect(PEMRBitBlt(Rec)^.rclBounds);
                    with PEMRBitBlt(Rec)^ do // only handle RGB bitmaps (no palette)
                        if (offBmiSrc <> 0) and (offBitsSrc <> 0) and (iUsageSrc = DIB_RGB_COLORS)
                            then
                            Ref.DrawBitmap(xSrc, ySrc, cxDest, cyDest, xDest, yDest, cxDest, cyDest,
                                Pointer(Cardinal(Rec) + offBmiSrc), Pointer(Cardinal(Rec) +
                                    offBitsSrc))
                        else
                            case PEMRBitBlt(Rec)^.dwRop of // we only handle PATCOPY = fillrect
                                PATCOPY: with PEMRBitBlt(Rec)^.rclBounds do
                                        Ref.Gdip.FillRectangle(Ref.Graphics, Brush, Left, Top, Right
                                            - Left, Bottom - Top);
                            end;
                end;
            EMR_STRETCHBLT:
                begin
                    NormalizeRect(PEMRStretchBlt(Rec)^.rclBounds);
                    with PEMRStretchBlt(Rec)^ do // only handle RGB bitmaps (no palette)
                        if (offBmiSrc <> 0) and (offBitsSrc <> 0) and (iUsageSrc = DIB_RGB_COLORS)
                            then
                            Ref.DrawBitmap(xSrc, ySrc, cxSrc, cySrc, xDest, yDest, cxDest, cyDest,
                                Pointer(Cardinal(Rec) + offBmiSrc), Pointer(Cardinal(Rec) +
                                    offBitsSrc))
                        else
                            case PEMRStretchBlt(Rec)^.dwRop of // we only handle PATCOPY = fillrect
                                PATCOPY: with PEMRStretchBlt(Rec)^.rclBounds do
                                        Ref.Gdip.FillRectangle(Ref.Graphics, Brush, Left, Top, Right
                                            - Left, Bottom - Top);
                            end;
                end;
            EMR_STRETCHDIBITS:
                begin
                    NormalizeRect(PEMRStretchDIBits(Rec)^.rclBounds);
                    with PEMRStretchDIBits(Rec)^ do
                        if (offBmiSrc <> 0) and (offBitsSrc <> 0) and (iUsageSrc = DIB_RGB_COLORS)
                            then
                            Ref.DrawBitmap(xSrc, ySrc, cxSrc, cySrc, xDest, yDest, cxDest, cyDest,
                                Pointer(Cardinal(Rec) + offBmiSrc), Pointer(Cardinal(Rec) +
                                    offBitsSrc));
                end;
        end;
    case Rec^.iType of
        EMR_HEADER, EMR_SETWINDOWEXTEX, EMR_SETWINDOWORGEX,
            EMR_SETVIEWPORTEXTEX, EMR_SETVIEWPORTORGEX:
            Ref.ScaleMatrix(0);
    end;
end;

procedure TGDIPlusFull.DrawAntiAliased(Source: TMetafile; Dest: hdc;
    R: TRect; aSmoothing: TSmoothingMode; aTextRendering: TTextRenderingHint);
var
    Img, Graphics: THandle;
begin
    Img := ConvertToEmfPlus(Source, Dest, aSmoothing, aTextRendering);
    if Img = 0 then
        inherited
    else
    try
        CreateFromHDC(Dest, Graphics);
        DrawImageRect(Graphics, Img, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    finally
        DeleteGraphics(Graphics);
        DisposeImage(Img);
    end;
end;

function TGDIPlusFull.MetaFileToStream(Source: TMetafile; out hGlobal: THandle): IStream;
var
    length: Cardinal;
begin
    length := GetEnhMetaFileBits(Source.Handle, 0, nil);
    hGlobal := GlobalAlloc(GMEM_MOVEABLE, length + 128);
    if GetEnhMetaFileBits(Source.Handle, length, GlobalLock(hGlobal)) <> length then
        assert(false);
    GlobalUnlock(hGlobal);
    CreateStreamOnHGlobal(hGlobal, true, result);
end;

function TGDIPlusFull.ConvertToEmfPlus(Source: TMetafile; Dest: hdc;
    aSmoothing: TSmoothingMode; aTextRendering: TTextRenderingHint): THandle;
var
    Ref: TGDIPlusEnum;
    flag: BOOL;
    EmfPlusImg: Integer;
    hGlobal: THandle;
    pstm: IStream;
    Img: TSynPicture;
    GR: TGdipRect;
begin
    result := 0;
    if not Exists or (Source = nil) or (Dest = 0) then
        exit;
    GR.X := 0;
    GR.Y := 0;
    GR.Width := Source.Width;
    GR.Height := Source.Height;
    fillchar(Ref, sizeof(Ref), 0);
    // 使用内部转换，用GDI+ 1.1转换Metafile为Emf+格式
    if NativeConvertToEmfPlus then
    begin
        // let GDI+ 1.1 make the conversion
        pstm := MetaFileToStream(Source, hGlobal);
        try
            Img := TSynPicture.Create;
            try
                if Img.LoadFromIStream(pstm) <> stOk then
                    exit;
                flag := false;
                CreateFromHDC(Dest, Ref.Graphics);
                SetSmoothingMode(Ref.Graphics, aSmoothing);
                SetTextRenderingHint(Ref.Graphics, aTextRendering);
                try
                    {fConvertToEmfPlus貌似就是GDI+ 1.1中隐含的函数，用它可以转换为Emf+格式}
                    if fConvertToEmfPlus(Ref.Graphics, Img.NativeImage, flag,
                        etEmfPlusOnly, nil, EmfPlusImg) = stOk then
                        result := EmfPlusImg;
                finally
                    DeleteGraphics(Ref.Graphics);
                end;
            finally
                Img.Free;
            end;
        finally
            pstm := nil;
            GlobalFree(hGlobal);
        end;
    end
    else
    begin
        // our manual (and not 100% complete yet) conversion
        with Ref.DC[0] do
        begin
            Int64(WinSize) := PInt64(@GR.Width)^;
            ViewSize := WinSize;
        end;
        Ref.Gdip := self;
        Ref.destDC := CreateCompatibleDC(Dest);
        RecordMetafile(Ref.destDC, etEmfPlusOnly, @GR, uPixel, nil, result);
        CreateFromImage(result, Ref.Graphics);
        SetSmoothingMode(Ref.Graphics, aSmoothing);
        SetTextRenderingHint(Ref.Graphics, aTextRendering);
        try
            EnumEnhMetaFile(Ref.destDC, Source.Handle, @EnumEMFFunc, @Ref, TRect(GR));
        finally
            Ref.EnumerateEnd;
        end;
    end;
end;

function TGDIPlusFull.getNativeConvertToEmfPlus: boolean;
begin
    if (self = nil) or ForceInternalConvertToEmfPlus then
        result := false
    else
    begin
        if not fConvertToEmfPlusTested then
        begin
            fConvertToEmfPlusTested := true;
            fConvertToEmfPlus := GetProcAddress(fHandle, 'GdipConvertToEmfPlus');
        end;
        result := (@fConvertToEmfPlus <> nil);
    end;
end;

{ TGDIPlusEnum }

procedure TGDIPlusEnum.CreatePenObj(index: Integer; color, Width, Style: Cardinal);
begin
    if Cardinal(index) <= Cardinal(high(obj)) then
        with obj[index] do
        begin
            kind := OBJ_PEN;
            Gdip.CreatePen(ColorRefToARGB(color), Width, uWorld, Handle);
            if Style in [PS_DASH..PS_DASHDOTDOT] then
                Gdip.SetPenDashStyle(Handle, PS_DASH); // force PS_DASH on GDI+
            DC[nDC].pen := Handle;
        end;
end;

procedure TGDIPlusEnum.DeleteObj(index: Integer);
begin
    if Cardinal(index) <= Cardinal(high(obj)) then
        with obj[index] do
        begin
            if Handle <> 0 then
                case kind of
                    OBJ_EXTPEN, OBJ_PEN:
                        begin
                            Gdip.DeletePen(Handle);
                            with DC[nDC] do
                                if pen = Handle then
                                    pen := 0;
                        end;
                    OBJ_BRUSH, OBJ_FONT:
                        ; // brushs and font are taken from Cached*[] -> deleted in EnumerateEnd
                else
                    exit;
                end;
            Handle := 0;
            kind := 0;
        end;
end;

procedure TGDIPlusEnum.DrawBitmap(xs, ys, ws, hs, xd, yd, wd, hd: Integer;
    bmi, bits: Pointer);
var
    Img: THandle;
begin
    if not Gdip.Exists or (Graphics = 0) then
        exit;
    if Gdip.CreateBitmapFromGdiDib(bmi, bits, Img) = stOk then
    try
        Gdip.DrawImageRectRect(Graphics, Img, xd, yd, wd, hd, xs, ys, ws, hs);
    finally
        Gdip.DisposeImage(Img);
    end;
end;

procedure TGDIPlusEnum.EnumerateEnd;
var
    i: Integer;
begin
    for i := 0 to high(obj) do
        DeleteObj(i);
    for i := 0 to high(CachedPen) do
        Gdip.DeletePen(CachedPen[i].Handle);
    for i := 0 to high(CachedBrush) do
        Gdip.DeleteBrush(CachedBrush[i].Handle);
    for i := 0 to high(CachedFont) do
        Gdip.DeleteFont(CachedFont[i].Handle);
    Gdip.DeleteMatrix(destMatrix);
    Finalize(obj);
    DeleteDC(destDC);
    Gdip.DeleteGraphics(Graphics);
end;

function AnsiICompW(u1, u2: PWideChar): Integer;
var
    c1, c2: Integer;
begin // faster than lstrcmpiW
    repeat
        c1 := Integer(u1^);
        c2 := Integer(u2^);
        result := c1 - c2;
        if result <> 0 then
        begin
            if (c1 > 255) or (c2 > 255) then
                exit;
            if c1 in [ord('a')..ord('z')] then
                dec(c1, 32);
            if c2 in [ord('a')..ord('z')] then
                dec(c2, 32);
            result := c1 - c2;
            if result <> 0 then
                exit;
        end;
        if (c1 = 0) or (c2 = 0) then
            break;
        inc(u1);
        inc(u2);
    until false;
end;

function TGDIPlusEnum.GetCachedFontIndex(aLogFont: PLOGFONTW): Integer;
var
    HF: HFONT;
    TM: TTextMetric;
    Old: HGDIOBJ;
    LF: TLogFontW;
    n: Integer;
begin
    // DrawDriverString error with underline or strikeout -> GDI+ does not work :(
    move(aLogFont^, LF, sizeof(LF)); // faster than LF := LogFont
    LF.lfUnderline := 0;
    LF.lfStrikeOut := 0;
    // search if not already in cache
    n := length(CachedFont);
    for result := 0 to n - 1 do
        with CachedFont[result] do
            if CompareMem(@logfont, @LF, sizeof(TLogFontW) - LF_FACESIZE) and
                (AnsiICompW(logfont.lfFaceName, LF.lfFaceName) = 0) and
                (objfont.underline = boolean(aLogFont^.lfUnderline)) and
                (objfont.strikeout = boolean(aLogFont^.lfStrikeOut)) then
                exit;
    // not available in cache -> create now
    result := n;
    SetLength(CachedFont, result + 1);
    with CachedFont[result] do
    begin
        logfont := LF;
        Gdip.CreateFontFromLogfont(destDC, @logfont, Handle);
        HF := CreateFontIndirectW(logfont);
        Old := SelectObject(destDC, HF);
        GetTextMetrics(destDC, TM);
        SelectObject(destDC, Old);
        DeleteObject(HF);
        objfont.ascent := TM.tmAscent;
        objfont.descent := TM.tmDescent;
        objfont.angle := logfont.lfOrientation div 10;
        objfont.underline := boolean(aLogFont^.lfUnderline);
        objfont.strikeout := boolean(aLogFont^.lfStrikeOut);
    end;
end;

function TGDIPlusEnum.GetCachedPen(color, Width: Cardinal): THandle;
var
    i, n: Integer;
begin
    for i := 0 to high(CachedPen) do
        if (CachedPen[i].color = color) and (CachedPen[i].Width = Width) then
        begin
            result := CachedPen[i].Handle;
            exit;
        end;
    Gdip.CreatePen(ColorRefToARGB(color), Width, uPixel, result);
    n := length(CachedPen);
    SetLength(CachedPen, n + 1);
    CachedPen[n].color := color;
    CachedPen[n].Width := Width;
    CachedPen[n].Handle := result;
end;

function TGDIPlusEnum.GetCachedSolidBrush(color: Cardinal): THandle;
var
    i, n: Integer;
begin
    for i := 0 to high(CachedBrush) do
        if CachedBrush[i].color = color then
        begin
            result := CachedBrush[i].Handle;
            exit;
        end;
    Gdip.CreateSolidFill(ColorRefToARGB(color), result);
    n := length(CachedBrush);
    SetLength(CachedBrush, n + 1);
    CachedBrush[n].color := color;
    CachedBrush[n].Handle := result;
end;

procedure TGDIPlusEnum.RestoreDC;
begin
    assert(nDC > 0);
    dec(nDC);
    ScaleMatrix(0);
    //  with DC[nDC] do
    //    Gdip.SetWorldTransform(Graphics,destMatrix);
end;

procedure TGDIPlusEnum.SaveDC;
begin
    assert(nDC < high(DC));
    DC[nDC + 1] := DC[nDC];
    inc(nDC);
end;

procedure TGDIPlusEnum.ScaleMatrix(matrixOrg: THandle);
var
    P: TPoint;
    matrix: THandle;
begin
    with DC[nDC] do
    begin
        P.X := MulDiv(ViewOrg.X, WinSize.cx, ViewSize.cx) - WinOrg.X;
        P.Y := MulDiv(ViewOrg.Y, WinSize.cy, ViewSize.cy) - WinOrg.Y;
        Gdip.CreateMatrix2(ViewSize.cx / WinSize.cx, 0, 0, ViewSize.cy / WinSize.cy,
            P.X, P.Y, matrix);
        Gdip.MultiplyMatrix(matrix, destMatrix);
        if matrixOrg <> 0 then
            Gdip.MultiplyMatrix(matrix, matrixOrg);
        Gdip.SetWorldTransform(Graphics, matrix);
        Gdip.DeleteMatrix(matrix);
    end;
end;

procedure TGDIPlusEnum.SetCachedFontSpec(aHandle: THandle; var aObjFont: TFontSpec);
var
    i: Integer;
begin
    for i := 0 to high(CachedFont) do
        if CachedFont[i].Handle = aHandle then
        begin
            aObjFont := CachedFont[i].objfont;
            exit;
        end;
    Int64(aObjFont) := 0;
end;

initialization
    Gdip := TGDIPlusFull.Create('gdiplus.dll');
{$IFNDEF NOTSYNPICTUREREGISTER}
    Gdip.RegisterPictures; // will initialize the Gdip library if necessary
    //  GdipTest('d:\Data\Pictures\Sample Pictures\Tree.jpg');
{$ENDIF}

finalization
    Gdip.Free;
end.

