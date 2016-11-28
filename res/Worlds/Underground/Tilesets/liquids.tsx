<?xml version="1.0" encoding="UTF-8"?>
<tileset name="liquids" tilewidth="16" tileheight="16" spacing="1" tilecount="12" columns="6">
 <properties>
  <property name="nonsolid" type="bool" value="true"/>
 </properties>
 <image source="liquids.png" width="101" height="33"/>
 <tile id="0">
  <animation>
   <frame tileid="0" duration="150"/>
   <frame tileid="1" duration="150"/>
   <frame tileid="2" duration="150"/>
  </animation>
 </tile>
 <tile id="1">
  <animation>
   <frame tileid="1" duration="150"/>
   <frame tileid="2" duration="150"/>
   <frame tileid="0" duration="150"/>
  </animation>
 </tile>
 <tile id="2">
  <animation>
   <frame tileid="2" duration="150"/>
   <frame tileid="0" duration="150"/>
   <frame tileid="1" duration="150"/>
  </animation>
 </tile>
 <tile id="3">
  <animation>
   <frame tileid="3" duration="150"/>
   <frame tileid="4" duration="150"/>
   <frame tileid="5" duration="150"/>
  </animation>
 </tile>
 <tile id="4">
  <animation>
   <frame tileid="4" duration="150"/>
   <frame tileid="5" duration="150"/>
   <frame tileid="3" duration="150"/>
  </animation>
 </tile>
 <tile id="5">
  <animation>
   <frame tileid="5" duration="150"/>
   <frame tileid="3" duration="150"/>
   <frame tileid="4" duration="150"/>
  </animation>
 </tile>
</tileset>
