<?xml version="1.0" encoding="UTF-8"?>
<tileset name="mountain_foreground" tilewidth="16" tileheight="16" tilecount="50" columns="10">
 <image source="mountain_foreground.png" width="160" height="95"/>
 <terraintypes>
  <terrain name="solid" tile="-1"/>
 </terraintypes>
 <tile id="0" terrain=",,,0"/>
 <tile id="3" terrain=",,0,0"/>
 <tile id="4" terrain=",,0,"/>
 <tile id="10" terrain=",0,,0"/>
 <tile id="11" terrain="0,0,0,"/>
 <tile id="12" terrain="0,0,,0"/>
 <tile id="13" terrain="0,0,0,0"/>
 <tile id="14" terrain="0,,0,"/>
 <tile id="21" terrain="0,,0,0"/>
 <tile id="22" terrain=",0,0,0"/>
 <tile id="30" terrain=",0,,"/>
 <tile id="33" terrain="0,0,,"/>
 <tile id="34" terrain="0,,,"/>
 <tile id="40" probability="0">
  <objectgroup draworder="index">
   <object id="1" x="0" y="16">
    <polygon points="0,0 16,-8 16,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="41" probability="0">
  <objectgroup draworder="index">
   <object id="1" x="0" y="8">
    <polygon points="0,0 16,-8 16,8 0,8"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="42" probability="0">
  <objectgroup draworder="index">
   <object id="1" x="0" y="0">
    <polygon points="0,0 16,8 16,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="43" probability="0">
  <objectgroup draworder="index">
   <object id="1" x="0" y="8">
    <polygon points="0,0 16,8 0,8"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="44" terrain=",,,0" probability="0">
  <objectgroup draworder="index">
   <object id="1" x="0" y="16">
    <polygon points="0,0 16,-16 16,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="45" terrain=",,0," probability="0">
  <objectgroup draworder="index">
   <object id="2" x="0" y="0">
    <polygon points="0,0 16,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
</tileset>
