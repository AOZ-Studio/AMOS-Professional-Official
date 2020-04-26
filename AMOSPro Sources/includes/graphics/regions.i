	IFND	GRAPHICS_REGIONS_I
GRAPHICS_REGIONS_I	SET	1
**
**	$Filename: graphics/regions.i $
**	$Release: 1.3 $
**
**	
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

   IFND	 GRAPHICS_GFX_I
   include  "graphics/gfx.i"
   ENDC

    STRUCTURE	Region,0
      STRUCT   rg_bounds,ra_SIZEOF
      APTR  rg_RegionRectangle
   LABEL    rg_SIZEOF

   STRUCTURE   RegionRectangle,0
      APTR  rr_Next
      APTR  rr_Prev
      STRUCT   rr_bounds,ra_SIZEOF
   LABEL    rr_SIZEOF

	ENDC	; GRAPHICS_REGIONS_I
