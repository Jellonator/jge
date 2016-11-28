<?xml version="1.0" encoding="UTF-8"?>
<tileset name="trees" tilewidth="16" tileheight="16" tilecount="60" columns="10">
 <image source="trees.png" width="160" height="96"/>
 <terraintypes>
  <terrain name="solid" tile="-1"/>
 </terraintypes>
 <tile id="0" terrain=",,,0">
  <objectgroup draworder="index">
   <object id="1" x="16" y="0">
    <polygon points="0,0 0,16 -12,16 -12,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="1" terrain=",,0,0"/>
 <tile id="2" terrain=",,0,0"/>
 <tile id="4" terrain=",,0,">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 12,0 12,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="6">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 16,0 16,8 0,8"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="10" terrain=",0,,0">
  <objectgroup draworder="index">
   <object id="1" x="16" y="0">
    <polygon points="0,0 -12,0 -12,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="11" terrain="0,0,0,"/>
 <tile id="12" terrain="0,0,,0"/>
 <tile id="13" terrain="0,0,0,0"/>
 <tile id="14" terrain="0,,0,">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 12,0 12,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="15">
  <objectgroup draworder="index">
   <object id="1" x="4" y="16">
    <polygon points="0,0 0,-16 8,-16 8,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="20">
  <objectgroup draworder="index">
   <object id="1" x="16" y="0">
    <polygon points="0,0 -12,0 -12,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="21" terrain="0,,0,0"/>
 <tile id="22" terrain=",0,0,0"/>
 <tile id="23" terrain="0,0,0,0" probability="0.125"/>
 <tile id="24">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 12,0 12,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="25">
  <objectgroup draworder="index">
   <object id="1" x="4" y="0">
    <polygon points="0,0 8,0 8,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="30" terrain=",0,,"/>
 <tile id="31" terrain="0,0,,"/>
 <tile id="34" terrain="0,,,"/>
 <tile id="44">
  <objectgroup draworder="index">
   <object id="1" x="0" y="16">
    <polygon points="0,0 16,-16 16,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="45">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 16,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
</tileset>
