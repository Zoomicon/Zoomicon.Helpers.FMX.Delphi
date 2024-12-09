unit Zoomicon.Helpers.FMX.Memo.MemoHelpers;

interface
  uses
    System.Types, //for TSizeF
    FMX.Memo; //for TMemo

  type

    TMemoHelper = class helper for TMemo
    public
      class var DisableFontSizeToFit : boolean; //=false (class variables are auto-initialized, not need to use class constructor for that)

      procedure SetFontSizeToFit(var LastFontFitSize: TSizeF);
    end;

implementation

  procedure TMemoHelper.SetFontSizeToFit(var LastFontFitSize: TSizeF); //TODO: add logging
  //const
    //Offset = 0; //The diference between ContentBounds and ContentLayout //TODO: info coming from https://stackoverflow.com/a/21993017/903783 - need to verify
  begin
    if DisableFontSizeToFit then exit;

    {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    // Temporarily enable AutoCalculateContentSize if it's disabled
    var LOriginalAutoCalc := AutoCalculateContentSize;
    if not LOriginalAutoCalc then
      AutoCalculateContentSize := True; //TODO: !!! Setting to true may be causing text to disappear !!!
    {$ENDIF}

    try
      {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      UpdateContentSize; //Recalculates content bounds of a scroll box. Does not calculate content bounds if AutoCalculateContentSize is False or if the state of the scroll box is csLoading or csDestroying
      {$ENDIF}

      const Offset = 10 {* AbsoluteScale.Y}; //TODO: not very good
      const LHeight = Height;
      if (LHeight = 0) {or (Size.Size = LastFontFitSize)} then //TODO: should we use this again?
        exit; //don't calculate font autofit based on probably not yet available height information, nor when AMemo.Height didn't change from last calculation

      //Font.Size := 12; //Don't set initial font size, use the current one (which may be from a previous calculation - this speeds up when resizing and also fixes glitches when loading saved state if recalculation isn't done for some reason after loading)

      var LContentBoundsHeight := ContentBounds.Height;
      if (LContentBoundsHeight = 0) then //must check, else first while will loop for ever since ContentBounds.Height is 0 on load
        exit;

      var LFontSize := Font.Size;
      LastFontFitSize := Size.Size;

      //make font bigger
      while (LContentBoundsHeight + Offset < LHeight) do //using WordWrap, not checking for Width
      begin
        LFontSize := LFontSize + 1;
        Font.Size := LFontSize;

        {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
        UpdateContentSize;
        {$ENDIF}

        var LContentBoundsNewHeight := ContentBounds.Height;
        if LContentBoundsNewHeight = LContentBoundsHeight then
        begin
          Font.Size := LFontSize - 1; //undo font size increase since it had no effect
          exit; //TODO: See why changing Font.Size doesn't affect ContentBounds in Android implementation so we get an infinite loop (Height is never reached)
        end;
        LContentBoundsHeight := LContentBoundsNewHeight;
      end;

      //make font smaller
      while (LContentBoundsHeight + Offset > LHeight) do //using WordWrap, not checking for Width
      begin
        LFontSize := LFontSize - 1;
        Font.Size := LFontSize;

        {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
        UpdateContentSize;
        {$ENDIF}

        var LContentBoundsNewHeight := ContentBounds.Height;
        if LContentBoundsNewHeight = LContentBoundsHeight then
        begin
          Font.Size := LFontSize + 1; //undo font size decrease since it had no effect
          exit; //TODO: See why changing Font.Size doesn't affect ContentBounds in Android implementation so we get an infinite loop (Height is never reached)
        end;
        LContentBoundsHeight := LContentBoundsNewHeight;
      end;
    finally
      {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      // Restore the original AutoCalculateContentSize value Self.AutoCalculateContentSize := OriginalAutoCalc;
      AutoCalculateContentSize := LOriginalAutoCalc;
      {$ENDIF}
    end;

  end;

end.
