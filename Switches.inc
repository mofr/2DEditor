{*****************************************************************************}
{* SWITCHES.INC                                                              *}
{*                                                                           *}
{* Defines several compiler switches for the different supported compiler    *}
{* platforms                                                                 *}
{*                                                                           *}
{*****************************************************************************}

// Write the required DX version here. DX3, DX5, DX6 and DX7 are available.
// A later version always includes the former ones.

{$DEFINE DIRECTX6}

// Assume Delphi3+ compiler
{$DEFINE DELPHI}

// FPC requires classes workaround for interfaces
{$IFDEF FPC}
{$ASMMODE INTEL}
{$UNDEF DELPHI}
{$DEFINE D2COM}
{$MODE DELPHI}
{$PACKRECORDS 4}
{$H+}
{$ENDIF}

// Standard Delphi switches
{$IFDEF DELPHI}
{$ALIGN ON}
{$MINENUMSIZE 4}
{$ENDIF}

// Delphi2 specific
{$IFDEF VER90}
{$DEFINE D2COM}
{$ENDIF}
