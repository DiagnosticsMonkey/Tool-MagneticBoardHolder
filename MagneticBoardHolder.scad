/* [Style] */
// Style
Style = "3"; // [1:Single, 2:Support, 3:Double]

/* [Common Dimensions] */
// Magnet Diameter (mm)
MagnetDiameter = 8;
// Magnet Height (mm)
MagnetHeight = 3;
// Magnet Slop (mm)
MagnetSlop = 0.1;
// Holder height
BoardZ = 20;
// WallTh
WallTh = 1;

/* [Holder Cone] */
// Board Stack
StackUp = 1.6;
// Shelf
Shelf = 2;
// ConeExtension
ConeExtension = 1;
// Attack angle of cone
ConeAngle = 45;
// Top Surface Style
TopSurfaceStyle = "2"; // [1:Flat, 2:Cone, 3:Pin]
// Top Feature Height
TopFeatureHeight = 3.2;
// Top Feature D
TopFeatureD = 2;
// Top Feature Cone Base
TopFeatureConeBase = 5;

/* [Support Cone] */
// Length of the support cone
SupportConeHeight = 4;
// Diameter of the support cone point
SupportConeTopD = 2;

/* [Corner Holder] */
// Distance between post centres
Span = 30;
// Height of the span
SpanHeight = 10;
// Cable clamp D
CableD = 6;

// ###########################################

/* [Hidden] */
RenderCludge = 0.01; // Cludge to tidy up rendering interface
$fn=120;

// Calculated Params
OD = MagnetDiameter + MagnetSlop + (2*WallTh);

// ###########################################

module CylinderWithMag(CylD, CylZ)
{
   difference()
   {
      cylinder(d = CylD, h = CylZ); // Main body
         translate([0,0,-RenderCludge])
            cylinder(d = MagnetDiameter + MagnetSlop, h = MagnetHeight); // Mag cutout
   }
}

module Holder()
{
   // ###########################################
   
   ConeHeight = StackUp + ConeExtension;
   ID = OD - 2*Shelf;
   ConeExpansion = ConeHeight * sin(ConeAngle); // Calc adjustment to cone for attack angle
   ConeD = ID + 2*ConeExpansion;
   
   // ###########################################
   
   union()
   {
      CylinderWithMag(OD, BoardZ);
      
      translate([0, 0, BoardZ])
      {
         cylinder(d1 = ID, d2 = ConeD, h = ConeHeight); // Bang a cone on for holding board to shelf
         if (TopSurfaceStyle == "2") // Cone
         {
            translate([0, 0, ConeHeight])
               cylinder(d1 = TopFeatureConeBase, d2 = TopFeatureD, h = TopFeatureHeight); // Bang a cone on for mounting holes
         }
         else if (TopSurfaceStyle == "3") // Pin
         {
            translate([0, 0, ConeHeight])
               cylinder(d = TopFeatureD, h = TopFeatureHeight); // Bang a cone on for mounting holes
         }
      }
   }
}

module Support()
{
   // ###########################################
   
   SupportBaseHeight = BoardZ - SupportConeHeight;
   ID = OD - 2*Shelf;
   
   // ###########################################
   
   union()
   {
      CylinderWithMag(OD, SupportBaseHeight);
      
      translate([0, 0, SupportBaseHeight])
      {
        cylinder(d1 = OD, d2 = SupportConeTopD, h = SupportConeHeight); // Bring support to point for easy positioning between components
      }
   }
}

module Double()
{
   difference()
   {
      difference()
      {
         union()
         {
            translate([-OD/2, 0, 0])
               cube([OD, Span, SpanHeight]);
            Holder();
            translate([0, Span, 0])
               Holder();
         }
         
         // Is there a better way to cut these magnets out rather than repeating the process? Yes!
         // Can I be bothered? No!
         translate([0,0,-RenderCludge])
            cylinder(d = MagnetDiameter + MagnetSlop, h = MagnetHeight); // Mag cutout
         translate([0, Span, -RenderCludge])
            cylinder(d = MagnetDiameter + MagnetSlop, h = MagnetHeight); // Mag cutout
      }
      
      translate([-OD/2 - RenderCludge,Span/2,0])
         rotate([0,90,0])
            cylinder(d = CableD * 2, h=OD + 2*RenderCludge);
   }
}

if( Style == "1" )
{
   Holder();
}
else if( Style == "2" )
{
   Support();
}
else if( Style == "3" )
{
   Double();
}
