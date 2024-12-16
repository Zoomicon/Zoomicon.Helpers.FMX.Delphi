//Description: ActionList utilities for FMX
//Author: George Birbilis (http://zoomicon.com)

unit Zoomicon.Helpers.FMX.ActnList;

interface

  function SafeTextToShortCut(const Text: string): Integer; //Fixing Delphi's 11.1 TextToShortcut which returns -1 when platform doesn't support the check (e.g. on Android) instead of 0 (which is what TAction.Shortcut expects for no-shortcut). Delphi 12.2 seems to have this fixed, returning 0 in that case

implementation
  uses
    System.Math,
    FMX.ActnList;

  function SafeTextToShortCut(const Text: string): Integer;
  begin
    result := Max(TextToShortCut(Text), 0); //Fixing Delphi's 11.1 TextToShortcut which returns -1 when platform doesn't support the check (e.g. on Android) instead of 0 (which is what TAction.Shortcut expects for no-shortcut). Delphi 12.2 seems to have this fixed, returning 0 in that case
  end;

end.

