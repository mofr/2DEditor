unit DirectDrawFPC;

{$I SWITCHES.INC}

interface

uses
	windows, DirectDraw, ole2;


// IDirectDraw interface methods

function IDirectDraw_QueryInterface(idd : IDirectDraw; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDraw_AddRef(idd : IDirectDraw) : Longint; stdcall;
function IDirectDraw_Release(idd : IDirectDraw) : Longint; stdcall;
function IDirectDraw_Compact(idd : IDirectDraw) : HResult; stdcall;
function IDirectDraw_CreateClipper(idd : IDirectDraw; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw_CreatePalette(idd : IDirectDraw; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw_CreateSurface(idd : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc; var lplpDDSurface : IDirectDrawSurface; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw_DuplicateSurface(idd : IDirectDraw; lpDDSurface : IDirectDrawSurface; var lplpDupDDSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDraw_EnumDisplayModes(idd : IDirectDraw; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback) : HResult; stdcall;
function IDirectDraw_EnumSurfaces(idd : IDirectDraw; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDraw_FlipToGDISurface(idd : IDirectDraw) : HResult; stdcall;
function IDirectDraw_GetCaps(idd : IDirectDraw; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
function IDirectDraw_GetDisplayMode(idd : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDraw_GetFourCCCodes(idd : IDirectDraw; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
function IDirectDraw_GetGDISurface(idd : IDirectDraw; var lplpGDIDDSSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDraw_GetMonitorFrequency(idd : IDirectDraw; var lpdwFrequency : DWORD) : HResult; stdcall;
function IDirectDraw_GetScanLine(idd : IDirectDraw; var lpdwScanLine : DWORD) : HResult; stdcall;
function IDirectDraw_GetVerticalBlankStatus(idd : IDirectDraw; var lpbIsInVB : BOOL) : HResult; stdcall;
function IDirectDraw_Initialize(idd : IDirectDraw; lpGUID : PGUID) : HResult; stdcall;
function IDirectDraw_RestoreDisplayMode(idd : IDirectDraw) : HResult; stdcall;
function IDirectDraw_SetCooperativeLevel(idd : IDirectDraw; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw_SetDisplayMode(idd : IDirectDraw; dwWidth : DWORD; dwHeight : DWORD; dwBpp : DWORD) : HResult; stdcall;
function IDirectDraw_WaitForVerticalBlank(idd : IDirectDraw; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;

// IDirectDraw2 interface methods

function IDirectDraw2_QueryInterface(idd : IDirectDraw2; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDraw2_AddRef(idd : IDirectDraw2) : Longint; stdcall;
function IDirectDraw2_Release(idd : IDirectDraw2) : Longint; stdcall;
function IDirectDraw2_Compact(idd : IDirectDraw2) : HResult; stdcall;
function IDirectDraw2_CreateClipper(idd : IDirectDraw2; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw2_CreatePalette(idd : IDirectDraw2; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw2_CreateSurface(idd : IDirectDraw2; var lpDDSurfaceDesc : TDDSurfaceDesc; var lplpDDSurface : IDirectDrawSurface; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw2_DuplicateSurface(idd : IDirectDraw2; lpDDSurface : IDirectDrawSurface; var lplpDupDDSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDraw2_EnumDisplayModes(idd : IDirectDraw2; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback) : HResult; stdcall;
function IDirectDraw2_EnumSurfaces(idd : IDirectDraw2; dwFlags : DWORD; var lpDDSD : TDDSurfaceDesc; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDraw2_FlipToGDISurface(idd : IDirectDraw2) : HResult; stdcall;
function IDirectDraw2_GetCaps(idd : IDirectDraw2; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
function IDirectDraw2_GetDisplayMode(idd : IDirectDraw2; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDraw2_GetFourCCCodes(idd : IDirectDraw2; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
function IDirectDraw2_GetGDISurface(idd : IDirectDraw2; var lplpGDIDDSSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDraw2_GetMonitorFrequency(idd : IDirectDraw2; var lpdwFrequency : DWORD) : HResult; stdcall;
function IDirectDraw2_GetScanLine(idd : IDirectDraw2; var lpdwScanLine : DWORD) : HResult; stdcall;
function IDirectDraw2_GetVerticalBlankStatus(idd : IDirectDraw2; var lpbIsInVB : BOOL) : HResult; stdcall;
function IDirectDraw2_Initialize(idd : IDirectDraw2; lpGUID : PGUID) : HResult; stdcall;
function IDirectDraw2_RestoreDisplayMode(idd : IDirectDraw2) : HResult; stdcall;
function IDirectDraw2_SetCooperativeLevel(idd : IDirectDraw2; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw2_SetDisplayMode(idd : IDirectDraw2; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw2_WaitForVerticalBlank(idd : IDirectDraw2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDraw2_GetAvailableVidMem(idd : IDirectDraw2; var lpDDSCaps : TDDSCaps; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;

// IDirectDraw4 interface methods

function IDirectDraw4_QueryInterface(idd : IDirectDraw4; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDraw4_AddRef(idd : IDirectDraw4) : Longint; stdcall;
function IDirectDraw4_Release(idd : IDirectDraw4) : Longint; stdcall;
function IDirectDraw4_Compact(idd : IDirectDraw4) : HResult; stdcall;
function IDirectDraw4_CreateClipper(idd : IDirectDraw4; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw4_CreatePalette(idd : IDirectDraw4; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw4_CreateSurface(idd : IDirectDraw4; const lpDDSurfaceDesc : TDDSurfaceDesc2; var lplpDDSurface : IDirectDrawSurface4; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw4_DuplicateSurface(idd : IDirectDraw4; lpDDSurface : IDirectDrawSurface4; var lplpDupDDSurface : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDraw4_EnumDisplayModes(idd : IDirectDraw4; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc2; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback2) : HResult; stdcall;
function IDirectDraw4_EnumSurfaces(idd : IDirectDraw4; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc2; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
function IDirectDraw4_FlipToGDISurface(idd : IDirectDraw4) : HResult; stdcall;
function IDirectDraw4_GetCaps(idd : IDirectDraw4; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
function IDirectDraw4_GetDisplayMode(idd : IDirectDraw4; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDraw4_GetFourCCCodes(idd : IDirectDraw4; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
function IDirectDraw4_GetGDISurface(idd : IDirectDraw4; var lplpGDIDDSSurface : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDraw4_GetMonitorFrequency(idd : IDirectDraw4; var lpdwFrequency : DWORD) : HResult; stdcall;
function IDirectDraw4_GetScanLine(idd : IDirectDraw4; var lpdwScanLine : DWORD) : HResult; stdcall;
function IDirectDraw4_GetVerticalBlankStatus(idd : IDirectDraw4; var lpbIsInVB : BOOL) : HResult; stdcall;
function IDirectDraw4_Initialize(idd : IDirectDraw4; lpGUID : PGUID) : HResult; stdcall;
function IDirectDraw4_RestoreDisplayMode(idd : IDirectDraw4) : HResult; stdcall;
function IDirectDraw4_SetCooperativeLevel(idd : IDirectDraw4; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw4_SetDisplayMode(idd : IDirectDraw4; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw4_WaitForVerticalBlank(idd : IDirectDraw4; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDraw4_GetAvailableVidMem(idd : IDirectDraw4; const lpDDSCaps : TDDSCaps2; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;
function IDirectDraw4_GetSurfaceFromDC(idd : IDirectDraw4; hdc : Windows.HDC; var lpDDS4 : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDraw4_RestoreAllSurfaces(idd : IDirectDraw4) : HResult; stdcall;
function IDirectDraw4_TestCooperativeLevel(idd : IDirectDraw4) : HResult; stdcall;
function IDirectDraw4_GetDeviceIdentifier(idd : IDirectDraw4; var lpdddi : TDDDeviceIdentifier; dwFlags : DWORD) : HResult; stdcall;

// IDirectDraw7 interface methods

function IDirectDraw7_QueryInterface(idd : IDirectDraw7; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDraw7_AddRef(idd : IDirectDraw7) : Longint; stdcall;
function IDirectDraw7_Release(idd : IDirectDraw7) : Longint; stdcall;
function IDirectDraw7_Compact(idd : IDirectDraw7) : HResult; stdcall;
function IDirectDraw7_CreateClipper(idd : IDirectDraw7; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw7_CreatePalette(idd : IDirectDraw7; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw7_CreateSurface(idd : IDirectDraw7; const lpDDSurfaceDesc : TDDSurfaceDesc2; var lplpDDSurface : IDirectDrawSurface7; pUnkOuter : IUnknown) : HResult; stdcall;
function IDirectDraw7_DuplicateSurface(idd : IDirectDraw7; lpDDSurface : IDirectDrawSurface7; var lplpDupDDSurface : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDraw7_EnumDisplayModes(idd : IDirectDraw7; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc2; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback2) : HResult; stdcall;
function IDirectDraw7_EnumSurfaces(idd : IDirectDraw7; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc2; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
function IDirectDraw7_FlipToGDISurface(idd : IDirectDraw7) : HResult; stdcall;
function IDirectDraw7_GetCaps(idd : IDirectDraw7; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
function IDirectDraw7_GetDisplayMode(idd : IDirectDraw7; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDraw7_GetFourCCCodes(idd : IDirectDraw7; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
function IDirectDraw7_GetGDISurface(idd : IDirectDraw7; var lplpGDIDDSSurface : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDraw7_GetMonitorFrequency(idd : IDirectDraw7; var lpdwFrequency : DWORD) : HResult; stdcall;
function IDirectDraw7_GetScanLine(idd : IDirectDraw7; var lpdwScanLine : DWORD) : HResult; stdcall;
function IDirectDraw7_GetVerticalBlankStatus(idd : IDirectDraw7; var lpbIsInVB : BOOL) : HResult; stdcall;
function IDirectDraw7_Initialize(idd : IDirectDraw7; lpGUID : PGUID) : HResult; stdcall;
function IDirectDraw7_RestoreDisplayMode(idd : IDirectDraw7) : HResult; stdcall;
function IDirectDraw7_SetCooperativeLevel(idd : IDirectDraw7; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw7_SetDisplayMode(idd : IDirectDraw7; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw7_WaitForVerticalBlank(idd : IDirectDraw7; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDraw7_GetAvailableVidMem(idd : IDirectDraw7; const lpDDSCaps : TDDSCaps2; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;
function IDirectDraw7_GetSurfaceFromDC(idd : IDirectDraw7; hdc : Windows.HDC; var lpDDS : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDraw7_RestoreAllSurfaces(idd : IDirectDraw7) : HResult; stdcall;
function IDirectDraw7_TestCooperativeLevel(idd : IDirectDraw7) : HResult; stdcall;
function IDirectDraw7_GetDeviceIdentifier(idd : IDirectDraw7; var lpdddi : TDDDeviceIdentifier2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw7_StartModeTest(idd : IDirectDraw7; const lpModesToTest; dwNumEntries , dwFlags : DWORD) : HResult; stdcall;
function IDirectDraw7_EvaluateMode(idd : IDirectDraw7; dwFlags : DWORD; var pSecondsUntilTimeout : DWORD) : HResult; stdcall;

// IDirectDrawPalette interface methods

function IDirectDrawPalette_QueryInterface(idd : IDirectDrawPalette; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawPalette_AddRef(idd : IDirectDrawPalette) : Longint; stdcall;
function IDirectDrawPalette_Release(idd : IDirectDrawPalette) : Longint; stdcall;
function IDirectDrawPalette_GetCaps(idd : IDirectDrawPalette; var lpdwCaps : DWORD) : HResult; stdcall;
function IDirectDrawPalette_GetEntries(idd : IDirectDrawPalette; dwFlags : DWORD; dwBase : DWORD; dwNumEntries : DWORD; lpEntries : pointer) : HResult; stdcall;
function IDirectDrawPalette_Initialize(idd : IDirectDrawPalette; lpDD : IDirectDraw; dwFlags : DWORD; lpDDColorTable : pointer) : HResult; stdcall;
function IDirectDrawPalette_SetEntries(idd : IDirectDrawPalette; dwFlags : DWORD; dwStartingEntry : DWORD; dwCount : DWORD; lpEntries : pointer) : HResult; stdcall;

// IDirectDrawClipper interface methods

function IDirectDrawClipper_QueryInterface(idd : IDirectDrawClipper; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawClipper_AddRef(idd : IDirectDrawClipper) : Longint; stdcall;
function IDirectDrawClipper_Release(idd : IDirectDrawClipper) : Longint; stdcall;
function IDirectDrawClipper_GetClipList(idd : IDirectDrawClipper; lpRect : PRect; lpClipList : PRgnData; var lpdwSize : DWORD) : HResult; stdcall;
function IDirectDrawClipper_GetHWnd(idd : IDirectDrawClipper; var lphWnd : HWND) : HResult; stdcall;
function IDirectDrawClipper_Initialize(idd : IDirectDrawClipper; lpDD : IDirectDraw; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawClipper_IsClipListChanged(idd : IDirectDrawClipper; var lpbChanged : BOOL) : HResult; stdcall;
function IDirectDrawClipper_SetClipList(idd : IDirectDrawClipper; lpClipList : PRgnData; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawClipper_SetHWnd(idd : IDirectDrawClipper; dwFlags : DWORD; hWnd : HWND) : HResult; stdcall;

// IDirectDrawSurface interface methods

function IDirectDrawSurface_QueryInterface(idd : IDirectDrawSurface; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawSurface_AddRef(idd : IDirectDrawSurface) : Longint; stdcall;
function IDirectDrawSurface_Release(idd : IDirectDrawSurface) : Longint; stdcall;
function IDirectDrawSurface_AddAttachedSurface(idd : IDirectDrawSurface; lpDDSAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDrawSurface_AddOverlayDirtyRect(idd : IDirectDrawSurface; const lpRect : TRect) : HResult; stdcall;
function IDirectDrawSurface_Blt(idd : IDirectDrawSurface; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
function IDirectDrawSurface_BltBatch(idd : IDirectDrawSurface; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface_BltFast(idd : IDirectDrawSurface; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
function IDirectDrawSurface_DeleteAttachedSurface(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDrawSurface_EnumAttachedSurfaces(idd : IDirectDrawSurface; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface_EnumOverlayZOrders(idd : IDirectDrawSurface; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface_Flip(idd : IDirectDrawSurface; lpDDSurfaceTargetOverride : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface_GetAttachedSurface(idd : IDirectDrawSurface; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
function IDirectDrawSurface_GetBltStatus(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface_GetCaps(idd : IDirectDrawSurface; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
function IDirectDrawSurface_GetClipper(idd : IDirectDrawSurface; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface_GetColorKey(idd : IDirectDrawSurface; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
function IDirectDrawSurface_GetDC(idd : IDirectDrawSurface; var lphDC : HDC) : HResult; stdcall;
function IDirectDrawSurface_GetFlipStatus(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface_GetOverlayPosition(idd : IDirectDrawSurface; var lplX , lplY : LongInt) : HResult; stdcall;
function IDirectDrawSurface_GetPalette(idd : IDirectDrawSurface; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface_GetPixelFormat(idd : IDirectDrawSurface; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
function IDirectDrawSurface_GetSurfaceDesc(idd : IDirectDrawSurface; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface_Initialize(idd : IDirectDrawSurface; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface_IsLost(idd : IDirectDrawSurface) : HResult; stdcall;
function IDirectDrawSurface_Lock(idd : IDirectDrawSurface; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDrawSurface_ReleaseDC(idd : IDirectDrawSurface; hDC : Windows.HDC) : HResult; stdcall;
function IDirectDrawSurface__Restore(idd : IDirectDrawSurface) : HResult; stdcall;
function IDirectDrawSurface_SetClipper(idd : IDirectDrawSurface; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface_SetColorKey(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
function IDirectDrawSurface_SetOverlayPosition(idd : IDirectDrawSurface; lX , lY : LongInt) : HResult; stdcall;
function IDirectDrawSurface_SetPalette(idd : IDirectDrawSurface; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface_Unlock(idd : IDirectDrawSurface; lpSurfaceData : Pointer) : HResult; stdcall;
function IDirectDrawSurface_UpdateOverlay(idd : IDirectDrawSurface; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
function IDirectDrawSurface_UpdateOverlayDisplay(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface_UpdateOverlayZOrder(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface) : HResult; stdcall;

// IDirectDrawSurface2 interface methods

function IDirectDrawSurface2_QueryInterface(idd : IDirectDrawSurface2; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawSurface2_AddRef(idd : IDirectDrawSurface2) : Longint; stdcall;
function IDirectDrawSurface2_Release(idd : IDirectDrawSurface2) : Longint; stdcall;
function IDirectDrawSurface2_AddAttachedSurface(idd : IDirectDrawSurface2; lpDDSAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_AddOverlayDirtyRect(idd : IDirectDrawSurface2; const lpRect : TRect) : HResult; stdcall;
function IDirectDrawSurface2_Blt(idd : IDirectDrawSurface2; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface2; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
function IDirectDrawSurface2_BltBatch(idd : IDirectDrawSurface2; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_BltFast(idd : IDirectDrawSurface2; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface2; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_DeleteAttachedSurface(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_EnumAttachedSurfaces(idd : IDirectDrawSurface2; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface2_EnumOverlayZOrders(idd : IDirectDrawSurface2; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface2_Flip(idd : IDirectDrawSurface2; lpDDSurfaceTargetOverride : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_GetAttachedSurface(idd : IDirectDrawSurface2; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_GetBltStatus(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_GetCaps(idd : IDirectDrawSurface2; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
function IDirectDrawSurface2_GetClipper(idd : IDirectDrawSurface2; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface2_GetColorKey(idd : IDirectDrawSurface2; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
function IDirectDrawSurface2_GetDC(idd : IDirectDrawSurface2; var lphDC : HDC) : HResult; stdcall;
function IDirectDrawSurface2_GetFlipStatus(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_GetOverlayPosition(idd : IDirectDrawSurface2; var lplX , lplY : LongInt) : HResult; stdcall;
function IDirectDrawSurface2_GetPalette(idd : IDirectDrawSurface2; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface2_GetPixelFormat(idd : IDirectDrawSurface2; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
function IDirectDrawSurface2_GetSurfaceDesc(idd : IDirectDrawSurface2; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface2_Initialize(idd : IDirectDrawSurface2; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface2_IsLost(idd : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_Lock(idd : IDirectDrawSurface2; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDrawSurface2_ReleaseDC(idd : IDirectDrawSurface2; hDC : Windows.HDC) : HResult; stdcall;
function IDirectDrawSurface2__Restore(idd : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_SetClipper(idd : IDirectDrawSurface2; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface2_SetColorKey(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
function IDirectDrawSurface2_SetOverlayPosition(idd : IDirectDrawSurface2; lX , lY : LongInt) : HResult; stdcall;
function IDirectDrawSurface2_SetPalette(idd : IDirectDrawSurface2; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface2_Unlock(idd : IDirectDrawSurface2; lpSurfaceData : Pointer) : HResult; stdcall;
function IDirectDrawSurface2_UpdateOverlay(idd : IDirectDrawSurface2; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface2; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
function IDirectDrawSurface2_UpdateOverlayDisplay(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_UpdateOverlayZOrder(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface2) : HResult; stdcall;
function IDirectDrawSurface2_GetDDInterface(idd : IDirectDrawSurface2; var lplpDD : IDirectDraw) : HResult; stdcall;
function IDirectDrawSurface2_PageLock(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface2_PageUnlock(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;

// IDirectDrawSurface3 interface methods

function IDirectDrawSurface3_QueryInterface(idd : IDirectDrawSurface3; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawSurface3_AddRef(idd : IDirectDrawSurface3) : Longint; stdcall;
function IDirectDrawSurface3_Release(idd : IDirectDrawSurface3) : Longint; stdcall;
function IDirectDrawSurface3_AddAttachedSurface(idd : IDirectDrawSurface3; lpDDSAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_AddOverlayDirtyRect(idd : IDirectDrawSurface3; const lpRect : TRect) : HResult; stdcall;
function IDirectDrawSurface3_Blt(idd : IDirectDrawSurface3; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface3; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
function IDirectDrawSurface3_BltBatch(idd : IDirectDrawSurface3; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_BltFast(idd : IDirectDrawSurface3; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface3; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_DeleteAttachedSurface(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_EnumAttachedSurfaces(idd : IDirectDrawSurface3; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface3_EnumOverlayZOrders(idd : IDirectDrawSurface3; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
function IDirectDrawSurface3_Flip(idd : IDirectDrawSurface3; lpDDSurfaceTargetOverride : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_GetAttachedSurface(idd : IDirectDrawSurface3; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_GetBltStatus(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_GetCaps(idd : IDirectDrawSurface3; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
function IDirectDrawSurface3_GetClipper(idd : IDirectDrawSurface3; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface3_GetColorKey(idd : IDirectDrawSurface3; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
function IDirectDrawSurface3_GetDC(idd : IDirectDrawSurface3; var lphDC : HDC) : HResult; stdcall;
function IDirectDrawSurface3_GetFlipStatus(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_GetOverlayPosition(idd : IDirectDrawSurface3; var lplX , lplY : LongInt) : HResult; stdcall;
function IDirectDrawSurface3_GetPalette(idd : IDirectDrawSurface3; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface3_GetPixelFormat(idd : IDirectDrawSurface3; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
function IDirectDrawSurface3_GetSurfaceDesc(idd : IDirectDrawSurface3; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface3_Initialize(idd : IDirectDrawSurface3; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
function IDirectDrawSurface3_IsLost(idd : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_Lock(idd : IDirectDrawSurface3; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDrawSurface3_ReleaseDC(idd : IDirectDrawSurface3; hDC : Windows.HDC) : HResult; stdcall;
function IDirectDrawSurface3__Restore(idd : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_SetClipper(idd : IDirectDrawSurface3; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface3_SetColorKey(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
function IDirectDrawSurface3_SetOverlayPosition(idd : IDirectDrawSurface3; lX , lY : LongInt) : HResult; stdcall;
function IDirectDrawSurface3_SetPalette(idd : IDirectDrawSurface3; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface3_Unlock(idd : IDirectDrawSurface3; lpSurfaceData : Pointer) : HResult; stdcall;
function IDirectDrawSurface3_UpdateOverlay(idd : IDirectDrawSurface3; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface3; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
function IDirectDrawSurface3_UpdateOverlayDisplay(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_UpdateOverlayZOrder(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface3) : HResult; stdcall;
function IDirectDrawSurface3_GetDDInterface(idd : IDirectDrawSurface3; var lplpDD : IDirectDraw) : HResult; stdcall;
function IDirectDrawSurface3_PageLock(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_PageUnlock(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface3_SetSurfaceDesc(idd : IDirectDrawSurface3; const lpddsd : TDDSurfaceDesc; dwFlags : DWORD) : HResult; stdcall;

// IDirectDrawSurface4 interface methods

function IDirectDrawSurface4_QueryInterface(idd : IDirectDrawSurface4; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawSurface4_AddRef(idd : IDirectDrawSurface4) : Longint; stdcall;
function IDirectDrawSurface4_Release(idd : IDirectDrawSurface4) : Longint; stdcall;
function IDirectDrawSurface4_AddAttachedSurface(idd : IDirectDrawSurface4; lpDDSAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_AddOverlayDirtyRect(idd : IDirectDrawSurface4; const lpRect : TRect) : HResult; stdcall;
function IDirectDrawSurface4_Blt(idd : IDirectDrawSurface4; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface4; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
function IDirectDrawSurface4_BltBatch(idd : IDirectDrawSurface4; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_BltFast(idd : IDirectDrawSurface4; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface4; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_DeleteAttachedSurface(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_EnumAttachedSurfaces(idd : IDirectDrawSurface4; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
function IDirectDrawSurface4_EnumOverlayZOrders(idd : IDirectDrawSurface4; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
function IDirectDrawSurface4_Flip(idd : IDirectDrawSurface4; lpDDSurfaceTargetOverride : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_GetAttachedSurface(idd : IDirectDrawSurface4; const lpDDSCaps : TDDSCaps2; var lplpDDAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_GetBltStatus(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_GetCaps(idd : IDirectDrawSurface4; var lpDDSCaps : TDDSCaps2) : HResult; stdcall;
function IDirectDrawSurface4_GetClipper(idd : IDirectDrawSurface4; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface4_GetColorKey(idd : IDirectDrawSurface4; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
function IDirectDrawSurface4_GetDC(idd : IDirectDrawSurface4; var lphDC : HDC) : HResult; stdcall;
function IDirectDrawSurface4_GetFlipStatus(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_GetOverlayPosition(idd : IDirectDrawSurface4; var lplX , lplY : LongInt) : HResult; stdcall;
function IDirectDrawSurface4_GetPalette(idd : IDirectDrawSurface4; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface4_GetPixelFormat(idd : IDirectDrawSurface4; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
function IDirectDrawSurface4_GetSurfaceDesc(idd : IDirectDrawSurface4; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDrawSurface4_Initialize(idd : IDirectDrawSurface4; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDrawSurface4_IsLost(idd : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_Lock(idd : IDirectDrawSurface4; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDrawSurface4_ReleaseDC(idd : IDirectDrawSurface4; hDC : Windows.HDC) : HResult; stdcall;
function IDirectDrawSurface4__Restore(idd : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_SetClipper(idd : IDirectDrawSurface4; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface4_SetColorKey(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
function IDirectDrawSurface4_SetOverlayPosition(idd : IDirectDrawSurface4; lX , lY : LongInt) : HResult; stdcall;
function IDirectDrawSurface4_SetPalette(idd : IDirectDrawSurface4; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface4_Unlock(idd : IDirectDrawSurface4; lpRect : PRect) : HResult; stdcall;
function IDirectDrawSurface4_UpdateOverlay(idd : IDirectDrawSurface4; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface4; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
function IDirectDrawSurface4_UpdateOverlayDisplay(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_UpdateOverlayZOrder(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface4) : HResult; stdcall;
function IDirectDrawSurface4_GetDDInterface(idd : IDirectDrawSurface4; var lplpDD : IUnknown) : HResult; stdcall;
function IDirectDrawSurface4_PageLock(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_PageUnlock(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_SetSurfaceDesc(idd : IDirectDrawSurface4; const lpddsd2 : TDDSurfaceDesc2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_SetPrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID; lpData : pointer; cbSize : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_GetPrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID; lpBuffer : pointer; var lpcbBufferSize : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_FreePrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID) : HResult; stdcall;
function IDirectDrawSurface4_GetUniquenessValue(idd : IDirectDrawSurface4; var lpValue : DWORD) : HResult; stdcall;
function IDirectDrawSurface4_ChangeUniquenessValue(idd : IDirectDrawSurface4) : HResult; stdcall;

// IDirectDrawSurface7 interface methods

function IDirectDrawSurface7_QueryInterface(idd : IDirectDrawSurface7; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawSurface7_AddRef(idd : IDirectDrawSurface7) : Longint; stdcall;
function IDirectDrawSurface7_Release(idd : IDirectDrawSurface7) : Longint; stdcall;
function IDirectDrawSurface7_AddAttachedSurface(idd : IDirectDrawSurface7; lpDDSAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_AddOverlayDirtyRect(idd : IDirectDrawSurface7; const lpRect : TRect) : HResult; stdcall;
function IDirectDrawSurface7_Blt(idd : IDirectDrawSurface7; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface7; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
function IDirectDrawSurface7_BltBatch(idd : IDirectDrawSurface7; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_BltFast(idd : IDirectDrawSurface7; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface7; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_DeleteAttachedSurface(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_EnumAttachedSurfaces(idd : IDirectDrawSurface7; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
function IDirectDrawSurface7_EnumOverlayZOrders(idd : IDirectDrawSurface7; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
function IDirectDrawSurface7_Flip(idd : IDirectDrawSurface7; lpDDSurfaceTargetOverride : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetAttachedSurface(idd : IDirectDrawSurface7; const lpDDSCaps : TDDSCaps2; var lplpDDAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_GetBltStatus(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetCaps(idd : IDirectDrawSurface7; var lpDDSCaps : TDDSCaps2) : HResult; stdcall;
function IDirectDrawSurface7_GetClipper(idd : IDirectDrawSurface7; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface7_GetColorKey(idd : IDirectDrawSurface7; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
function IDirectDrawSurface7_GetDC(idd : IDirectDrawSurface7; var lphDC : HDC) : HResult; stdcall;
function IDirectDrawSurface7_GetFlipStatus(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetOverlayPosition(idd : IDirectDrawSurface7; var lplX , lplY : LongInt) : HResult; stdcall;
function IDirectDrawSurface7_GetPalette(idd : IDirectDrawSurface7; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface7_GetPixelFormat(idd : IDirectDrawSurface7; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
function IDirectDrawSurface7_GetSurfaceDesc(idd : IDirectDrawSurface7; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDrawSurface7_Initialize(idd : IDirectDrawSurface7; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
function IDirectDrawSurface7_IsLost(idd : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_Lock(idd : IDirectDrawSurface7; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
function IDirectDrawSurface7_ReleaseDC(idd : IDirectDrawSurface7; hDC : Windows.HDC) : HResult; stdcall;
function IDirectDrawSurface7__Restore(idd : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_SetClipper(idd : IDirectDrawSurface7; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
function IDirectDrawSurface7_SetColorKey(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
function IDirectDrawSurface7_SetOverlayPosition(idd : IDirectDrawSurface7; lX , lY : LongInt) : HResult; stdcall;
function IDirectDrawSurface7_SetPalette(idd : IDirectDrawSurface7; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
function IDirectDrawSurface7_Unlock(idd : IDirectDrawSurface7; lpRect : PRect) : HResult; stdcall;
function IDirectDrawSurface7_UpdateOverlay(idd : IDirectDrawSurface7; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface7; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
function IDirectDrawSurface7_UpdateOverlayDisplay(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_UpdateOverlayZOrder(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_GetDDInterface(idd : IDirectDrawSurface7; var lplpDD : IUnknown) : HResult; stdcall;
function IDirectDrawSurface7_PageLock(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_PageUnlock(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_SetSurfaceDesc(idd : IDirectDrawSurface7; const lpddsd2 : TDDSurfaceDesc2; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_SetPrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID; lpData : pointer; cbSize : DWORD; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetPrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID; lpBuffer : pointer; var lpcbBufferSize : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_FreePrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID) : HResult; stdcall;
function IDirectDrawSurface7_GetUniquenessValue(idd : IDirectDrawSurface7; var lpValue : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_ChangeUniquenessValue(idd : IDirectDrawSurface7) : HResult; stdcall;
function IDirectDrawSurface7_SetPriority(idd : IDirectDrawSurface7; dwPriority : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetPriority(idd : IDirectDrawSurface7; var lpdwPriority : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_SetLOD(idd : IDirectDrawSurface7; dwMaxLOD : DWORD) : HResult; stdcall;
function IDirectDrawSurface7_GetLOD(idd : IDirectDrawSurface7; var lpdwMaxLOD : DWORD) : HResult; stdcall;

// IDirectDrawColorControl interface methods

function IDirectDrawColorControl_QueryInterface(idd : IDirectDrawColorControl; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawColorControl_AddRef(idd : IDirectDrawColorControl) : Longint; stdcall;
function IDirectDrawColorControl_Release(idd : IDirectDrawColorControl) : Longint; stdcall;
function IDirectDrawColorControl_GetColorControls(idd : IDirectDrawColorControl; var lpColorControl : TDDColorControl) : HResult; stdcall;
function IDirectDrawColorControl_SetColorControls(idd : IDirectDrawColorControl; const lpColorControl : TDDColorControl) : HResult; stdcall;

// IDirectDrawGammaControl interface methods

function IDirectDrawGammaControl_QueryInterface(idd : IDirectDrawGammaControl; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawGammaControl_AddRef(idd : IDirectDrawGammaControl) : Longint; stdcall;
function IDirectDrawGammaControl_Release(idd : IDirectDrawGammaControl) : Longint; stdcall;
function IDirectDrawGammaControl_GetGammaRamp(idd : IDirectDrawGammaControl; dwFlags : DWORD; var lpRampData : TDDGammaRamp) : HResult; stdcall;
function IDirectDrawGammaControl_SetGammaRamp(idd : IDirectDrawGammaControl; dwFlags : DWORD; const lpRampData : TDDGammaRamp) : HResult; stdcall;

// IDirectDrawVideoPort interface methods

function IDirectDrawVideoPort_QueryInterface(idd : IDirectDrawVideoPort; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDirectDrawVideoPort_AddRef(idd : IDirectDrawVideoPort) : Longint; stdcall;
function IDirectDrawVideoPort_Release(idd : IDirectDrawVideoPort) : Longint; stdcall;
function IDirectDrawVideoPort_Flip(idd : IDirectDrawVideoPort; lpDDSurface : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_GetBandwidthInfo(idd : IDirectDrawVideoPort; var lpddpfFormat : TDDPixelFormat; dwWidth : DWORD; dwHeight : DWORD; dwFlags : DWORD; var lpBandwidth : TDDVideoPortBandWidth) : HResult; stdcall;
function IDirectDrawVideoPort_GetColorControls(idd : IDirectDrawVideoPort; var lpColorControl : TDDColorControl) : HResult; stdcall;
function IDirectDrawVideoPort_GetInputFormats(idd : IDirectDrawVideoPort; var lpNumFormats : DWORD; var lpFormats : TDDPixelFormat; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_GetOutputFormats(idd : IDirectDrawVideoPort; var lpInputFormat : TDDPixelFormat; var lpNumFormats : DWORD; lpFormats : PDDPixelFormat; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_GetFieldPolarity(idd : IDirectDrawVideoPort; var lpbVideoField : BOOL) : HResult; stdcall;
function IDirectDrawVideoPort_GetVideoLine(idd : IDirectDrawVideoPort; var lpdwLine : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_GetVideoSignalStatus(idd : IDirectDrawVideoPort; varlpdwStatus : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_SetColorControls(idd : IDirectDrawVideoPort; var lpColorControl : TDDColorControl) : HResult; stdcall;
function IDirectDrawVideoPort_SetTargetSurface(idd : IDirectDrawVideoPort; lpDDSurface : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
function IDirectDrawVideoPort_StartVideo(idd : IDirectDrawVideoPort; var lpVideoInfo : TDDVideoPortInfo) : HResult; stdcall;
function IDirectDrawVideoPort_StopVideo(idd : IDirectDrawVideoPort) : HResult; stdcall;
function IDirectDrawVideoPort_UpdateVideo(idd : IDirectDrawVideoPort; var lpVideoInfo : TDDVideoPortInfo) : HResult; stdcall;
function IDirectDrawVideoPort_WaitForSync(idd : IDirectDrawVideoPort; dwFlags : DWORD; dwLine : DWORD; dwTimeout : DWORD) : HResult; stdcall;

// IDDVideoPortContainer interface methods

function IDDVideoPortContainer_QueryInterface(idd : IDDVideoPortContainer; const IID : TGUID; var obj) : HRESULT; stdcall;
function IDDVideoPortContainer_AddRef(idd : IDDVideoPortContainer) : Longint; stdcall;
function IDDVideoPortContainer_Release(idd : IDDVideoPortContainer) : Longint; stdcall;
function IDDVideoPortContainer_CreateVideoPort(idd : IDDVideoPortContainer; dwFlags : DWORD; var lpTDDVideoPortDesc : TDDVideoPortDesc; var lplpDDVideoPort : IDirectDrawVideoPort; pUnkOuter : IUnknown) : HResult; stdcall;
function IDDVideoPortContainer_EnumVideoPorts(idd : IDDVideoPortContainer; dwFlags : DWORD; lpTDDVideoPortCaps : PDDVideoPortCaps; lpContext : Pointer; lpEnumVideoCallback : TDDEnumVideoCallback) : HResult; stdcall;
function IDDVideoPortContainer_GetVideoPortConnectInfo(idd : IDDVideoPortContainer; dwPortId : DWORD; var lpNumEntries : DWORD; lpConnectInfo : PDDVideoPortConnect) : HResult; stdcall;
function IDDVideoPortContainer_QueryVideoPortStatus(idd : IDDVideoPortContainer; dwPortId : DWORD; var lpVPStatus : TDDVideoPortStatus) : HResult; stdcall;

implementation


// IDirectDraw interface methods

function IDirectDraw_QueryInterface(idd : IDirectDraw; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDraw_AddRef(idd : IDirectDraw) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDraw_Release(idd : IDirectDraw) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDraw_Compact(idd : IDirectDraw) : HResult; stdcall;
begin
	result := idd^^.Compact(idd);
end;

function IDirectDraw_CreateClipper(idd : IDirectDraw; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateClipper(idd, dwFlags, lplpDDClipper, pUnkOuter);
end;

function IDirectDraw_CreatePalette(idd : IDirectDraw; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreatePalette(idd, dwFlags, lpColorTable, lplpDDPalette, pUnkOuter);
end;

function IDirectDraw_CreateSurface(idd : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc; var lplpDDSurface : IDirectDrawSurface; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateSurface(idd, lpDDSurfaceDesc, lplpDDSurface, pUnkOuter);
end;

function IDirectDraw_DuplicateSurface(idd : IDirectDraw; lpDDSurface : IDirectDrawSurface; var lplpDupDDSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.DuplicateSurface(idd, lpDDSurface, lplpDupDDSurface);
end;

function IDirectDraw_EnumDisplayModes(idd : IDirectDraw; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumDisplayModes(idd, dwFlags, lpDDSurfaceDesc, lpContext, @lpEnumModesCallback);
end;

function IDirectDraw_EnumSurfaces(idd : IDirectDraw; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumSurfaces(idd, dwFlags, lpDDSD, lpContext, @lpEnumCallback);
end;

function IDirectDraw_FlipToGDISurface(idd : IDirectDraw) : HResult; stdcall;
begin
	result := idd^^.FlipToGDISurface(idd);
end;

function IDirectDraw_GetCaps(idd : IDirectDraw; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDDriverCaps, lpDDHELCaps);
end;

function IDirectDraw_GetDisplayMode(idd : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.GetDisplayMode(idd, lpDDSurfaceDesc);
end;

function IDirectDraw_GetFourCCCodes(idd : IDirectDraw; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
begin
	result := idd^^.GetFourCCCodes(idd, lpNumCodes, lpCodes);
end;

function IDirectDraw_GetGDISurface(idd : IDirectDraw; var lplpGDIDDSSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.GetGDISurface(idd, lplpGDIDDSSurface);
end;

function IDirectDraw_GetMonitorFrequency(idd : IDirectDraw; var lpdwFrequency : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetMonitorFrequency(idd, lpdwFrequency);
end;

function IDirectDraw_GetScanLine(idd : IDirectDraw; var lpdwScanLine : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetScanLine(idd, lpdwScanLine);
end;

function IDirectDraw_GetVerticalBlankStatus(idd : IDirectDraw; var lpbIsInVB : BOOL) : HResult; stdcall;
begin
	result := idd^^.GetVerticalBlankStatus(idd, lpbIsInVB);
end;

function IDirectDraw_Initialize(idd : IDirectDraw; lpGUID : PGUID) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpGUID);
end;

function IDirectDraw_RestoreDisplayMode(idd : IDirectDraw) : HResult; stdcall;
begin
	result := idd^^.RestoreDisplayMode(idd);
end;

function IDirectDraw_SetCooperativeLevel(idd : IDirectDraw; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetCooperativeLevel(idd, hWnd, dwFlags);
end;

function IDirectDraw_SetDisplayMode(idd : IDirectDraw; dwWidth : DWORD; dwHeight : DWORD; dwBpp : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetDisplayMode(idd, dwWidth, dwHeight, dwBpp);
end;

function IDirectDraw_WaitForVerticalBlank(idd : IDirectDraw; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.WaitForVerticalBlank(idd, dwFlags, hEvent);
end;


// IDirectDraw2 interface methods

function IDirectDraw2_QueryInterface(idd : IDirectDraw2; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDraw2_AddRef(idd : IDirectDraw2) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDraw2_Release(idd : IDirectDraw2) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDraw2_Compact(idd : IDirectDraw2) : HResult; stdcall;
begin
	result := idd^^.Compact(idd);
end;

function IDirectDraw2_CreateClipper(idd : IDirectDraw2; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateClipper(idd, dwFlags, lplpDDClipper, pUnkOuter);
end;

function IDirectDraw2_CreatePalette(idd : IDirectDraw2; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreatePalette(idd, dwFlags, lpColorTable, lplpDDPalette, pUnkOuter);
end;

function IDirectDraw2_CreateSurface(idd : IDirectDraw2; var lpDDSurfaceDesc : TDDSurfaceDesc; var lplpDDSurface : IDirectDrawSurface; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateSurface(idd, lpDDSurfaceDesc, lplpDDSurface, pUnkOuter);
end;

function IDirectDraw2_DuplicateSurface(idd : IDirectDraw2; lpDDSurface : IDirectDrawSurface; var lplpDupDDSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.DuplicateSurface(idd, lpDDSurface, lplpDupDDSurface);
end;

function IDirectDraw2_EnumDisplayModes(idd : IDirectDraw2; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumDisplayModes(idd, dwFlags, lpDDSurfaceDesc, lpContext, @lpEnumModesCallback);
end;

function IDirectDraw2_EnumSurfaces(idd : IDirectDraw2; dwFlags : DWORD; var lpDDSD : TDDSurfaceDesc; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumSurfaces(idd, dwFlags, lpDDSD, lpContext, @lpEnumCallback);
end;

function IDirectDraw2_FlipToGDISurface(idd : IDirectDraw2) : HResult; stdcall;
begin
	result := idd^^.FlipToGDISurface(idd);
end;

function IDirectDraw2_GetCaps(idd : IDirectDraw2; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDDriverCaps, lpDDHELCaps);
end;

function IDirectDraw2_GetDisplayMode(idd : IDirectDraw2; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.GetDisplayMode(idd, lpDDSurfaceDesc);
end;

function IDirectDraw2_GetFourCCCodes(idd : IDirectDraw2; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
begin
	result := idd^^.GetFourCCCodes(idd, lpNumCodes, lpCodes);
end;

function IDirectDraw2_GetGDISurface(idd : IDirectDraw2; var lplpGDIDDSSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.GetGDISurface(idd, lplpGDIDDSSurface);
end;

function IDirectDraw2_GetMonitorFrequency(idd : IDirectDraw2; var lpdwFrequency : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetMonitorFrequency(idd, lpdwFrequency);
end;

function IDirectDraw2_GetScanLine(idd : IDirectDraw2; var lpdwScanLine : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetScanLine(idd, lpdwScanLine);
end;

function IDirectDraw2_GetVerticalBlankStatus(idd : IDirectDraw2; var lpbIsInVB : BOOL) : HResult; stdcall;
begin
	result := idd^^.GetVerticalBlankStatus(idd, lpbIsInVB);
end;

function IDirectDraw2_Initialize(idd : IDirectDraw2; lpGUID : PGUID) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpGUID);
end;

function IDirectDraw2_RestoreDisplayMode(idd : IDirectDraw2) : HResult; stdcall;
begin
	result := idd^^.RestoreDisplayMode(idd);
end;

function IDirectDraw2_SetCooperativeLevel(idd : IDirectDraw2; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetCooperativeLevel(idd, hWnd, dwFlags);
end;

function IDirectDraw2_SetDisplayMode(idd : IDirectDraw2; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetDisplayMode(idd, dwWidth, dwHeight, dwBPP, dwRefreshRate, dwFlags);
end;

function IDirectDraw2_WaitForVerticalBlank(idd : IDirectDraw2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.WaitForVerticalBlank(idd, dwFlags, hEvent);
end;

function IDirectDraw2_GetAvailableVidMem(idd : IDirectDraw2; var lpDDSCaps : TDDSCaps; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetAvailableVidMem(idd, lpDDSCaps, lpdwTotal, lpdwFree);
end;


// IDirectDraw4 interface methods

function IDirectDraw4_QueryInterface(idd : IDirectDraw4; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDraw4_AddRef(idd : IDirectDraw4) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDraw4_Release(idd : IDirectDraw4) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDraw4_Compact(idd : IDirectDraw4) : HResult; stdcall;
begin
	result := idd^^.Compact(idd);
end;

function IDirectDraw4_CreateClipper(idd : IDirectDraw4; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateClipper(idd, dwFlags, lplpDDClipper, pUnkOuter);
end;

function IDirectDraw4_CreatePalette(idd : IDirectDraw4; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreatePalette(idd, dwFlags, lpColorTable, lplpDDPalette, pUnkOuter);
end;

function IDirectDraw4_CreateSurface(idd : IDirectDraw4; const lpDDSurfaceDesc : TDDSurfaceDesc2; var lplpDDSurface : IDirectDrawSurface4; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateSurface(idd, lpDDSurfaceDesc, lplpDDSurface, pUnkOuter);
end;

function IDirectDraw4_DuplicateSurface(idd : IDirectDraw4; lpDDSurface : IDirectDrawSurface4; var lplpDupDDSurface : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.DuplicateSurface(idd, lpDDSurface, lplpDupDDSurface);
end;

function IDirectDraw4_EnumDisplayModes(idd : IDirectDraw4; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc2; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback2) : HResult; stdcall;
begin
	result := idd^^.EnumDisplayModes(idd, dwFlags, lpDDSurfaceDesc, lpContext, @lpEnumModesCallback);
end;

function IDirectDraw4_EnumSurfaces(idd : IDirectDraw4; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc2; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
begin
	result := idd^^.EnumSurfaces(idd, dwFlags, lpDDSD, lpContext, @lpEnumCallback);
end;

function IDirectDraw4_FlipToGDISurface(idd : IDirectDraw4) : HResult; stdcall;
begin
	result := idd^^.FlipToGDISurface(idd);
end;

function IDirectDraw4_GetCaps(idd : IDirectDraw4; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDDriverCaps, lpDDHELCaps);
end;

function IDirectDraw4_GetDisplayMode(idd : IDirectDraw4; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.GetDisplayMode(idd, lpDDSurfaceDesc);
end;

function IDirectDraw4_GetFourCCCodes(idd : IDirectDraw4; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
begin
	result := idd^^.GetFourCCCodes(idd, lpNumCodes, lpCodes);
end;

function IDirectDraw4_GetGDISurface(idd : IDirectDraw4; var lplpGDIDDSSurface : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.GetGDISurface(idd, lplpGDIDDSSurface);
end;

function IDirectDraw4_GetMonitorFrequency(idd : IDirectDraw4; var lpdwFrequency : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetMonitorFrequency(idd, lpdwFrequency);
end;

function IDirectDraw4_GetScanLine(idd : IDirectDraw4; var lpdwScanLine : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetScanLine(idd, lpdwScanLine);
end;

function IDirectDraw4_GetVerticalBlankStatus(idd : IDirectDraw4; var lpbIsInVB : BOOL) : HResult; stdcall;
begin
	result := idd^^.GetVerticalBlankStatus(idd, lpbIsInVB);
end;

function IDirectDraw4_Initialize(idd : IDirectDraw4; lpGUID : PGUID) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpGUID);
end;

function IDirectDraw4_RestoreDisplayMode(idd : IDirectDraw4) : HResult; stdcall;
begin
	result := idd^^.RestoreDisplayMode(idd);
end;

function IDirectDraw4_SetCooperativeLevel(idd : IDirectDraw4; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetCooperativeLevel(idd, hWnd, dwFlags);
end;

function IDirectDraw4_SetDisplayMode(idd : IDirectDraw4; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetDisplayMode(idd, dwWidth, dwHeight, dwBPP, dwRefreshRate, dwFlags);
end;

function IDirectDraw4_WaitForVerticalBlank(idd : IDirectDraw4; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.WaitForVerticalBlank(idd, dwFlags, hEvent);
end;

function IDirectDraw4_GetAvailableVidMem(idd : IDirectDraw4; const lpDDSCaps : TDDSCaps2; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetAvailableVidMem(idd, lpDDSCaps, lpdwTotal, lpdwFree);
end;

function IDirectDraw4_GetSurfaceFromDC(idd : IDirectDraw4; hdc : Windows.HDC; var lpDDS4 : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceFromDC(idd, hdc, lpDDS4);
end;

function IDirectDraw4_RestoreAllSurfaces(idd : IDirectDraw4) : HResult; stdcall;
begin
	result := idd^^.RestoreAllSurfaces(idd);
end;

function IDirectDraw4_TestCooperativeLevel(idd : IDirectDraw4) : HResult; stdcall;
begin
	result := idd^^.TestCooperativeLevel(idd);
end;

function IDirectDraw4_GetDeviceIdentifier(idd : IDirectDraw4; var lpdddi : TDDDeviceIdentifier; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetDeviceIdentifier(idd, lpdddi, dwFlags);
end;


// IDirectDraw7 interface methods

function IDirectDraw7_QueryInterface(idd : IDirectDraw7; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDraw7_AddRef(idd : IDirectDraw7) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDraw7_Release(idd : IDirectDraw7) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDraw7_Compact(idd : IDirectDraw7) : HResult; stdcall;
begin
	result := idd^^.Compact(idd);
end;

function IDirectDraw7_CreateClipper(idd : IDirectDraw7; dwFlags : DWORD; var lplpDDClipper : IDirectDrawClipper; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateClipper(idd, dwFlags, lplpDDClipper, pUnkOuter);
end;

function IDirectDraw7_CreatePalette(idd : IDirectDraw7; dwFlags : DWORD; lpColorTable : pointer; var lplpDDPalette : IDirectDrawPalette; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreatePalette(idd, dwFlags, lpColorTable, lplpDDPalette, pUnkOuter);
end;

function IDirectDraw7_CreateSurface(idd : IDirectDraw7; const lpDDSurfaceDesc : TDDSurfaceDesc2; var lplpDDSurface : IDirectDrawSurface7; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateSurface(idd, lpDDSurfaceDesc, lplpDDSurface, pUnkOuter);
end;

function IDirectDraw7_DuplicateSurface(idd : IDirectDraw7; lpDDSurface : IDirectDrawSurface7; var lplpDupDDSurface : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.DuplicateSurface(idd, lpDDSurface, lplpDupDDSurface);
end;

function IDirectDraw7_EnumDisplayModes(idd : IDirectDraw7; dwFlags : DWORD; lpDDSurfaceDesc : PDDSurfaceDesc2; lpContext : Pointer; lpEnumModesCallback : TDDEnumModesCallback2) : HResult; stdcall;
begin
	result := idd^^.EnumDisplayModes(idd, dwFlags, lpDDSurfaceDesc, lpContext, @lpEnumModesCallback);
end;

function IDirectDraw7_EnumSurfaces(idd : IDirectDraw7; dwFlags : DWORD; const lpDDSD : TDDSurfaceDesc2; lpContext : Pointer; lpEnumCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
begin
	result := idd^^.EnumSurfaces(idd, dwFlags, lpDDSD, lpContext, @lpEnumCallback);
end;

function IDirectDraw7_FlipToGDISurface(idd : IDirectDraw7) : HResult; stdcall;
begin
	result := idd^^.FlipToGDISurface(idd);
end;

function IDirectDraw7_GetCaps(idd : IDirectDraw7; lpDDDriverCaps : PDDCaps; lpDDHELCaps : PDDCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDDriverCaps, lpDDHELCaps);
end;

function IDirectDraw7_GetDisplayMode(idd : IDirectDraw7; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.GetDisplayMode(idd, lpDDSurfaceDesc);
end;

function IDirectDraw7_GetFourCCCodes(idd : IDirectDraw7; var lpNumCodes : DWORD; lpCodes : PDWORD) : HResult; stdcall;
begin
	result := idd^^.GetFourCCCodes(idd, lpNumCodes, lpCodes);
end;

function IDirectDraw7_GetGDISurface(idd : IDirectDraw7; var lplpGDIDDSSurface : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.GetGDISurface(idd, lplpGDIDDSSurface);
end;

function IDirectDraw7_GetMonitorFrequency(idd : IDirectDraw7; var lpdwFrequency : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetMonitorFrequency(idd, lpdwFrequency);
end;

function IDirectDraw7_GetScanLine(idd : IDirectDraw7; var lpdwScanLine : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetScanLine(idd, lpdwScanLine);
end;

function IDirectDraw7_GetVerticalBlankStatus(idd : IDirectDraw7; var lpbIsInVB : BOOL) : HResult; stdcall;
begin
	result := idd^^.GetVerticalBlankStatus(idd, lpbIsInVB);
end;

function IDirectDraw7_Initialize(idd : IDirectDraw7; lpGUID : PGUID) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpGUID);
end;

function IDirectDraw7_RestoreDisplayMode(idd : IDirectDraw7) : HResult; stdcall;
begin
	result := idd^^.RestoreDisplayMode(idd);
end;

function IDirectDraw7_SetCooperativeLevel(idd : IDirectDraw7; hWnd : HWND; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetCooperativeLevel(idd, hWnd, dwFlags);
end;

function IDirectDraw7_SetDisplayMode(idd : IDirectDraw7; dwWidth : DWORD; dwHeight : DWORD; dwBPP : DWORD; dwRefreshRate : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetDisplayMode(idd, dwWidth, dwHeight, dwBPP, dwRefreshRate, dwFlags);
end;

function IDirectDraw7_WaitForVerticalBlank(idd : IDirectDraw7; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.WaitForVerticalBlank(idd, dwFlags, hEvent);
end;

function IDirectDraw7_GetAvailableVidMem(idd : IDirectDraw7; const lpDDSCaps : TDDSCaps2; var lpdwTotal , lpdwFree : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetAvailableVidMem(idd, lpDDSCaps, lpdwTotal, lpdwFree);
end;

function IDirectDraw7_GetSurfaceFromDC(idd : IDirectDraw7; hdc : Windows.HDC; var lpDDS : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceFromDC(idd, hdc, lpDDS);
end;

function IDirectDraw7_RestoreAllSurfaces(idd : IDirectDraw7) : HResult; stdcall;
begin
	result := idd^^.RestoreAllSurfaces(idd);
end;

function IDirectDraw7_TestCooperativeLevel(idd : IDirectDraw7) : HResult; stdcall;
begin
	result := idd^^.TestCooperativeLevel(idd);
end;

function IDirectDraw7_GetDeviceIdentifier(idd : IDirectDraw7; var lpdddi : TDDDeviceIdentifier2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetDeviceIdentifier(idd, lpdddi, dwFlags);
end;

function IDirectDraw7_StartModeTest(idd : IDirectDraw7; const lpModesToTest; dwNumEntries , dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.StartModeTest(idd, lpModesToTest, dwNumEntries, dwFlags);
end;

function IDirectDraw7_EvaluateMode(idd : IDirectDraw7; dwFlags : DWORD; var pSecondsUntilTimeout : DWORD) : HResult; stdcall;
begin
	result := idd^^.EvaluateMode(idd, dwFlags, pSecondsUntilTimeout);
end;


// IDirectDrawPalette interface methods

function IDirectDrawPalette_QueryInterface(idd : IDirectDrawPalette; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawPalette_AddRef(idd : IDirectDrawPalette) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawPalette_Release(idd : IDirectDrawPalette) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawPalette_GetCaps(idd : IDirectDrawPalette; var lpdwCaps : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpdwCaps);
end;

function IDirectDrawPalette_GetEntries(idd : IDirectDrawPalette; dwFlags : DWORD; dwBase : DWORD; dwNumEntries : DWORD; lpEntries : pointer) : HResult; stdcall;
begin
	result := idd^^.GetEntries(idd, dwFlags, dwBase, dwNumEntries, lpEntries);
end;

function IDirectDrawPalette_Initialize(idd : IDirectDrawPalette; lpDD : IDirectDraw; dwFlags : DWORD; lpDDColorTable : pointer) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, dwFlags, lpDDColorTable);
end;

function IDirectDrawPalette_SetEntries(idd : IDirectDrawPalette; dwFlags : DWORD; dwStartingEntry : DWORD; dwCount : DWORD; lpEntries : pointer) : HResult; stdcall;
begin
	result := idd^^.SetEntries(idd, dwFlags, dwStartingEntry, dwCount, lpEntries);
end;


// IDirectDrawClipper interface methods

function IDirectDrawClipper_QueryInterface(idd : IDirectDrawClipper; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawClipper_AddRef(idd : IDirectDrawClipper) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawClipper_Release(idd : IDirectDrawClipper) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawClipper_GetClipList(idd : IDirectDrawClipper; lpRect : PRect; lpClipList : PRgnData; var lpdwSize : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetClipList(idd, lpRect, lpClipList, lpdwSize);
end;

function IDirectDrawClipper_GetHWnd(idd : IDirectDrawClipper; var lphWnd : HWND) : HResult; stdcall;
begin
	result := idd^^.GetHWnd(idd, lphWnd);
end;

function IDirectDrawClipper_Initialize(idd : IDirectDrawClipper; lpDD : IDirectDraw; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, dwFlags);
end;

function IDirectDrawClipper_IsClipListChanged(idd : IDirectDrawClipper; var lpbChanged : BOOL) : HResult; stdcall;
begin
	result := idd^^.IsClipListChanged(idd, lpbChanged);
end;

function IDirectDrawClipper_SetClipList(idd : IDirectDrawClipper; lpClipList : PRgnData; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetClipList(idd, lpClipList, dwFlags);
end;

function IDirectDrawClipper_SetHWnd(idd : IDirectDrawClipper; dwFlags : DWORD; hWnd : HWND) : HResult; stdcall;
begin
	result := idd^^.SetHWnd(idd, dwFlags, hWnd);
end;


// IDirectDrawSurface interface methods

function IDirectDrawSurface_QueryInterface(idd : IDirectDrawSurface; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawSurface_AddRef(idd : IDirectDrawSurface) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawSurface_Release(idd : IDirectDrawSurface) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawSurface_AddAttachedSurface(idd : IDirectDrawSurface; lpDDSAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.AddAttachedSurface(idd, lpDDSAttachedSurface);
end;

function IDirectDrawSurface_AddOverlayDirtyRect(idd : IDirectDrawSurface; const lpRect : TRect) : HResult; stdcall;
begin
	result := idd^^.AddOverlayDirtyRect(idd, lpRect);
end;

function IDirectDrawSurface_Blt(idd : IDirectDrawSurface; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
begin
	result := idd^^.Blt(idd, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx);
end;

function IDirectDrawSurface_BltBatch(idd : IDirectDrawSurface; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltBatch(idd, lpDDBltBatch, dwCount, dwFlags);
end;

function IDirectDrawSurface_BltFast(idd : IDirectDrawSurface; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltFast(idd, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans);
end;

function IDirectDrawSurface_DeleteAttachedSurface(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.DeleteAttachedSurface(idd, dwFlags, lpDDSAttachedSurface);
end;

function IDirectDrawSurface_EnumAttachedSurfaces(idd : IDirectDrawSurface; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumAttachedSurfaces(idd, lpContext, @lpEnumSurfacesCallback);
end;

function IDirectDrawSurface_EnumOverlayZOrders(idd : IDirectDrawSurface; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumOverlayZOrders(idd, dwFlags, lpContext, @lpfnCallback);
end;

function IDirectDrawSurface_Flip(idd : IDirectDrawSurface; lpDDSurfaceTargetOverride : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurfaceTargetOverride, dwFlags);
end;

function IDirectDrawSurface_GetAttachedSurface(idd : IDirectDrawSurface; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.GetAttachedSurface(idd, lpDDSCaps, lplpDDAttachedSurface);
end;

function IDirectDrawSurface_GetBltStatus(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetBltStatus(idd, dwFlags);
end;

function IDirectDrawSurface_GetCaps(idd : IDirectDrawSurface; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDSCaps);
end;

function IDirectDrawSurface_GetClipper(idd : IDirectDrawSurface; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.GetClipper(idd, lplpDDClipper);
end;

function IDirectDrawSurface_GetColorKey(idd : IDirectDrawSurface; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
begin
	result := idd^^.GetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface_GetDC(idd : IDirectDrawSurface; var lphDC : HDC) : HResult; stdcall;
begin
	result := idd^^.GetDC(idd, lphDC);
end;

function IDirectDrawSurface_GetFlipStatus(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetFlipStatus(idd, dwFlags);
end;

function IDirectDrawSurface_GetOverlayPosition(idd : IDirectDrawSurface; var lplX , lplY : LongInt) : HResult; stdcall;
begin
	result := idd^^.GetOverlayPosition(idd, lplX, lplY);
end;

function IDirectDrawSurface_GetPalette(idd : IDirectDrawSurface; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.GetPalette(idd, lplpDDPalette);
end;

function IDirectDrawSurface_GetPixelFormat(idd : IDirectDrawSurface; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
begin
	result := idd^^.GetPixelFormat(idd, lpDDPixelFormat);
end;

function IDirectDrawSurface_GetSurfaceDesc(idd : IDirectDrawSurface; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceDesc(idd, lpDDSurfaceDesc);
end;

function IDirectDrawSurface_Initialize(idd : IDirectDrawSurface; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, lpDDSurfaceDesc);
end;

function IDirectDrawSurface_IsLost(idd : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.IsLost(idd);
end;

function IDirectDrawSurface_Lock(idd : IDirectDrawSurface; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.Lock(idd, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent);
end;

function IDirectDrawSurface_ReleaseDC(idd : IDirectDrawSurface; hDC : Windows.HDC) : HResult; stdcall;
begin
	result := idd^^.ReleaseDC(idd, hDC);
end;

function IDirectDrawSurface__Restore(idd : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^._Restore(idd);
end;

function IDirectDrawSurface_SetClipper(idd : IDirectDrawSurface; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.SetClipper(idd, lpDDClipper);
end;

function IDirectDrawSurface_SetColorKey(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
begin
	result := idd^^.SetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface_SetOverlayPosition(idd : IDirectDrawSurface; lX , lY : LongInt) : HResult; stdcall;
begin
	result := idd^^.SetOverlayPosition(idd, lX, lY);
end;

function IDirectDrawSurface_SetPalette(idd : IDirectDrawSurface; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.SetPalette(idd, lpDDPalette);
end;

function IDirectDrawSurface_Unlock(idd : IDirectDrawSurface; lpSurfaceData : Pointer) : HResult; stdcall;
begin
	result := idd^^.Unlock(idd, lpSurfaceData);
end;

function IDirectDrawSurface_UpdateOverlay(idd : IDirectDrawSurface; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlay(idd, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx);
end;

function IDirectDrawSurface_UpdateOverlayDisplay(idd : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayDisplay(idd, dwFlags);
end;

function IDirectDrawSurface_UpdateOverlayZOrder(idd : IDirectDrawSurface; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayZOrder(idd, dwFlags, lpDDSReference);
end;


// IDirectDrawSurface2 interface methods

function IDirectDrawSurface2_QueryInterface(idd : IDirectDrawSurface2; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawSurface2_AddRef(idd : IDirectDrawSurface2) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawSurface2_Release(idd : IDirectDrawSurface2) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawSurface2_AddAttachedSurface(idd : IDirectDrawSurface2; lpDDSAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^.AddAttachedSurface(idd, lpDDSAttachedSurface);
end;

function IDirectDrawSurface2_AddOverlayDirtyRect(idd : IDirectDrawSurface2; const lpRect : TRect) : HResult; stdcall;
begin
	result := idd^^.AddOverlayDirtyRect(idd, lpRect);
end;

function IDirectDrawSurface2_Blt(idd : IDirectDrawSurface2; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface2; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
begin
	result := idd^^.Blt(idd, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx);
end;

function IDirectDrawSurface2_BltBatch(idd : IDirectDrawSurface2; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltBatch(idd, lpDDBltBatch, dwCount, dwFlags);
end;

function IDirectDrawSurface2_BltFast(idd : IDirectDrawSurface2; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface2; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltFast(idd, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans);
end;

function IDirectDrawSurface2_DeleteAttachedSurface(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^.DeleteAttachedSurface(idd, dwFlags, lpDDSAttachedSurface);
end;

function IDirectDrawSurface2_EnumAttachedSurfaces(idd : IDirectDrawSurface2; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumAttachedSurfaces(idd, lpContext, @lpEnumSurfacesCallback);
end;

function IDirectDrawSurface2_EnumOverlayZOrders(idd : IDirectDrawSurface2; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumOverlayZOrders(idd, dwFlags, lpContext, @lpfnCallback);
end;

function IDirectDrawSurface2_Flip(idd : IDirectDrawSurface2; lpDDSurfaceTargetOverride : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurfaceTargetOverride, dwFlags);
end;

function IDirectDrawSurface2_GetAttachedSurface(idd : IDirectDrawSurface2; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^.GetAttachedSurface(idd, lpDDSCaps, lplpDDAttachedSurface);
end;

function IDirectDrawSurface2_GetBltStatus(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetBltStatus(idd, dwFlags);
end;

function IDirectDrawSurface2_GetCaps(idd : IDirectDrawSurface2; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDSCaps);
end;

function IDirectDrawSurface2_GetClipper(idd : IDirectDrawSurface2; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.GetClipper(idd, lplpDDClipper);
end;

function IDirectDrawSurface2_GetColorKey(idd : IDirectDrawSurface2; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
begin
	result := idd^^.GetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface2_GetDC(idd : IDirectDrawSurface2; var lphDC : HDC) : HResult; stdcall;
begin
	result := idd^^.GetDC(idd, lphDC);
end;

function IDirectDrawSurface2_GetFlipStatus(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetFlipStatus(idd, dwFlags);
end;

function IDirectDrawSurface2_GetOverlayPosition(idd : IDirectDrawSurface2; var lplX , lplY : LongInt) : HResult; stdcall;
begin
	result := idd^^.GetOverlayPosition(idd, lplX, lplY);
end;

function IDirectDrawSurface2_GetPalette(idd : IDirectDrawSurface2; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.GetPalette(idd, lplpDDPalette);
end;

function IDirectDrawSurface2_GetPixelFormat(idd : IDirectDrawSurface2; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
begin
	result := idd^^.GetPixelFormat(idd, lpDDPixelFormat);
end;

function IDirectDrawSurface2_GetSurfaceDesc(idd : IDirectDrawSurface2; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceDesc(idd, lpDDSurfaceDesc);
end;

function IDirectDrawSurface2_Initialize(idd : IDirectDrawSurface2; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, lpDDSurfaceDesc);
end;

function IDirectDrawSurface2_IsLost(idd : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^.IsLost(idd);
end;

function IDirectDrawSurface2_Lock(idd : IDirectDrawSurface2; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.Lock(idd, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent);
end;

function IDirectDrawSurface2_ReleaseDC(idd : IDirectDrawSurface2; hDC : Windows.HDC) : HResult; stdcall;
begin
	result := idd^^.ReleaseDC(idd, hDC);
end;

function IDirectDrawSurface2__Restore(idd : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^._Restore(idd);
end;

function IDirectDrawSurface2_SetClipper(idd : IDirectDrawSurface2; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.SetClipper(idd, lpDDClipper);
end;

function IDirectDrawSurface2_SetColorKey(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
begin
	result := idd^^.SetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface2_SetOverlayPosition(idd : IDirectDrawSurface2; lX , lY : LongInt) : HResult; stdcall;
begin
	result := idd^^.SetOverlayPosition(idd, lX, lY);
end;

function IDirectDrawSurface2_SetPalette(idd : IDirectDrawSurface2; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.SetPalette(idd, lpDDPalette);
end;

function IDirectDrawSurface2_Unlock(idd : IDirectDrawSurface2; lpSurfaceData : Pointer) : HResult; stdcall;
begin
	result := idd^^.Unlock(idd, lpSurfaceData);
end;

function IDirectDrawSurface2_UpdateOverlay(idd : IDirectDrawSurface2; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface2; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlay(idd, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx);
end;

function IDirectDrawSurface2_UpdateOverlayDisplay(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayDisplay(idd, dwFlags);
end;

function IDirectDrawSurface2_UpdateOverlayZOrder(idd : IDirectDrawSurface2; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface2) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayZOrder(idd, dwFlags, lpDDSReference);
end;

function IDirectDrawSurface2_GetDDInterface(idd : IDirectDrawSurface2; var lplpDD : IDirectDraw) : HResult; stdcall;
begin
	result := idd^^.GetDDInterface(idd, lplpDD);
end;

function IDirectDrawSurface2_PageLock(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageLock(idd, dwFlags);
end;

function IDirectDrawSurface2_PageUnlock(idd : IDirectDrawSurface2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageUnlock(idd, dwFlags);
end;


// IDirectDrawSurface3 interface methods

function IDirectDrawSurface3_QueryInterface(idd : IDirectDrawSurface3; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawSurface3_AddRef(idd : IDirectDrawSurface3) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawSurface3_Release(idd : IDirectDrawSurface3) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawSurface3_AddAttachedSurface(idd : IDirectDrawSurface3; lpDDSAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^.AddAttachedSurface(idd, lpDDSAttachedSurface);
end;

function IDirectDrawSurface3_AddOverlayDirtyRect(idd : IDirectDrawSurface3; const lpRect : TRect) : HResult; stdcall;
begin
	result := idd^^.AddOverlayDirtyRect(idd, lpRect);
end;

function IDirectDrawSurface3_Blt(idd : IDirectDrawSurface3; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface3; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
begin
	result := idd^^.Blt(idd, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx);
end;

function IDirectDrawSurface3_BltBatch(idd : IDirectDrawSurface3; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltBatch(idd, lpDDBltBatch, dwCount, dwFlags);
end;

function IDirectDrawSurface3_BltFast(idd : IDirectDrawSurface3; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface3; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltFast(idd, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans);
end;

function IDirectDrawSurface3_DeleteAttachedSurface(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^.DeleteAttachedSurface(idd, dwFlags, lpDDSAttachedSurface);
end;

function IDirectDrawSurface3_EnumAttachedSurfaces(idd : IDirectDrawSurface3; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumAttachedSurfaces(idd, lpContext, @lpEnumSurfacesCallback);
end;

function IDirectDrawSurface3_EnumOverlayZOrders(idd : IDirectDrawSurface3; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback) : HResult; stdcall;
begin
	result := idd^^.EnumOverlayZOrders(idd, dwFlags, lpContext, @lpfnCallback);
end;

function IDirectDrawSurface3_Flip(idd : IDirectDrawSurface3; lpDDSurfaceTargetOverride : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurfaceTargetOverride, dwFlags);
end;

function IDirectDrawSurface3_GetAttachedSurface(idd : IDirectDrawSurface3; var lpDDSCaps : TDDSCaps; var lplpDDAttachedSurface : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^.GetAttachedSurface(idd, lpDDSCaps, lplpDDAttachedSurface);
end;

function IDirectDrawSurface3_GetBltStatus(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetBltStatus(idd, dwFlags);
end;

function IDirectDrawSurface3_GetCaps(idd : IDirectDrawSurface3; var lpDDSCaps : TDDSCaps) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDSCaps);
end;

function IDirectDrawSurface3_GetClipper(idd : IDirectDrawSurface3; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.GetClipper(idd, lplpDDClipper);
end;

function IDirectDrawSurface3_GetColorKey(idd : IDirectDrawSurface3; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
begin
	result := idd^^.GetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface3_GetDC(idd : IDirectDrawSurface3; var lphDC : HDC) : HResult; stdcall;
begin
	result := idd^^.GetDC(idd, lphDC);
end;

function IDirectDrawSurface3_GetFlipStatus(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetFlipStatus(idd, dwFlags);
end;

function IDirectDrawSurface3_GetOverlayPosition(idd : IDirectDrawSurface3; var lplX , lplY : LongInt) : HResult; stdcall;
begin
	result := idd^^.GetOverlayPosition(idd, lplX, lplY);
end;

function IDirectDrawSurface3_GetPalette(idd : IDirectDrawSurface3; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.GetPalette(idd, lplpDDPalette);
end;

function IDirectDrawSurface3_GetPixelFormat(idd : IDirectDrawSurface3; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
begin
	result := idd^^.GetPixelFormat(idd, lpDDPixelFormat);
end;

function IDirectDrawSurface3_GetSurfaceDesc(idd : IDirectDrawSurface3; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceDesc(idd, lpDDSurfaceDesc);
end;

function IDirectDrawSurface3_Initialize(idd : IDirectDrawSurface3; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, lpDDSurfaceDesc);
end;

function IDirectDrawSurface3_IsLost(idd : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^.IsLost(idd);
end;

function IDirectDrawSurface3_Lock(idd : IDirectDrawSurface3; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.Lock(idd, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent);
end;

function IDirectDrawSurface3_ReleaseDC(idd : IDirectDrawSurface3; hDC : Windows.HDC) : HResult; stdcall;
begin
	result := idd^^.ReleaseDC(idd, hDC);
end;

function IDirectDrawSurface3__Restore(idd : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^._Restore(idd);
end;

function IDirectDrawSurface3_SetClipper(idd : IDirectDrawSurface3; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.SetClipper(idd, lpDDClipper);
end;

function IDirectDrawSurface3_SetColorKey(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
begin
	result := idd^^.SetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface3_SetOverlayPosition(idd : IDirectDrawSurface3; lX , lY : LongInt) : HResult; stdcall;
begin
	result := idd^^.SetOverlayPosition(idd, lX, lY);
end;

function IDirectDrawSurface3_SetPalette(idd : IDirectDrawSurface3; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.SetPalette(idd, lpDDPalette);
end;

function IDirectDrawSurface3_Unlock(idd : IDirectDrawSurface3; lpSurfaceData : Pointer) : HResult; stdcall;
begin
	result := idd^^.Unlock(idd, lpSurfaceData);
end;

function IDirectDrawSurface3_UpdateOverlay(idd : IDirectDrawSurface3; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface3; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlay(idd, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx);
end;

function IDirectDrawSurface3_UpdateOverlayDisplay(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayDisplay(idd, dwFlags);
end;

function IDirectDrawSurface3_UpdateOverlayZOrder(idd : IDirectDrawSurface3; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface3) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayZOrder(idd, dwFlags, lpDDSReference);
end;

function IDirectDrawSurface3_GetDDInterface(idd : IDirectDrawSurface3; var lplpDD : IDirectDraw) : HResult; stdcall;
begin
	result := idd^^.GetDDInterface(idd, lplpDD);
end;

function IDirectDrawSurface3_PageLock(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageLock(idd, dwFlags);
end;

function IDirectDrawSurface3_PageUnlock(idd : IDirectDrawSurface3; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageUnlock(idd, dwFlags);
end;

function IDirectDrawSurface3_SetSurfaceDesc(idd : IDirectDrawSurface3; const lpddsd : TDDSurfaceDesc; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetSurfaceDesc(idd, lpddsd, dwFlags);
end;


// IDirectDrawSurface4 interface methods

function IDirectDrawSurface4_QueryInterface(idd : IDirectDrawSurface4; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawSurface4_AddRef(idd : IDirectDrawSurface4) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawSurface4_Release(idd : IDirectDrawSurface4) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawSurface4_AddAttachedSurface(idd : IDirectDrawSurface4; lpDDSAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.AddAttachedSurface(idd, lpDDSAttachedSurface);
end;

function IDirectDrawSurface4_AddOverlayDirtyRect(idd : IDirectDrawSurface4; const lpRect : TRect) : HResult; stdcall;
begin
	result := idd^^.AddOverlayDirtyRect(idd, lpRect);
end;

function IDirectDrawSurface4_Blt(idd : IDirectDrawSurface4; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface4; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
begin
	result := idd^^.Blt(idd, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx);
end;

function IDirectDrawSurface4_BltBatch(idd : IDirectDrawSurface4; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltBatch(idd, lpDDBltBatch, dwCount, dwFlags);
end;

function IDirectDrawSurface4_BltFast(idd : IDirectDrawSurface4; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface4; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltFast(idd, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans);
end;

function IDirectDrawSurface4_DeleteAttachedSurface(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.DeleteAttachedSurface(idd, dwFlags, lpDDSAttachedSurface);
end;

function IDirectDrawSurface4_EnumAttachedSurfaces(idd : IDirectDrawSurface4; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
begin
	result := idd^^.EnumAttachedSurfaces(idd, lpContext, @lpEnumSurfacesCallback);
end;

function IDirectDrawSurface4_EnumOverlayZOrders(idd : IDirectDrawSurface4; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback2) : HResult; stdcall;
begin
	result := idd^^.EnumOverlayZOrders(idd, dwFlags, lpContext, @lpfnCallback);
end;

function IDirectDrawSurface4_Flip(idd : IDirectDrawSurface4; lpDDSurfaceTargetOverride : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurfaceTargetOverride, dwFlags);
end;

function IDirectDrawSurface4_GetAttachedSurface(idd : IDirectDrawSurface4; const lpDDSCaps : TDDSCaps2; var lplpDDAttachedSurface : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.GetAttachedSurface(idd, lpDDSCaps, lplpDDAttachedSurface);
end;

function IDirectDrawSurface4_GetBltStatus(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetBltStatus(idd, dwFlags);
end;

function IDirectDrawSurface4_GetCaps(idd : IDirectDrawSurface4; var lpDDSCaps : TDDSCaps2) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDSCaps);
end;

function IDirectDrawSurface4_GetClipper(idd : IDirectDrawSurface4; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.GetClipper(idd, lplpDDClipper);
end;

function IDirectDrawSurface4_GetColorKey(idd : IDirectDrawSurface4; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
begin
	result := idd^^.GetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface4_GetDC(idd : IDirectDrawSurface4; var lphDC : HDC) : HResult; stdcall;
begin
	result := idd^^.GetDC(idd, lphDC);
end;

function IDirectDrawSurface4_GetFlipStatus(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetFlipStatus(idd, dwFlags);
end;

function IDirectDrawSurface4_GetOverlayPosition(idd : IDirectDrawSurface4; var lplX , lplY : LongInt) : HResult; stdcall;
begin
	result := idd^^.GetOverlayPosition(idd, lplX, lplY);
end;

function IDirectDrawSurface4_GetPalette(idd : IDirectDrawSurface4; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.GetPalette(idd, lplpDDPalette);
end;

function IDirectDrawSurface4_GetPixelFormat(idd : IDirectDrawSurface4; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
begin
	result := idd^^.GetPixelFormat(idd, lpDDPixelFormat);
end;

function IDirectDrawSurface4_GetSurfaceDesc(idd : IDirectDrawSurface4; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceDesc(idd, lpDDSurfaceDesc);
end;

function IDirectDrawSurface4_Initialize(idd : IDirectDrawSurface4; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, lpDDSurfaceDesc);
end;

function IDirectDrawSurface4_IsLost(idd : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.IsLost(idd);
end;

function IDirectDrawSurface4_Lock(idd : IDirectDrawSurface4; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.Lock(idd, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent);
end;

function IDirectDrawSurface4_ReleaseDC(idd : IDirectDrawSurface4; hDC : Windows.HDC) : HResult; stdcall;
begin
	result := idd^^.ReleaseDC(idd, hDC);
end;

function IDirectDrawSurface4__Restore(idd : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^._Restore(idd);
end;

function IDirectDrawSurface4_SetClipper(idd : IDirectDrawSurface4; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.SetClipper(idd, lpDDClipper);
end;

function IDirectDrawSurface4_SetColorKey(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
begin
	result := idd^^.SetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface4_SetOverlayPosition(idd : IDirectDrawSurface4; lX , lY : LongInt) : HResult; stdcall;
begin
	result := idd^^.SetOverlayPosition(idd, lX, lY);
end;

function IDirectDrawSurface4_SetPalette(idd : IDirectDrawSurface4; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.SetPalette(idd, lpDDPalette);
end;

function IDirectDrawSurface4_Unlock(idd : IDirectDrawSurface4; lpRect : PRect) : HResult; stdcall;
begin
	result := idd^^.Unlock(idd, lpRect);
end;

function IDirectDrawSurface4_UpdateOverlay(idd : IDirectDrawSurface4; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface4; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlay(idd, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx);
end;

function IDirectDrawSurface4_UpdateOverlayDisplay(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayDisplay(idd, dwFlags);
end;

function IDirectDrawSurface4_UpdateOverlayZOrder(idd : IDirectDrawSurface4; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayZOrder(idd, dwFlags, lpDDSReference);
end;

function IDirectDrawSurface4_GetDDInterface(idd : IDirectDrawSurface4; var lplpDD : IUnknown) : HResult; stdcall;
begin
	result := idd^^.GetDDInterface(idd, lplpDD);
end;

function IDirectDrawSurface4_PageLock(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageLock(idd, dwFlags);
end;

function IDirectDrawSurface4_PageUnlock(idd : IDirectDrawSurface4; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageUnlock(idd, dwFlags);
end;

function IDirectDrawSurface4_SetSurfaceDesc(idd : IDirectDrawSurface4; const lpddsd2 : TDDSurfaceDesc2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetSurfaceDesc(idd, lpddsd2, dwFlags);
end;

function IDirectDrawSurface4_SetPrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID; lpData : pointer; cbSize : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetPrivateData(idd, guidTag, lpData, cbSize, dwFlags);
end;

function IDirectDrawSurface4_GetPrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID; lpBuffer : pointer; var lpcbBufferSize : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetPrivateData(idd, guidTag, lpBuffer, lpcbBufferSize);
end;

function IDirectDrawSurface4_FreePrivateData(idd : IDirectDrawSurface4; const guidTag : TGUID) : HResult; stdcall;
begin
	result := idd^^.FreePrivateData(idd, guidTag);
end;

function IDirectDrawSurface4_GetUniquenessValue(idd : IDirectDrawSurface4; var lpValue : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetUniquenessValue(idd, lpValue);
end;

function IDirectDrawSurface4_ChangeUniquenessValue(idd : IDirectDrawSurface4) : HResult; stdcall;
begin
	result := idd^^.ChangeUniquenessValue(idd);
end;


// IDirectDrawSurface7 interface methods

function IDirectDrawSurface7_QueryInterface(idd : IDirectDrawSurface7; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawSurface7_AddRef(idd : IDirectDrawSurface7) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawSurface7_Release(idd : IDirectDrawSurface7) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawSurface7_AddAttachedSurface(idd : IDirectDrawSurface7; lpDDSAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.AddAttachedSurface(idd, lpDDSAttachedSurface);
end;

function IDirectDrawSurface7_AddOverlayDirtyRect(idd : IDirectDrawSurface7; const lpRect : TRect) : HResult; stdcall;
begin
	result := idd^^.AddOverlayDirtyRect(idd, lpRect);
end;

function IDirectDrawSurface7_Blt(idd : IDirectDrawSurface7; lpDestRect : PRect; lpDDSrcSurface : IDirectDrawSurface7; lpSrcRect : PRect; dwFlags : DWORD; lpDDBltFx : PDDBltFX) : HResult; stdcall;
begin
	result := idd^^.Blt(idd, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx);
end;

function IDirectDrawSurface7_BltBatch(idd : IDirectDrawSurface7; const lpDDBltBatch : TDDBltBatch; dwCount : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltBatch(idd, lpDDBltBatch, dwCount, dwFlags);
end;

function IDirectDrawSurface7_BltFast(idd : IDirectDrawSurface7; dwX : DWORD; dwY : DWORD; lpDDSrcSurface : IDirectDrawSurface7; lpSrcRect : PRect; dwTrans : DWORD) : HResult; stdcall;
begin
	result := idd^^.BltFast(idd, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans);
end;

function IDirectDrawSurface7_DeleteAttachedSurface(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDSAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.DeleteAttachedSurface(idd, dwFlags, lpDDSAttachedSurface);
end;

function IDirectDrawSurface7_EnumAttachedSurfaces(idd : IDirectDrawSurface7; lpContext : Pointer; lpEnumSurfacesCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
begin
	result := idd^^.EnumAttachedSurfaces(idd, lpContext, @lpEnumSurfacesCallback);
end;

function IDirectDrawSurface7_EnumOverlayZOrders(idd : IDirectDrawSurface7; dwFlags : DWORD; lpContext : Pointer; lpfnCallback : TDDEnumSurfacesCallback7) : HResult; stdcall;
begin
	result := idd^^.EnumOverlayZOrders(idd, dwFlags, lpContext, @lpfnCallback);
end;

function IDirectDrawSurface7_Flip(idd : IDirectDrawSurface7; lpDDSurfaceTargetOverride : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurfaceTargetOverride, dwFlags);
end;

function IDirectDrawSurface7_GetAttachedSurface(idd : IDirectDrawSurface7; const lpDDSCaps : TDDSCaps2; var lplpDDAttachedSurface : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.GetAttachedSurface(idd, lpDDSCaps, lplpDDAttachedSurface);
end;

function IDirectDrawSurface7_GetBltStatus(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetBltStatus(idd, dwFlags);
end;

function IDirectDrawSurface7_GetCaps(idd : IDirectDrawSurface7; var lpDDSCaps : TDDSCaps2) : HResult; stdcall;
begin
	result := idd^^.GetCaps(idd, lpDDSCaps);
end;

function IDirectDrawSurface7_GetClipper(idd : IDirectDrawSurface7; var lplpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.GetClipper(idd, lplpDDClipper);
end;

function IDirectDrawSurface7_GetColorKey(idd : IDirectDrawSurface7; dwFlags : DWORD; var lpDDColorKey : TDDColorKey) : HResult; stdcall;
begin
	result := idd^^.GetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface7_GetDC(idd : IDirectDrawSurface7; var lphDC : HDC) : HResult; stdcall;
begin
	result := idd^^.GetDC(idd, lphDC);
end;

function IDirectDrawSurface7_GetFlipStatus(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetFlipStatus(idd, dwFlags);
end;

function IDirectDrawSurface7_GetOverlayPosition(idd : IDirectDrawSurface7; var lplX , lplY : LongInt) : HResult; stdcall;
begin
	result := idd^^.GetOverlayPosition(idd, lplX, lplY);
end;

function IDirectDrawSurface7_GetPalette(idd : IDirectDrawSurface7; var lplpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.GetPalette(idd, lplpDDPalette);
end;

function IDirectDrawSurface7_GetPixelFormat(idd : IDirectDrawSurface7; var lpDDPixelFormat : TDDPixelFormat) : HResult; stdcall;
begin
	result := idd^^.GetPixelFormat(idd, lpDDPixelFormat);
end;

function IDirectDrawSurface7_GetSurfaceDesc(idd : IDirectDrawSurface7; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.GetSurfaceDesc(idd, lpDDSurfaceDesc);
end;

function IDirectDrawSurface7_Initialize(idd : IDirectDrawSurface7; lpDD : IDirectDraw; var lpDDSurfaceDesc : TDDSurfaceDesc2) : HResult; stdcall;
begin
	result := idd^^.Initialize(idd, lpDD, lpDDSurfaceDesc);
end;

function IDirectDrawSurface7_IsLost(idd : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.IsLost(idd);
end;

function IDirectDrawSurface7_Lock(idd : IDirectDrawSurface7; lpDestRect : PRect; var lpDDSurfaceDesc : TDDSurfaceDesc2; dwFlags : DWORD; hEvent : THandle) : HResult; stdcall;
begin
	result := idd^^.Lock(idd, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent);
end;

function IDirectDrawSurface7_ReleaseDC(idd : IDirectDrawSurface7; hDC : Windows.HDC) : HResult; stdcall;
begin
	result := idd^^.ReleaseDC(idd, hDC);
end;

function IDirectDrawSurface7__Restore(idd : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^._Restore(idd);
end;

function IDirectDrawSurface7_SetClipper(idd : IDirectDrawSurface7; lpDDClipper : IDirectDrawClipper) : HResult; stdcall;
begin
	result := idd^^.SetClipper(idd, lpDDClipper);
end;

function IDirectDrawSurface7_SetColorKey(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDColorKey : PDDColorKey) : HResult; stdcall;
begin
	result := idd^^.SetColorKey(idd, dwFlags, lpDDColorKey);
end;

function IDirectDrawSurface7_SetOverlayPosition(idd : IDirectDrawSurface7; lX , lY : LongInt) : HResult; stdcall;
begin
	result := idd^^.SetOverlayPosition(idd, lX, lY);
end;

function IDirectDrawSurface7_SetPalette(idd : IDirectDrawSurface7; lpDDPalette : IDirectDrawPalette) : HResult; stdcall;
begin
	result := idd^^.SetPalette(idd, lpDDPalette);
end;

function IDirectDrawSurface7_Unlock(idd : IDirectDrawSurface7; lpRect : PRect) : HResult; stdcall;
begin
	result := idd^^.Unlock(idd, lpRect);
end;

function IDirectDrawSurface7_UpdateOverlay(idd : IDirectDrawSurface7; lpSrcRect : PRect; lpDDDestSurface : IDirectDrawSurface7; lpDestRect : PRect; dwFlags : DWORD; lpDDOverlayFx : PDDOverlayFX) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlay(idd, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx);
end;

function IDirectDrawSurface7_UpdateOverlayDisplay(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayDisplay(idd, dwFlags);
end;

function IDirectDrawSurface7_UpdateOverlayZOrder(idd : IDirectDrawSurface7; dwFlags : DWORD; lpDDSReference : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.UpdateOverlayZOrder(idd, dwFlags, lpDDSReference);
end;

function IDirectDrawSurface7_GetDDInterface(idd : IDirectDrawSurface7; var lplpDD : IUnknown) : HResult; stdcall;
begin
	result := idd^^.GetDDInterface(idd, lplpDD);
end;

function IDirectDrawSurface7_PageLock(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageLock(idd, dwFlags);
end;

function IDirectDrawSurface7_PageUnlock(idd : IDirectDrawSurface7; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.PageUnlock(idd, dwFlags);
end;

function IDirectDrawSurface7_SetSurfaceDesc(idd : IDirectDrawSurface7; const lpddsd2 : TDDSurfaceDesc2; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetSurfaceDesc(idd, lpddsd2, dwFlags);
end;

function IDirectDrawSurface7_SetPrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID; lpData : pointer; cbSize : DWORD; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetPrivateData(idd, guidTag, lpData, cbSize, dwFlags);
end;

function IDirectDrawSurface7_GetPrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID; lpBuffer : pointer; var lpcbBufferSize : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetPrivateData(idd, guidTag, lpBuffer, lpcbBufferSize);
end;

function IDirectDrawSurface7_FreePrivateData(idd : IDirectDrawSurface7; const guidTag : TGUID) : HResult; stdcall;
begin
	result := idd^^.FreePrivateData(idd, guidTag);
end;

function IDirectDrawSurface7_GetUniquenessValue(idd : IDirectDrawSurface7; var lpValue : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetUniquenessValue(idd, lpValue);
end;

function IDirectDrawSurface7_ChangeUniquenessValue(idd : IDirectDrawSurface7) : HResult; stdcall;
begin
	result := idd^^.ChangeUniquenessValue(idd);
end;

function IDirectDrawSurface7_SetPriority(idd : IDirectDrawSurface7; dwPriority : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetPriority(idd, dwPriority);
end;

function IDirectDrawSurface7_GetPriority(idd : IDirectDrawSurface7; var lpdwPriority : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetPriority(idd, lpdwPriority);
end;

function IDirectDrawSurface7_SetLOD(idd : IDirectDrawSurface7; dwMaxLOD : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetLOD(idd, dwMaxLOD);
end;

function IDirectDrawSurface7_GetLOD(idd : IDirectDrawSurface7; var lpdwMaxLOD : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetLOD(idd, lpdwMaxLOD);
end;


// IDirectDrawColorControl interface methods

function IDirectDrawColorControl_QueryInterface(idd : IDirectDrawColorControl; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawColorControl_AddRef(idd : IDirectDrawColorControl) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawColorControl_Release(idd : IDirectDrawColorControl) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawColorControl_GetColorControls(idd : IDirectDrawColorControl; var lpColorControl : TDDColorControl) : HResult; stdcall;
begin
	result := idd^^.GetColorControls(idd, lpColorControl);
end;

function IDirectDrawColorControl_SetColorControls(idd : IDirectDrawColorControl; const lpColorControl : TDDColorControl) : HResult; stdcall;
begin
	result := idd^^.SetColorControls(idd, lpColorControl);
end;


// IDirectDrawGammaControl interface methods

function IDirectDrawGammaControl_QueryInterface(idd : IDirectDrawGammaControl; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawGammaControl_AddRef(idd : IDirectDrawGammaControl) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawGammaControl_Release(idd : IDirectDrawGammaControl) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawGammaControl_GetGammaRamp(idd : IDirectDrawGammaControl; dwFlags : DWORD; var lpRampData : TDDGammaRamp) : HResult; stdcall;
begin
	result := idd^^.GetGammaRamp(idd, dwFlags, lpRampData);
end;

function IDirectDrawGammaControl_SetGammaRamp(idd : IDirectDrawGammaControl; dwFlags : DWORD; const lpRampData : TDDGammaRamp) : HResult; stdcall;
begin
	result := idd^^.SetGammaRamp(idd, dwFlags, lpRampData);
end;


// IDirectDrawVideoPort interface methods

function IDirectDrawVideoPort_QueryInterface(idd : IDirectDrawVideoPort; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDirectDrawVideoPort_AddRef(idd : IDirectDrawVideoPort) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDirectDrawVideoPort_Release(idd : IDirectDrawVideoPort) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDirectDrawVideoPort_Flip(idd : IDirectDrawVideoPort; lpDDSurface : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.Flip(idd, lpDDSurface, dwFlags);
end;

function IDirectDrawVideoPort_GetBandwidthInfo(idd : IDirectDrawVideoPort; var lpddpfFormat : TDDPixelFormat; dwWidth : DWORD; dwHeight : DWORD; dwFlags : DWORD; var lpBandwidth : TDDVideoPortBandWidth) : HResult; stdcall;
begin
	result := idd^^.GetBandwidthInfo(idd, lpddpfFormat, dwWidth, dwHeight, dwFlags, lpBandwidth);
end;

function IDirectDrawVideoPort_GetColorControls(idd : IDirectDrawVideoPort; var lpColorControl : TDDColorControl) : HResult; stdcall;
begin
	result := idd^^.GetColorControls(idd, lpColorControl);
end;

function IDirectDrawVideoPort_GetInputFormats(idd : IDirectDrawVideoPort; var lpNumFormats : DWORD; var lpFormats : TDDPixelFormat; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetInputFormats(idd, lpNumFormats, lpFormats, dwFlags);
end;

function IDirectDrawVideoPort_GetOutputFormats(idd : IDirectDrawVideoPort; var lpInputFormat : TDDPixelFormat; var lpNumFormats : DWORD; lpFormats : PDDPixelFormat; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetOutputFormats(idd, lpInputFormat, lpNumFormats, lpFormats, dwFlags);
end;

function IDirectDrawVideoPort_GetFieldPolarity(idd : IDirectDrawVideoPort; var lpbVideoField : BOOL) : HResult; stdcall;
begin
	result := idd^^.GetFieldPolarity(idd, lpbVideoField);
end;

function IDirectDrawVideoPort_GetVideoLine(idd : IDirectDrawVideoPort; var lpdwLine : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetVideoLine(idd, lpdwLine);
end;

function IDirectDrawVideoPort_GetVideoSignalStatus(idd : IDirectDrawVideoPort; varlpdwStatus : DWORD) : HResult; stdcall;
begin
	result := idd^^.GetVideoSignalStatus(idd, varlpdwStatus);
end;

function IDirectDrawVideoPort_SetColorControls(idd : IDirectDrawVideoPort; var lpColorControl : TDDColorControl) : HResult; stdcall;
begin
	result := idd^^.SetColorControls(idd, lpColorControl);
end;

function IDirectDrawVideoPort_SetTargetSurface(idd : IDirectDrawVideoPort; lpDDSurface : IDirectDrawSurface; dwFlags : DWORD) : HResult; stdcall;
begin
	result := idd^^.SetTargetSurface(idd, lpDDSurface, dwFlags);
end;

function IDirectDrawVideoPort_StartVideo(idd : IDirectDrawVideoPort; var lpVideoInfo : TDDVideoPortInfo) : HResult; stdcall;
begin
	result := idd^^.StartVideo(idd, lpVideoInfo);
end;

function IDirectDrawVideoPort_StopVideo(idd : IDirectDrawVideoPort) : HResult; stdcall;
begin
	result := idd^^.StopVideo(idd);
end;

function IDirectDrawVideoPort_UpdateVideo(idd : IDirectDrawVideoPort; var lpVideoInfo : TDDVideoPortInfo) : HResult; stdcall;
begin
	result := idd^^.UpdateVideo(idd, lpVideoInfo);
end;

function IDirectDrawVideoPort_WaitForSync(idd : IDirectDrawVideoPort; dwFlags : DWORD; dwLine : DWORD; dwTimeout : DWORD) : HResult; stdcall;
begin
	result := idd^^.WaitForSync(idd, dwFlags, dwLine, dwTimeout);
end;


// IDDVideoPortContainer interface methods

function IDDVideoPortContainer_QueryInterface(idd : IDDVideoPortContainer; const IID : TGUID; var obj) : HRESULT; stdcall;
begin
	result := idd^^.QueryInterface(idd, IID, obj);
end;

function IDDVideoPortContainer_AddRef(idd : IDDVideoPortContainer) : Longint; stdcall;
begin
	result := idd^^.AddRef(idd);
end;

function IDDVideoPortContainer_Release(idd : IDDVideoPortContainer) : Longint; stdcall;
begin
	result := idd^^.Release(idd);
end;

function IDDVideoPortContainer_CreateVideoPort(idd : IDDVideoPortContainer; dwFlags : DWORD; var lpTDDVideoPortDesc : TDDVideoPortDesc; var lplpDDVideoPort : IDirectDrawVideoPort; pUnkOuter : IUnknown) : HResult; stdcall;
begin
	result := idd^^.CreateVideoPort(idd, dwFlags, lpTDDVideoPortDesc, lplpDDVideoPort, pUnkOuter);
end;

function IDDVideoPortContainer_EnumVideoPorts(idd : IDDVideoPortContainer; dwFlags : DWORD; lpTDDVideoPortCaps : PDDVideoPortCaps; lpContext : Pointer; lpEnumVideoCallback : TDDEnumVideoCallback) : HResult; stdcall;
begin
	result := idd^^.EnumVideoPorts(idd, dwFlags, lpTDDVideoPortCaps, lpContext, @lpEnumVideoCallback);
end;

function IDDVideoPortContainer_GetVideoPortConnectInfo(idd : IDDVideoPortContainer; dwPortId : DWORD; var lpNumEntries : DWORD; lpConnectInfo : PDDVideoPortConnect) : HResult; stdcall;
begin
	result := idd^^.GetVideoPortConnectInfo(idd, dwPortId, lpNumEntries, lpConnectInfo);
end;

function IDDVideoPortContainer_QueryVideoPortStatus(idd : IDDVideoPortContainer; dwPortId : DWORD; var lpVPStatus : TDDVideoPortStatus) : HResult; stdcall;
begin
	result := idd^^.QueryVideoPortStatus(idd, dwPortId, lpVPStatus);
end;


begin
end.
