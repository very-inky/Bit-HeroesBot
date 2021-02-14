
;User config
RaidTier = 3
RaidDifficulty = 3

pvpstrip = true
pvpstripitems = ;literally have no idea how to implement this?!!!!
pvpdifficulty = 5
;PVP difficulties 3, 4, and 5 are supported
pvpopponent = 1
;
AutoUse = true
AutoBestTeam = true




;Dont change these variables!
;Not configurable!
Raidcheck = 0
Pvpcheck = 0
pvpteam = 0
Energycheck = 0
Worldboss = 0
Trialgauntlet = 0
bountiescheck = 0




;===== Copy The Following Functions To Your Own Code Just once =====


;--------------------------------
;  FindText - Capture screen image into text and then find it
;--------------------------------
;    returnArray := FindText(
;      X1 --> the search scope's upper left corner X coordinates
;    , Y1 --> the search scope's upper left corner Y coordinates
;    , X2 --> the search scope's lower right corner X coordinates
;    , Y2 --> the search scope's lower right corner Y coordinates
;    , err1 --> Fault tolerance percentage of text       (0.1=10%)
;    , err0 --> Fault tolerance percentage of background (0.1=10%)
;    , Text --> can be a lot of text parsed into images, separated by "|"
;    , ScreenShot --> if the value is 0, the last screenshot will be used
;    , FindAll --> if the value is 0, Just find one result and return
;    , JoinText --> if the value is 1, Join all Text for combination lookup
;    , offsetX --> Set the max text offset (X) for combination lookup
;    , offsetY --> Set the max text offset (Y) for combination lookup
;    , dir --> Four directions for searching: up, down, left and right
;  )
;
;  The function returns a second-order array containing
;  all lookup results, Any result is an associative array
;  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
;  if no image is found, the function returns 0.
;  All coordinates are relative to Screen, colors are in RGB format
;
;  If the return variable is set to "ok", ok.1 is the first result found.
;  Where ok.1.1 is the X coordinate of the upper left corner of the found image,
;  and ok.1.2 is the Y coordinate of the upper left corner of the found image,
;  ok.1.3 is the width of the found image, and ok.1.4 is the height of the found image,
;  ok.1.x <==> ok.1.1+ok.1.3//2 ( is the Center X coordinate of the found image ),
;  ok.1.y <==> ok.1.2+ok.1.4//2 ( is the Center Y coordinate of the found image ),
;  ok.1.id is the comment text, which is included in the <> of its parameter.
;  ok.1.x can also be written as ok[1].x, which supports variables. (eg: ok[A_Index].x)
;
;--------------------------------

FindText(args*)
{
  return FindText.FindText(args*)
}

Class FindText
{  ;// Class Begin

static bind:=[], bits:=[], Lib:=[]

__New()
{
  this.bind:=[], this.bits:=[], this.Lib:=[]
}

__Delete()
{
  if (this.bits.hBM)
    DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

FindText( x1, y1, x2, y2, err1:=0, err0:=0, text:="", ScreenShot:=1
  , FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10, dir:=1 )
{
  local
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  x:=(x1<x2?x1:x2), y:=(y1<y2?y1:y2)
  , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  , this.xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
  if (w<1 or h<1)
  {
    SetBatchLines, %bch%
    return 0
  }
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  info:=[]
  Loop, Parse, text, |
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (!(num:=info.MaxIndex()) or !bits.Scan0)
  {
    SetBatchLines, %bch%
    return 0
  }
  arr:=[], in:={zx:zx, zy:zy, zw:zw, zh:zh
  , sx:x-zx, sy:y-zy, sw:w, sh:h}, k:=0
  For i,j in info
    k+=Round(j.2 * j.3), in.comment .= j.11
  VarSetCapacity(s1, k*4), VarSetCapacity(s0, k*4)
  , VarSetCapacity(gs, (w+2)*(h+2))
  , VarSetCapacity(ss, w*h)
  , JoinText:=(num=1 ? 0 : JoinText)
  , allpos_max:=(FindAll or JoinText ? 10240 : 1)
  , VarSetCapacity(allpos, allpos_max*2*4)
  Loop, 2
  {
    if (err1=0 and err0=0) and (num>1 or A_Index>1)
      err1:=0.05, err0:=0.05
    this.PicFind(arr, in, info, 1, err1, err0, dir
      , bits, 0, 0, offsetX, offsetY, gs, ss, s1, s0
      , allpos, allpos_max, FindAll, JoinText)
    if !(err1=0 and err0=0 and !arr.MaxIndex())
      Break
  }
  SetBatchLines, %bch%
  return arr.MaxIndex() ? arr:0
}

PicFind(arr, in, info, index, err1, err0, dir
  , bits, x, y, offsetX, offsetY
  , ByRef gs, ByRef ss, ByRef s1, ByRef s0
  , ByRef allpos, allpos_max, FindAll, JoinText)
{
  local
  static MyFunc:=""
  if (!MyFunc)
  {
    x32:=""
    . "5557565383EC388B7C244C83FF050F84110400008BB4249400000085F60F8ECD"
    . "09000031C0897C244CC744240C00000000C744240800000000C7442404000000"
    . "0031EDC74424100000000089C78D76008B4C24088BB424900000008B5C24108B"
    . "54240C01CE89C829CB8B8C2490000000039C248C00000085C97E5889342489F9"
    . "89D6EB188BBC248800000083C60483C0018914AF83C501390424742A837C244C"
    . "0389F20F45D0803C033175D88BBC248400000083C60483C00139042489148F8D"
    . "790189F975D68BB424900000000174241089CF83442404018B5C24748B442404"
    . "015C24088B5C2460015C240C398424940000000F8557FFFFFF897C240C8B7C24"
    . "4C31C08B74240C39B424980000000F4DF039AC249C0000008974240C0F4DE839"
    . "EE0F4CF583FF03897424100F84990400008B4424708B74246C0FAF442460C1E6"
    . "028974241C01F08B742460894424288B442474F7D885FF8D0486894424180F85"
    . "5C0100008B4424508B4C2478C744241400000000C744241C00000000C1E8100F"
    . "B6C08904248B4424500FB6C4894424040FB6442450894424088B442474C1E002"
    . "85C9894424240F8EA2000000896C242C8B4424288B6C2454908DB42600000000"
    . "8B54247485D27E6B8B5C245C8B74241C8B7C245C03B4248000000001C3034424"
    . "248944242001C789F68DBC27000000000FB643020FB64B012B04242B4C24040F"
    . "B6132B5424080FAFC00FAFC98D04400FAFD28D04888D045039C50F930683C304"
    . "83C60139FB75C98B7424740174241C8B4424208344241401034424188B742414"
    . "397424780F8576FFFFFF8B6C242C8B4424782B8424940000008B7C24742BBC24"
    . "900000008904248B44245883E80283F8020F87FD090000837C2458020F84EF05"
    . "0000837C2458030F843407000089FBC74424240000000031F685DB0F88760100"
    . "003B3424C7442404040000000F8EE405000083EB01EBE089F68DBC2700000000"
    . "83FF010F84EB04000083FF020F842D0700008B4424508B5C24540FB67424500F"
    . "B67C2454C744241400000000C744242400000000C1E8100FB6DF0FB6D08B4424"
    . "5089D10FB6C4894424088B442454C1E8100FB6C029C101D08B5424788904248B"
    . "442408894C24308B4C240801D8894424088D043E29D9894C240489F189442420"
    . "8B44247429F9894C241CC1E00285D28944242C0F8EF5FEFFFF896C24348B4C24"
    . "288B6C24308B44247485C00F8E7E0000008B44245C8B54242403942480000000"
    . "01C8034C242C89CF894C2428037C245CEB33391C247C3D394C24047F37394C24"
    . "087C3189F30FB6F33974241C0F9EC3397424200F9DC183C00483C20121D9884A"
    . "FF39C7741E0FB658020FB648010FB63039DD7EBE31C983C00483C201884AFF39"
    . "C775E28B7C2474017C24248B4C24288344241401034C24188B44241439442478"
    . "0F855FFFFFFF8B6C2434E93FFEFFFFC7442424000000008B44242483C4385B5E"
    . "5F5DC25C008B44246C034424742B84249000000089C58B442470034424782B84"
    . "249400000039442470894424147FC08B4424708B7C246C0FAF442460896C2404"
    . "8B6C245CC7442424000000008D04B8894424108B442450F7D8894424088D7600"
    . "8B44246C8B7424048B54241039F00F8FDF0000008B5C245485DB0F84F6000000"
    . "8BBC24840000008B1F8BBC248800000001D38B370FB64C1D00890C2489F10FB6"
    . "F98B0C2429F9394C24500F8C93000000394C24080F8F89000000C744240C0000"
    . "00008904240FB64C1D0189F00FB6FC29F9394C24507C698B44240839C17C610F"
    . "B64C1D02C1EE1089F30FB6F329F1394C24507C4C39C17C488344240C018B4424"
    . "0C3B442454746C8B44240C8BB424840000008BBC24880000008B1C868B348701"
    . "D30FB64C1D0089F00FB6F829F9394C24507C0D3B4C24087D8C8DB42600000000"
    . "8B042483C00183C204394424040F8D21FFFFFF83442470018B7C24608B442414"
    . "017C24103B4424700F8DF2FEFFFFE984FEFFFF8B04248B7424248BBC24A00000"
    . "008B5C24708904F7895CF70483C6013BB424A4000000897424247CA78B442424"
    . "83C4385B5E5F5DC25C008B44245031D2F7B424900000000FAF4424608D049089"
    . "4424288B44246C034424742B84249000000089C6894424348B44247003442478"
    . "2B8424940000003974246C8944242C0F8FFAFDFFFF8B4424708B74246C0FAF44"
    . "2460C744242400000000896C24088D04B0034424288B74245C894424308B4424"
    . "30894424208B442470894424148B44242C394424700F8F0D010000908D742600"
    . "8B4424208B5C24100FB67C060289C52B6C242885DB893C240FB67C0601897C24"
    . "040FB63C060F84FA0000008B84249C0000008944241C8B842498000000894424"
    . "1831C0EB58394424087E458B9C24880000008B0C8301E90FB6540E020FB65C0E"
    . "012B14242B5C24040FB60C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A"
    . "39542454720A836C241C0178608D760083C001394424100F8488000000394424"
    . "0C7EA28B9C24840000008B0C8301E90FB6540E020FB65C0E012B14242B5C2404"
    . "0FB60C0E0FAFD20FAFDB29F98D14520FAFC98D149A8D144A395424540F8363FF"
    . "FFFF836C2418010F8958FFFFFF83442414018B5C24608B442414015C24203944"
    . "242C0F8DF8FEFFFF8344246C0183442430048B4424343B44246C0F8DBDFEFFFF"
    . "E992FCFFFF8B4424248BBC24A00000008B5C246C891CC78B5C2414895CC70483"
    . "C001398424A4000000894424247F9EE963FCFFFF8B4424508B7C2478C7042400"
    . "000000C74424040000000083C001C1E00789C68B442474C1E00285FF89442414"
    . "0F8E68FAFFFF8B442428896C241C89F58B74247485F67E5F8B4C245C8B5C2404"
    . "8B7C245C039C248000000001C1034424148944240801C789F68DBC2700000000"
    . "0FB651020FB641010FB6316BC04B6BD22601C289F0C1E00429F001D039C50F97"
    . "0383C10483C30139F975D58B7C2474017C24048B44240883042401034424188B"
    . "34243974247875888B6C241CE9DDF9FFFF8B3424C74424240000000031DB85F6"
    . "0F8891FBFFFF39FBC7442404020000000F8F8B0300008B4424748B4C24100FAF"
    . "C601D885C989C2894424280F84840000008B84249C0000000394248000000089"
    . "5C24188B5C240C8974241C897C242089CE894424148B84249800000089442408"
    . "31C039C37E1C8BBC248400000089D1030C87803900750B836C2408010F882E03"
    . "000039C57E1C8BBC24880000008B0C8701D1803900740B836C2414010F880E03"
    . "000083C00139C675B98B5C24188B74241C8B7C24208B44246C8B4C24248B9424"
    . "A000000001D88904CA8B44247001F08944CA0483C101398C24A4000000894C24"
    . "240F8EB0FAFFFF8B4C240C85C9742B8B8424840000008B5424288D0C88894C24"
    . "088B8C248000000001D18B1083C00401CA3B442408C6020075F08B44240483F8"
    . "010F84AA02000083F8020F849902000083F8030F848802000083C601E9E0F8FF"
    . "FF31DBC74424240000000031F639FB0F8F42FAFFFF3B3424C744240403000000"
    . "0F8EB0FEFFFF83C301EBE0908D74260031EDC744240C00000000E902F7FFFF8B"
    . "44246C034424748B7C2470894424208B4424708D77FF0344247889342439F00F"
    . "8CF30000008B7C246C83C001C744241800000000894424248B442474896C242C"
    . "8D77FF8B3C240FAF7C246083C00289742428894424088B442420897C24148D78"
    . "018B442428394424200F8C8A0000008B0C248B5C24148B742418035C241C2B74"
    . "246C035C245CC1E91F0374247C894C2404EB46394424647E49807C2404007542"
    . "8B0C24394C24687E390FB64BFE83C3046BE9260FB64BF96BD14B8D4C15000FB6"
    . "6BF889EAC1E20429EA01CAC1FA078854060183C00139F8741889C2C1EA1F84D2"
    . "74B1C64406010083C00183C30439F875E88B74240801742418830424018B5C24"
    . "608B0424015C2414394424240F854FFFFFFF8B6C242CEB0B8B44247483C00289"
    . "4424088B5C247885DB0F8E1FF7FFFF8B4424080344247CC744240401000000C7"
    . "44241400000000896C24208904248B44247883C001894424188B44247483C004"
    . "8944241C8B4C247485C90F8E8E0000008B14248B5C24148B74241C039C248000"
    . "000089D12B4C247401D68DB6000000000FB642010FB62ABF0100000003442450"
    . "39E87C3C0FB66A0239E87C340FB669FF39E87C2C0FB66EFF39E87C240FB669FE"
    . "39E87C1C0FB62939E87C150FB66EFE39E87C0D0FB63E39F80F9CC089C78D7600"
    . "89F883C20183C3018843FF83C60183C101390C24759A8B7C2474017C24148344"
    . "2404018B7424088B442404013424394424180F854CFFFFFF8B6C2420E92DF6FF"
    . "FF83EE01E953FCFFFF8DB426000000008B5C24188B74241C8B7C2420E959FDFF"
    . "FF83C601E98CFDFFFF83C301E935FCFFFF83C30139FB7E0F83C60131DB3B3424"
    . "7EF2E9B0F7FFFFC744240401000000E922FCFFFF31F6C744242400000000EBDB"
    x64:=""
    . "4157415641554154555756534883EC48448BB424E00000004C8BBC2400010000"
    . "83F90544898C24A8000000895424104489C54C8B8C24B00000004C8BA4240801"
    . "00000F84EF030000448B9C24200100004531C04531ED4585DB0F8ECB00000044"
    . "89B424E0000000448BB4241801000031C089AC24A000000031FF31F64531C045"
    . "31EDC74424080000000089C54C898C24B00000004585F67E604863542408418D"
    . "1C3E89F848039424100100004189E9EB1A83C0014D63D84183C1044183C00148"
    . "83C20139C34789149C742983F9034589CA440F45D0803A3175D783C0014D63DD"
    . "4183C1044183C5014883C20139C34789149F75D7440174240883C60103BC24E0"
    . "00000003AC24B800000039B4242001000075818BAC24A00000004C8B8C24B000"
    . "0000448BB424E000000031C04439AC2428010000440F4DE84439842430010000"
    . "440F4DC04539C54489C0410F4DC583F903894424300F84A50400008B8424D800"
    . "00008BBC24D00000000FAF8424B80000008D04B88BBC24B80000008944241844"
    . "89F0F7D885C98D0487894424080F855E0100008B7C2410448B9424E800000031"
    . "D24889F889FE400FB6FF0FB6C4C1EE104585D289C3428D04B500000000400FB6"
    . "F6894424100F8EB40000004C89A42408010000448B64241844896C24144C89BC"
    . "24000100004189CD44894424204189D74585F67E5D4D63DF4C039C24F8000000"
    . "4963C44D8D4401024531D20F1F440000410FB600410FB648FF410FB650FE29F0"
    . "29D90FAFC029FA0FAFC98D04400FAFD28D04888D045039C5430F9304134983C2"
    . "014983C0044539D67FC644036424104501F74183C50144036424084439AC24E8"
    . "000000758B448B6C2414448B4424204C8BBC24000100004C8BA424080100008B"
    . "8424A80000004489F38BB424E80000002B9C24180100002BB4242001000083E8"
    . "0283F8020F874B0B000083BC24A8000000020F84A606000083BC24A800000003"
    . "0F84DD0700004189D9C7442418000000004531D24585C90F88450100004139F2"
    . "BF040000000F8E980600004183E901EBE083F9010F846105000083F9020F84CD"
    . "0700008B7424104889EB440FB6D50FB6CF89F0440FB6DEC1E8104489DB0FB6F8"
    . "4889F04429D30FB6D489E889FEC1E810895C241089D50FB6C029CD29C601C78D"
    . "040A31C989C3438D04134531D289C2428D04B500000000894424148B8424E800"
    . "000085C00F8E15FFFFFF448B5C241844896C24204589D54C89BC24000100004C"
    . "89A424080100004189D744894424284C898C24B00000004189CC660F1F440000"
    . "4585F60F8E7F050000488B9424B00000004963C34D63D54C039424F800000048"
    . "8D44020231D2EB3C0F1F8400000000004439C77C4139CD7F3D39CB7C3944394C"
    . "2410410F9EC04539CF0F9DC14421C141880C124883C2014883C0044139D60F8E"
    . "1C050000440FB6000FB648FF440FB648FE4439C67EBA31C9EBD5C74424180000"
    . "00008B4424184883C4485B5E5F5D415C415D415E415FC38B8424D80000000384"
    . "24E80000004403B424D00000002B842420010000442BB42418010000398424D8"
    . "000000894424147FB18B8424D80000008BBC24D00000000FAF8424B8000000C7"
    . "44241800000000448D2CB8418D40FF448B442410498D44870444896C24104589"
    . "C2488944242041F7DA0F1F80000000008B8424D00000008B5424104439F00F8F"
    . "CB00000085ED0F84EC000000458B1F418B1C244101D30FB6F34963CB410FB60C"
    . "0929F14139C80F8C940000004439D10F8C8B000000498D7C2404498D77044889"
    . "7C2408418D4B010FB6FF4863C9410FB60C0929F94139C87C674439D17C624183"
    . "C302C1EB104D63DB0FB6DB430FB60C1929D94139C87C494439D17C4448397424"
    . "207475448B1E488B7C24084101D38B1F4963CB410FB60C09440FB6EB4429E941"
    . "39C87C1C4883C7044883C6044439D148897C24087D8D662E0F1F840000000000"
    . "83C00183C2044139C60F8D35FFFFFF838424D8000000018BBC24B80000008B44"
    . "2414017C24103B8424D80000000F8DFDFEFFFFE96AFEFFFF8B7C2418488BB424"
    . "380100008B9C24D80000008D0C3F83C7013BBC2440010000897C24184863C989"
    . "048E895C8E040F8D36FEFFFF83C00183C2044139C60F8DC9FEFFFFEB920F1F00"
    . "8B44241031D24403B424D0000000442BB42418010000F7B42418010000448974"
    . "24380FAF8424B80000008D0490894424208B8424D8000000038424E80000002B"
    . "8424200100004439B424D0000000894424280F8FC2FDFFFF8B8424D80000008B"
    . "BC24D00000004189EE0FAF8424B80000008B6C24304C89BC24000100004589C7"
    . "C7442418000000004C89A424080100008D04B803442420894424348B8424D800"
    . "0000448B642434894424088B442428398424D80000000F8F3F0100000F1F4000"
    . "418D4424024489E72B7C242085ED4898450FB61C01418D4424014898410FB61C"
    . "014963C4410FB634010F84310100008B842430010000894424148B8424280100"
    . "008944241031C0EB730F1F80000000004539D77E5B488B9424080100008B0C82"
    . "01F98D5102448D41014863C9410FB60C094863D24D63C0410FB61411470FB604"
    . "0129F10FAFC94429DA4129D80FAFD2450FAFC08D1452428D14828D144A4139D6"
    . "720E836C24140178770F1F80000000004883C00139C50F8EA40000004139C541"
    . "89C27E8C488B9424000100008B0C8201F98D5102448D41014863C9410FB60C09"
    . "4863D24D63C0410FB61411470FB6040129F10FAFC94429DA4129D80FAFD2450F"
    . "AFC08D1452428D14828D144A4139D60F833BFFFFFF836C2410010F8930FFFFFF"
    . "83442408014403A424B80000008B442408394424280F8DC5FEFFFF838424D000"
    . "00000183442434048B4424383B8424D00000000F8D82FEFFFFE904FCFFFF6690"
    . "8B7C2418488BB424380100008B9C24D000000089F801C04898891C868B5C2408"
    . "895C860489F883C00139842440010000894424187F8AE9C7FBFFFF8B7424108B"
    . "8C24E8000000428D04B50000000031FF31ED8944241083C601C1E60785C90F8E"
    . "FBF9FFFF44896C241444894424204C89BC24000100004C89A42408010000448B"
    . "442408448B6C24184C8BBC24F8000000448BA424E80000004585F67E4E4963C5"
    . "4863DD4531D2498D4C01024C01FB66900FB6110FB641FF440FB659FE6BC04B6B"
    . "D22601C24489D8C1E0044429D801D039C6420F9704134983C2014883C1044539"
    . "D67FCD44036C24104401F583C7014501C54139FC75A2E94AF9FFFF0F1F440000"
    . "44035C24144501F54183C40144035C24084439A424E80000000F8561FAFFFF44"
    . "8B6C2420448B4424284C8BBC24000100004C8BA42408010000E921F9FFFF4189"
    . "F2C7442418000000004531C94585D20F88ADFAFFFF4139D9BF020000000F8F1F"
    . "0400004589D38B542430450FAFDE4501CB85D2747A8B84242801000044895424"
    . "148BAC24300100004C8B9424F800000044894C24104189D18944240831C06690"
    . "4139C589C27E194489D941030C8741803C0A00750B836C2408010F88D0030000"
    . "4139D07E174489DA4103148441803C1200740983ED010F88B40300004883C001"
    . "4139C17FBB448B4C2410448B5424148B4C24188B9424D0000000488BAC243801"
    . "000089C84401CA01C04898895485008B9424D80000004401D28954850489C883"
    . "C00139842440010000894424180F8ECFF9FFFF4585ED7427418D55FF488BAC24"
    . "F80000004C89F8498D4C97044489DA03104883C0044839C8C64415000075ED83"
    . "FF010F844903000083FF020F843703000083FF030F84250300004183C201E93A"
    . "F8FFFF4531C9C7442418000000004531D24139D90F8F68F9FFFF4139F2BF0300"
    . "00000F8EBBFEFFFF4183C101EBE066908B8424D00000008BBC24D80000004401"
    . "F083EF01894424088B8424D8000000038424E800000039F80F8C680100008BB4"
    . "24D000000083C0018B9C24B8000000894424184C89A42408010000448B9C24C0"
    . "000000448BA424C800000083EE0144896C24384C898C24B00000008D04B50000"
    . "00008974242031F60FAFDF448944243C4189F18944243448984489B424E00000"
    . "004889442428418D46024C89BC24000100004189DD894424148B4424088D6801"
    . "8B442420394424080F8C9F0000008B7424344C8B7C24284D63C14D63F54C0384"
    . "24F0000000418D54350089FEC1EE1F4863D24989D24929D74C039424B0000000"
    . "EB4A4139C37E4E4084F675494139FC7E44410FB64A0283C0014983C0016BD926"
    . "410FB64A016BD14B8D0C134B8D14174983C204420FB61C3289DAC1E20429DA01"
    . "CAC1FA07418850FF39C5741C89C2C1EA1F84D274AD83C00141C600004983C204"
    . "4983C00139C575E444034C241483C7014403AC24B8000000397C24180F853EFF"
    . "FFFF448B6C2438448B44243C448BB424E00000004C8BBC24000100004C8BA424"
    . "08010000EB08418D4602894424148B9424E800000085D20F8E02F6FFFF486344"
    . "2414488BBC24F000000031C944896C24204C89BC2400010000BD010000004C89"
    . "A4240801000044894424284189CD4889442408488D7C07018B8424E800000083"
    . "C001894424144963C6488D700348F7D04889C3418D46FF4889F28B7424104989"
    . "DF4883C0014989D448894424184585F60F8E95000000488B4424184963CD4803"
    . "8C24F80000004D8D0C3C4D8D043F488D1C384889F80FB610440FB658FF41BA01"
    . "00000001F24439DA7C46440FB658014439DA7C3C450FB658FF4439DA7C32450F"
    . "B659FF4439DA7C28450FB658FE4439DA7C1E450FB6184439DA7C15450FB659FE"
    . "4439DA7C0B450FB6114439D2410F9CC24883C0014488114983C1014883C10149"
    . "83C0014839D8758D4501F583C50148037C2408396C24140F8550FFFFFFE99DFB"
    . "FFFF4183EA01E9BEFBFFFF0F1F440000448B4C2410448B542414E9C0FCFFFF41"
    . "83C201E9F2FCFFFF4183C101E9A4FBFFFF4183C1014139D97E114183C2014531"
    . "C94139F27EEFE937F6FFFFBF01000000E98EFBFFFF4531D2C744241800000000"
    . "EBDC9090909090909090909090909090"
    this.MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  num:=info.MaxIndex(), j:=info[index]
  , text:=j.1, w:=j.2, h:=j.3, mode:=j.8
  , color:=j.9, n:=j.10, comment:=j.11
  , e1:=(err1 and !j.12 ? Round(j.4*err1) : j.6)
  , e0:=(err0 and !j.12 ? Round(j.5*err0) : j.7)
  , sx:=in.sx, sy:=in.sy, sw:=in.sw, sh:=in.sh
  if (mode=5)
  {
    r:=StrSplit(text,"/"), i:=0, k:=bits.Stride
    Loop, % n
      NumPut(r[3*i+2]*k+r[3*i+1]*4, s1, 4*i, "uint")
      , NumPut(r[3*i+3], s0, 4*i, "uint"), i++
  }
  if (!JoinText or index=1)
    x1:=sx, y1:=sy, x2:=sx+sw, y2:=sy+sh
  else
  {
    x1:=x, y1:=y-offsetY, y1:=(y1<sy ? sy:y1)
    , x2:=x+offsetX+w, x2:=(x2>sx+sw ? sx+sw:x2)
    , y2:=y+offsetY+h, y2:=(y2>sy+sh ? sy+sh:y2)
  }
  ok:=!bits.Scan0 ? 0:DllCall(&MyFunc, "int",mode
    , "uint",color, "uint",n, "int",dir, "Ptr",bits.Scan0
    , "int",bits.Stride, "int",in.zw, "int",in.zh
    , "int",x1, "int",y1, "int",x2-x1, "int",y2-y1
    , "Ptr",&gs, "Ptr",&ss, "Ptr",&s1, "Ptr",&s0
    , "AStr",text, "int",w, "int",h, "int",e1, "int",e0
    , "Ptr",&allpos, "int",allpos_max)
  pos:=[]
  Loop, % ok*2
    pos[A_Index]:=NumGet(allpos, 4*(A_Index-1), "uint")
  Loop, % ok
  {
    x:=pos[2*A_Index-1], y:=pos[2*A_Index]
    if (!JoinText)
      arr.Push( {1:x+=in.zx, 2:y+=in.zy, 3:w, 4:h
    
  , x:x+w//2, y:y+h//2, id:comment} )
    else
    {
      if (index=1)
        in.x:=x, in.minY:=y, in.maxY:=y+h
      minY:=in.minY, maxY:=in.maxY
      , (y<minY && in.minY:=y)
      , (y+h>maxY && in.maxY:=y+h)
      if (index=num)
      {
        x1:=in.x+in.zx, y1:=in.minY+in.zy
        , w1:=x+w-in.x, h1:=in.maxY-in.minY
        , arr.Push( {1:x1, 2:y1, 3:w1, 4:h1
        , x:x1+w1//2, y:y1+h1//2, id:in.comment} )
      }
      else
      {
        this.PicFind(arr, in, info, index+1, err1, err0, 3
          , bits, x+w, y, offsetX, offsetY, gs, ss, s1, s0
          , allpos, allpos_max, FindAll, JoinText)
      }
      in.minY:=minY, in.maxY:=maxY
    }
    if (!FindAll and arr.MaxIndex())
      return
  }
  if (!JoinText and index<num)
    return this.PicFind(arr, in, info, index+1, err1, err0, dir
      , bits, 0, 0, offsetX, offsetY, gs, ss, s1, s0
      , allpos, allpos_max, FindAll, JoinText)
}

PicInfo(text)
{
  local
  static info:=[]
  if !InStr(text,"$")
    return
  if (info[text])
    return info[text]
  v:=text, comment:="", e1:=e0:=0, set_e1_e0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v,"<([^>]*)>",r)
    v:=StrReplace(v,r), comment:=Trim(r1)
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v,"\[([^\]]*)]",r)
  {
    v:=StrReplace(v,r), r:=StrSplit(r1, ",")
    e1:=r.1, e0:=r.2, set_e1_e0:=1
  }
  r:=StrSplit(v,"$"), color:=r.1, v:=r.2
  mode:=InStr(color,"##") ? 5
    : InStr(color,"-") ? 4 : InStr(color,"#") ? 3
    : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
  color:=RegExReplace(color,"[*#]")
  if (mode=5)
  {
    x1:=y1:=x2:=y2:=0, r:=StrSplit(Trim(v,"/"),"/")
    if !(n:=r.MaxIndex()//3)
      return
    Loop, % n
      x:=r[3*A_Index-2], y:=r[3*A_Index-1]
      , (x<x1 && x1:=x), (y<y1 && y1:=y)
      , (x>x2 && x2:=x), (y>y2 && y2:=y)
    v:="", i:=1
    Loop, % n
      v.="/" (r[i++]-x1) "/" (r[i++]-y1) "/0x" r[i++]
    v:=Trim(v,"/"), w1:=x2-x1+1, h1:=y2-y1+1
  }
  else
  {
    r:=StrSplit(v,"."), w1:=r.1
    , v:=this.base64tobit(r.2), h1:=StrLen(v)//w1
    if (w1<1 or h1<1 or StrLen(v)!=w1*h1)
      return
  }
  if (mode=4)
  {
    color:=StrReplace(color,"0x")
    r:=StrSplit(color,"-")
    color:="0x" r.1, n:="0x" r.2
  }
  else if (mode!=5)
  {
    r:=StrSplit(color,"@")
    color:=r.1, n:=Round(r.2,2)+(!r.2)
    , n:=Floor(9*255*255*(1-n)*(1-n))
  }
  StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
  , e1:=Round(len1*e1), e0:=Round(len0*e0)
  return info[text]:=[v,w1,h1,len1,len0,e1,e0
    , mode,color,n,comment,set_e1_e0]
}

; Bind the window so that it can find images when obscured
; by other windows, it's equivalent to always being
; at the front desk. Unbind Window using FindText.BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  local
  bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id, bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      WinGet, oldStyle, ExStyle, ahk_id %bind_id%
      bind.oldStyle:=oldStyle
      WinSet, Transparent, 255, ahk_id %bind_id%
      Loop, 30
      {
        Sleep, 100
        WinGet, i, Transparent, ahk_id %bind_id%
      }
      Until (i=255)
    }
  }
  else
  {
    bind_id:=bind.id
    if (bind.mode & 1)
      WinSet, ExStyle, % bind.oldStyle, ahk_id %bind_id%
    bind.id:=0, bind.mode:=0, bind.oldStyle:=0
  }
}

xywh2xywh(x1,y1,w1,h1, ByRef x,ByRef y,ByRef w,ByRef h
  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
{
  local
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  , left:=(left<zx ? zx:left), right:=(right>zx+zw-1 ? zx+zw-1:right)
  , up:=(up<zy ? zy:up), down:=(down>zy+zh-1 ? zy+zh-1:down)
  , x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

GetBitsFromScreen(x, y, w, h, ScreenShot:=1
  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
{
  local
  static Ptr:="Ptr"
  bits:=this.bits
  if (!ScreenShot)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    return bits
  }
  bch:=A_BatchLines, cri:=A_IsCritical
  Critical
  if (zw<1 or zh<1)
    this.xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
  if (zw>bits.oldzw or zh>bits.oldzh or !bits.hBM)
  {
    if (bits.hBM)
      DllCall("DeleteObject", Ptr,bits.hBM)
    VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
    NumPut(zw, bi, 4, "int"), NumPut(-zh, bi, 8, "int")
    NumPut(1, bi, 12, "short"), NumPut(bpp:=32, bi, 14, "short")
    bits.hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
      , "int",0, "Ptr*",ppvBits:=0, Ptr,0, "int",0, Ptr)
    bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    bits.Stride:=((zw*bpp+31)//32)*4
    bits.oldzw:=zw, bits.oldzh:=zh
  }
  if (bits.hBM) and !(w<1 or h<1)
  {
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,bits.hBM, Ptr)
    DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
    if (id:=this.BindWindow(0,0,1))
      WinGet, id, ID, ahk_id %id%
    if (id)
    {
      WinGetPos, wx, wy, ww, wh, ahk_id %id%
      left:=x, right:=x+w-1, up:=y, down:=y+h-1
      , left:=(left<wx ? wx:left), right:=(right>wx+ww-1 ? wx+ww-1:right)
      , up:=(up<wy ? wy:up), down:=(down>wy+wh-1 ? wy+wh-1:down)
      , x:=left, y:=up, w:=right-left+1, h:=down-up+1
    }
    if (id) and !(w<1 or h<1)
    {
      if (mode:=this.BindWindow(0,0,0,1))<2
      {
        hDC2:=DllCall("GetDCEx", Ptr,id, Ptr,0, "int",3, Ptr)
        DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , Ptr,hDC2, "int",x-wx, "int",y-wy, "uint",0x00CC0020|0x40000000)
        DllCall("ReleaseDC", Ptr,id, Ptr,hDC2)
      }
      else
      {
        VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
        NumPut(ww, bi, 4, "int"), NumPut(-wh, bi, 8, "int")
        NumPut(1, bi, 12, "short"), NumPut(32, bi, 14, "short")
        hBM2:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
        , "int",0, "Ptr*",0, Ptr,0, "int",0, Ptr)
        mDC2:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
        oBM2:=DllCall("SelectObject", Ptr,mDC2, Ptr,hBM2, Ptr)
        DllCall("PrintWindow", Ptr,id, Ptr,mDC2, "uint",(mode>3)*3)
        DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , Ptr,mDC2, "int",x-wx, "int",y-wy, "uint",0x00CC0020|0x40000000)
        DllCall("SelectObject", Ptr,mDC2, Ptr,oBM2)
        DllCall("DeleteDC", Ptr,mDC2)
        DllCall("DeleteObject", Ptr,hBM2)
      }
    }
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteDC", Ptr,mDC)
  }
  Critical, %cri%
  SetBatchLines, %bch%
  return bits
}

MCode(ByRef code, hex)
{
  local
  ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  VarSetCapacity(code, len:=StrLen(hex)//2)
  Loop, % len
    NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  DllCall("VirtualProtect","Ptr",&code,"Ptr",len,"uint",0x40,"Ptr*",0)
  SetBatchLines, %bch%
  ListLines, %lls%
}

base64tobit(s)
{
  local
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=RegExReplace(s,"[" A_LoopField "]",StrReplace(v,"0x"))
  }
  ListLines, %lls%
  return RegExReplace(RegExReplace(s,"10*$"),"[^01]+")
}

bit2base64(s)
{
  local
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,StrReplace(v,"0x"),A_LoopField)
  }
  ListLines, %lls%
  return s
}

ASCII(s)
{
  local
  if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
  {
    s:=RegExReplace(this.base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return s
}

; You can put the text library at the beginning of the script,
; and Use FindText.PicLib(Text,1) to add the text library to PicLib()'s Lib,
; Use FindText.PicLib("comment1|comment2|...") to get text images from Lib

PicLib(comments, add_to_Lib:=0, index:=1)
{
  local
  Lib:=this.Lib
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
      {
        s1:=Trim(r1), s2:=""
        Loop, Parse, s1
          s2.="_" . Format("{:d}",Ord(A_LoopField))
        Lib[index,s2]:=r
      }
    Lib[index,""]:=""
  }
  else
  {
    Text:=""
    Loop, Parse, comments, |
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop, Parse, s1
        s2.="_" . Format("{:d}",Ord(A_LoopField))
      Text.="|" . Lib[index,s2]
    }
    return Text
  }
}

; Decompose a string into individual characters and get their data

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; Use FindText.PicX(Text) to automatically cut into multiple characters
; Can't be used in ColorPos mode, because it can cause position errors

PicX(Text)
{
  local
  if !RegExMatch(Text,"(<[^$]+)\$(\d+)\.([\w+/]+)",r)
    return Text
  v:=this.base64tobit(r3), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r2 "}","$0`n")
  While InStr(txt,c)
  {
    While !(txt~="m`n)^" c)
      txt:=RegExReplace(txt,"m`n)^.")
    i:=0
    While (txt~="m`n)^.{" i "}" c)
      i:=Format("{:d}",i+1)
    v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
    txt:=RegExReplace(txt,"m`n)^.{" i "}")
    if (v!="")
      Text.="|" r1 "$" i "." this.bit2base64(v)
  }
  return Text
}

; Screenshot and retained as the last screenshot.

ScreenShot(x1:="", y1:="", x2:="", y2:="")
{
  local
  if (x1+y1+x2+y2="")
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=(x1<x2?x1:x2), y:=(y1<y2?y1:y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  this.GetBitsFromScreen(x,y,w,h,1)
}

; Get the RGB color of a point from the last screenshot.
; If the point to get the color is beyond the range of
; Screen, it will return White color (0xFFFFFF).

GetColor(x, y, fmt:=1)
{
  local
  c:=!(bits:=this.GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh))
    or (x<zx or x>=zx+zw or y<zy or y>=zy+zh or !bits.Scan0)
    ? 0xFFFFFF : NumGet(bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4,"uint")
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; Identify a line of text or verification code
; based on the result returned by FindText().
; offsetX is the maximum interval between two texts,
; if it exceeds, a "*" sign will be inserted.
; offsetY is the maximum height difference between two texts,
; Return Association array {ocr:Text, x:X, y:Y}

Ocr(ok, offsetX:=20, offsetY:=20)
{
  local
  ocr_Text:=ocr_X:=ocr_Y:=min_X:=""
  For k,v in ok
    x:=v.1
    , min_X:=(A_Index=1 or x<min_X ? x : min_X)
    , max_X:=(A_Index=1 or x>max_X ? x : max_X)
  While (min_X!="" and min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) or Abs(y-ocr_Y)>offsetY
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" or x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" and LeftX-min_X>offsetX ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  return {ocr:ocr_Text, x:ocr_X, y:min_Y
    , w: min_X-ocr_X, h: max_Y-min_Y}
}

; Sort the results returned by FindText() from left to right
; and top to bottom, ignore slight height difference

Sort(ok, dy:=10)
{
  local
  if !IsObject(ok)
    return ok
  ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k2,v2 in ypos
      if Abs(y-v2)<=dy
      {
        y:=v2, add:=0
        Break
      }
    if (add)
      ypos.Push(y)
    n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
  }
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; Reordering according to the nearest distance

Sort2(ok, px, py)
{
  local
  if !IsObject(ok)
    return ok
  For k,v in ok
    n:=((v.x-px)**2+(v.y-py)**2) "." k, s:=A_Index=1 ? n : s "-" n
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; Prompt mouse position in remote assistance

MouseTip(x:="", y:="", w:=10, h:=10, d:=4)
{
  local
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  x:=Round(x-w-d), y:=Round(y-h-d), w:=(2*w+1)+2*d, h:=(2*h+1)+2*d
  ;-------------------------
  Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid -DPIScale
  Gui, _MouseTip_: Show, Hide w%w% h%h%
  ;-------------------------
  DetectHiddenWindows, % (dhw:=A_DetectHiddenWindows)?"On":"On"
  i:=w-d, j:=h-d
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%, ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  ;Gui, _MouseTip_: Show, NA x%x% y%y%
  Loop, 4
  {
    Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
    Sleep, 500
  }
  ;Gui, _MouseTip_: Destroy
}

; Quickly get the search data of screen image

GetTextFromScreen(x1, y1, x2, y2, Threshold:=""
  , ScreenShot:=1, ByRef rx:="", ByRef ry:="")
{
  local
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  x:=(x1<x2?x1:x2), y:=(y1<y2?y1:y2)
  , w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  , this.xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
  if (w<1 or h<1)
  {
    SetBatchLines, %bch%
    return
  }
  ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
  this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  gs:=[], k:=0
  Loop, %h%
  {
    j:=y+A_Index-1
    Loop, %w%
      i:=x+A_Index-1, c:=this.GetColor(i,j,0)
      , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  }
  if InStr(Threshold,"**")
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
      Threshold:=50
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop, %h%
    {
      y1:=A_Index
      Loop, %w%
        x1:=A_Index, i:=y1*sw+x1+1, j:=gs[i]+Threshold
        , s.=( gs[i-1]>j || gs[i+1]>j
        || gs[i-sw]>j || gs[i+sw]>j
        || gs[i-sw-1]>j || gs[i-sw+1]>j
        || gs[i+sw-1]>j || gs[i+sw+1]>j ) ? "1":"0"
    }
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
    {
      pp:=[]
      Loop, 256
        pp[A_Index-1]:=0
      Loop, % w*h
        pp[gs[A_Index]]++
      IP:=IS:=0
      Loop, 256
        k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
      Threshold:=Floor(IP/IS)
      Loop, 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop, % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP-IP1, IS2:=IS-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop, % w*h
      s.=gs[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  re1=(^0{%w%}|^1{%w%})
  re2=(0{%w%}$|1{%w%}$)
  While RegExMatch(s,re1)
    s:=RegExReplace(s,re1), CutUp++
  While RegExMatch(s,re2)
    s:=RegExReplace(s,re2), CutDown++
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  SetBatchLines, %bch%
  ListLines, %lls%
  return s
}

; Quickly save screen image to BMP file for debugging

SavePic(file, x1:="", y1:="", x2:="", y2:="", ScreenShot:=1)
{
  local
  static Ptr:="Ptr"
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  if (x1+y1+x2+y2="")
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=(x1<x2?x1:x2), y:=(y1<y2?y1:y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  this.xywh2xywh(x,y,w,h,x,y,w,h,zx,zy,zw,zh)
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  if (!bits.hBM) or (w<1 or h<1)
  {
    SetBatchLines, %bch%
    return
  }
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp:=24, bi, 14, "short")
  hBM:=DllCall("CreateDIBSection", Ptr,0, Ptr,&bi
    , "int",0, "Ptr*",ppvBits:=0, Ptr,0, "int",0, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  ;-------------------------
  mDC2:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM2:=DllCall("SelectObject", Ptr,mDC2, Ptr,bits.hBM, Ptr)
  DllCall("BitBlt",Ptr,mDC,"int",0,"int",0,"int",w,"int",h
    , Ptr,mDC2, "int",x-zx, "int",y-zy, "uint",0x00CC0020)
  DllCall("SelectObject", Ptr,mDC2, Ptr,oBM2)
  DllCall("DeleteDC", Ptr,mDC2)
  ;-------------------------
  size:=((w*bpp+31)//32)*4*h
  VarSetCapacity(bf, 14, 0), StrPut("BM", &bf, "CP0")
  NumPut(54+size, bf, 2, "uint"), NumPut(54, bf, 10, "uint")
  f:=FileOpen(file,"w"), f.RawWrite(bf,14), f.RawWrite(bi,40)
  , f.RawWrite(ppvBits+0, size), f.Close()
  ;-------------------------
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("DeleteObject", Ptr,hBM)
  SetBatchLines, %bch%
}

; Show the last screen shot

ShowScreenShot(onoff:=1)
{
  local
  static Ptr:="Ptr"
  Gui, FindText_Screen: Destroy
  bits:=this.GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
  if (!onoff or !bits.hBM or zw<1 or zh<1)
    return
  mDC:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,bits.hBM, Ptr)
  hBrush:=DllCall("CreateSolidBrush", "uint",0xFFFFFF, Ptr)
  oBrush:=DllCall("SelectObject", Ptr,mDC, Ptr,hBrush, Ptr)
  DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",zw, "int",zh
    , Ptr,mDC, "int",0, "int",0, "uint",0xC000CA) ; MERGECOPY
  DllCall("SelectObject", Ptr,mDC, Ptr,oBrush)
  DllCall("DeleteObject", Ptr,hBrush)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteDC", Ptr,mDC)
  ;---------------------
  Gui, FindText_Screen: +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
  Gui, FindText_Screen: Margin, 0, 0
  Gui, FindText_Screen: Add, Picture, x0 y0 w%zw% h%zh% +Hwndid +0xE
  SendMessage, 0x172, 0, bits.hBM,, ahk_id %id%
  Gui, FindText_Screen: Show, NA x%zx% y%zy% w%zw% h%zh%, Show ScreenShot
}

; Running AHK code dynamically with new threads

Class Thread
{
  __New(args*)
  {
    this.pid:=this.Exec(args*)
  }
  __Delete()
  {
    Process, Close, % this.pid
  }
  Exec(s, Ahk:="", args:="")
  {
    local
    Ahk:=Ahk ? Ahk:A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
    s:="DllCall(""SetWindowText"",""Ptr"",A_ScriptHwnd,""Str"",""<AHK>"")`n"
      . StrReplace(s,"`r"), pid:=""
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec("""" Ahk """ /f * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID



    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`n FileDelete, " f "`n" s
      FileDelete, %f%
      FileAppend, %s%, %f%
      r:=ObjBindMethod(this, "Clear")
      SetTimer, %r%, -3000
      Run, "%Ahk%" /f "%f%" %args%,, UseErrorLevel, pid
    }
    return pid
  }
  Clear()
  {
    FileDelete, % A_Temp "\~ahk.tmp"
    SetTimer,, Off
  }
}

/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride, int zw, int zh
  , int sx, int sy, int sw, int sh
  , unsigned char * gs, char * ss
  , unsigned int * s1, unsigned int * s0
  , char * text, int w, int h, int err1, int err0
  , unsigned int * allpos, int allpos_max )
{
  int ok=0, o, i, j, k, x, y, r, g, b, rr, gg, bb;
  int x1, y1, x2, y2, len1, len0, e1, e0, max;
  int r_min, r_max, g_min, g_max, b_min, b_max;
  //----------------------
  // MultColor Mode
  if (mode==5)
  {
    x2=sx+sw-w; y2=sy+sh-h; k=c;
    for (y=sy; y<=y2; y++)
    {
      for (x=sx; x<=x2; x++)
      {
        o=y*Stride+x*4;
        for (i=0; i<n; i++)
        {
          j=o+s1[i]; c=s0[i];
          b=Bmp[j]-(c&0xFF);
          if (b>k || b<-k)
            goto NoMatch5;
          g=Bmp[1+j]-((c>>8)&0xFF);
          if (g>k || g<-k)
            goto NoMatch5;
          r=Bmp[2+j]-((c>>16)&0xFF);
          if (r>k || r<-k)
            goto NoMatch5;
        }
        allpos[ok*2]=x; allpos[ok*2+1]=y;
        if (++ok>=allpos_max)
          goto Return1;
        NoMatch5:
        continue;
      }
    }
    goto Return1;
  }
  //----------------------
  // Generate Lookup Table
  o=0; len1=0; len0=0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      i=(mode==3) ? y*Stride+x*4 : y*sw+x;
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=len1>len0 ? len1 : len0;
  // Color Position Mode
  // only used to recognize multicolored Verification Code
  if (mode==3)
  {
    c=(c/w)*Stride+(c%w)*4;
    x2=sx+sw-w; y2=sy+sh-h;
    for (x=sx; x<=x2; x++)
    {
      for (y=sy; y<=y2; y++)
      {
        o=y*Stride+x*4; e1=err1; e0=err0;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b>n && (--e1)<0)
              goto NoMatch3;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b<=n && (--e0)<0)
              goto NoMatch3;
          }
        }
        allpos[ok*2]=x; allpos[ok*2+1]=y;
        if (++ok>=allpos_max)
          goto Return1;
        NoMatch3:
        continue;
      }
    }
    goto Return1;
  }
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        ss[i]=(3*r*r+4*g*g+2*b*b<=n) ? 1:0;
      }
  }
  else if (mode==1)  // Gray Threshold Mode
  {
    c=(c+1)*128;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ss[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 1:0;
  }
  else if (mode==2)  // Gray Difference Mode
  {
    x2=sx+sw; y2=sy+sh;
    for (y=sy-1; y<=y2; y++)
    {
      for (x=sx-1; x<=x2; x++, i++)
        if (x<0 || x>=zw || y<0 || y>=zh)
          gs[i]=0;
        else
        {
          o=y*Stride+x*4;
          gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
        }
    }
    k=sw+2; i=0;
    for (y=1; y<=sh; y++)
      for (x=1; x<=sw; x++, i++)
      {
        o=y*k+x; j=gs[o]+c;
        ss[i]=(gs[o-1]>j || gs[o+1]>j
          || gs[o-k]>j   || gs[o+k]>j
          || gs[o-k-1]>j || gs[o-k+1]>j
          || gs[o+k-1]>j || gs[o+k+1]>j) ? 1:0;
      }
  }
  else  // (mode==4) Color Difference Mode
  {
    r=(c>>16)&0xFF; g=(c>>8)&0xFF; b=c&0xFF;
    rr=(n>>16)&0xFF; gg=(n>>8)&0xFF; bb=n&0xFF;
    r_min=r-rr; g_min=g-gg; b_min=b-bb;
    r_max=r+rr; g_max=g+gg; b_max=b+bb;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]; g=Bmp[1+o]; b=Bmp[o];
        ss[i]=(r>=r_min && r<=r_max
            && g>=g_min && g<=g_max
            && b>=b_min && b<=b_max) ? 1:0;
      }
  }
  // Start Lookup
  x1=0; y1=0; x2=sw-w; y2=sh-h; if (dir<1||dir>4) dir=1;
  if (dir==1)  // From top to bottom
  {
    for (y=y1; y<=y2; y++)
    {
      for (x=x1; x<=x2; x++)
      {
        goto GoSub;
        GoBack1:
        continue;
      }
    }
  }
  else if (dir==2)  // From bottom to top
  {
    for (y=y2; y>=y1; y--)
    {
      for (x=x1; x<=x2; x++)
      {
        goto GoSub;
        GoBack2:
        continue;
      }
    }
  }
  else if (dir==3)  // From left to right
  {
    for (x=x1; x<=x2; x++)
    {
      for (y=y1; y<=y2; y++)
      {
        goto GoSub;
        GoBack3:
        continue;
      }
    }
  }
  else  // (dir==4)  From right to left
  {
    for (x=x2; x>=x1; x--)
    {
      for (y=y1; y<=y2; y++)
      {
        goto GoSub;
        GoBack4:
        continue;
      }
    }
  }
  goto Return1;
  //----------------------
  GoSub:
  o=y*sw+x; e1=err1; e0=err0;
  for (i=0; i<max; i++)
  {
    if ((i<len1 && ss[o+s1[i]]==0 && (--e1)<0)
    ||  (i<len0 && ss[o+s0[i]]!=0 && (--e0)<0))
      goto NoMatch;
  }
  allpos[ok*2]=sx+x; allpos[ok*2+1]=sy+y;
  if (++ok>=allpos_max)
    goto Return1;
  // Clear the image that has been found
  for (i=0; i<len1; i++)
    ss[o+s1[i]]=0;
  NoMatch:
  if (dir==1) goto GoBack1;
  if (dir==2) goto GoBack2;
  if (dir==3) goto GoBack3;
  goto GoBack4;
  //----------------------
  Return1:
  return ok;
}

*/


;==== Optional GUI interface ====


Gui(cmd, arg1:="")
{
  local
  static
  global FindText
  local lls, bch, cri
  ListLines, % InStr("|KeyDown|LButtonDown|MouseMove|"
    , "|" cmd "|") ? "Off" : A_ListLines
  static init:=0
  if (!init)
  {
    init:=1
    Gui_:=ObjBindMethod(FindText,"Gui")
    Gui_G:=ObjBindMethod(FindText,"Gui","G")
    Gui_Run:=ObjBindMethod(FindText,"Gui","Run")
    Gui_Off:=ObjBindMethod(FindText,"Gui","Off")
    Gui_Show:=ObjBindMethod(FindText,"Gui","Show")
    Gui_KeyDown:=ObjBindMethod(FindText,"Gui","KeyDown")
    Gui_LButtonDown:=ObjBindMethod(FindText,"Gui","LButtonDown")
    Gui_MouseMove:=ObjBindMethod(FindText,"Gui","MouseMove")
    Gui_ScreenShot:=ObjBindMethod(FindText,"Gui","ScreenShot")
    Gui_ShowPic:=ObjBindMethod(FindText,"Gui","ShowPic")
    Gui_ToolTip:=ObjBindMethod(FindText,"Gui","ToolTip")
    Gui_ToolTipOff:=ObjBindMethod(FindText,"Gui","ToolTipOff")
    bch:=A_BatchLines, cri:=A_IsCritical
    Critical
    #NoEnv
    %Gui_%("Load_Language_Text")
    %Gui_%("MakeCaptureWindow")
    %Gui_%("MakeMainWindow")
    OnMessage(0x100, Gui_KeyDown)
    OnMessage(0x201, Gui_LButtonDown)
    OnMessage(0x200, Gui_MouseMove)
    Menu, Tray, Add
    Menu, Tray, Add, % Lang["1"], %Gui_Show%
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    {
      Menu, Tray, Default, % Lang["1"]
      Menu, Tray, Click, 1
      Menu, Tray, Icon, Shell32.dll, 23
    }
    Critical, %cri%
    SetBatchLines, %bch%
  }
  Switch cmd
  {
  Case "Off":
    return
  Case "G":
    GuiControl, +g, %id%, %Gui_Run%
    return
  Case "Run":
    Critical
    %Gui_%(A_GuiControl)
    return
  Case "Show":
    Gui, FindText_Main: Default
    Gui, Show, Center
    GuiControl, Focus, scr
    return
  Case "MakeCaptureWindow":
    ww:=35, hh:=12, WindowColor:="0xDDEEFF"
    Gui, FindText_Capture: New
    Gui, +AlwaysOnTop -DPIScale +HwndCapture_ID
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12, Verdana
    Gui, Add, Text, xm w855 h315 Section
    Gui, -Theme
    nW:=71, nH:=25, w:=11, C_:=[], Cid_:=[]
    Loop, % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "xs ys" : Mod(i,nW)=1 ? "xs y+1":"x+1"
      j.=i>nW*nH ? " cRed BackgroundFFFFAA" : ""
      Gui, Add, Progress, w%w% h%w% %j% +Hwndid
      Control, ExStyle, -0x20000,, ahk_id %id%
      C_[i]:=id, Cid_[id]:=i
    }
    Gui, +Theme
    Gui, Add, Slider, xm w855 vMySlider1 Hwndid Disabled
      +Center Page20 Line10 NoTicks AltSubmit
    %Gui_G%()
    Gui, Add, Slider, ym h315 vMySlider2 Hwndid Disabled
      +Center Page20 Line10 NoTicks AltSubmit +Vertical
    %Gui_G%()
    MySlider1:=MySlider2:=dx:=dy:=0
    Gui, Add, Button, xm+125 w50 vRepU Hwndid, % Lang["RepU"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutU Hwndid, % Lang["CutU"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutU3 Hwndid, % Lang["CutU3"]
    %Gui_G%()
    ;--------------
    Gui, Add, Text, x+50 yp+3 Section, % Lang["SelGray"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelGray ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelColor"]
    Gui, Add, Edit, x+3 yp-3 w120 vSelColor ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelR"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelR ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelG"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelG ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelB"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelB ReadOnly
    ;--------------
    Gui, Add, Button, xm w50 vRepL Hwndid, % Lang["RepL"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutL Hwndid, % Lang["CutL"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutL3 Hwndid, % Lang["CutL3"]
    %Gui_G%()
    Gui, Add, Button, x+15 w70 vAuto Hwndid, % Lang["Auto"]
    %Gui_G%()
    Gui, Add, Button, x+15 w50 vRepR Hwndid, % Lang["RepR"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutR Hwndid, % Lang["CutR"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutR3 Hwndid Section, % Lang["CutR3"]
    %Gui_G%()
    Gui, Add, Button, xm+125 w50 vRepD Hwndid, % Lang["RepD"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutD Hwndid, % Lang["CutD"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutD3 Hwndid, % Lang["CutD3"]
    %Gui_G%()
    ;--------------
    Gui, Add, Tab3, ys-8 -Wrap, % Lang["2"]
    Gui, Tab, 1
    Gui, Add, Text, x+15 y+15, % Lang["Threshold"]
    Gui, Add, Edit, x+15 w100 vThreshold
    Gui, Add, Button, x+15 yp-3 vGray2Two Hwndid, % Lang["Gray2Two"]
    %Gui_G%()
    Gui, Tab, 2
    Gui, Add, Text, x+15 y+15, % Lang["GrayDiff"]
    Gui, Add, Edit, x+15 w100 vGrayDiff, 50
    Gui, Add, Button, x+15 yp-3 vGrayDiff2Two Hwndid, % Lang["GrayDiff2Two"]
    %Gui_G%()
    Gui, Tab, 3
    Gui, Add, Text, x+15 y+15, % Lang["Similar1"] " 0"
    Gui, Add, Slider, x+0 w100 vSimilar1 Hwndid
      +Center Page1 NoTicks ToolTip, 100
    %Gui_G%()
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColor2Two Hwndid, % Lang["Color2Two"]
    %Gui_G%()
    Gui, Tab, 4
    Gui, Add, Text, x+15 y+15, % Lang["Similar2"] " 0"
    Gui, Add, Slider, x+0 w100 vSimilar2 Hwndid
      +Center Page1 NoTicks ToolTip, 100
    %Gui_G%()
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColorPos2Two Hwndid, % Lang["ColorPos2Two"]
    %Gui_G%()
    Gui, Tab, 5
    Gui, Add, Text, x+10 y+15, % Lang["DiffR"]
    Gui, Add, Edit, x+5 w70 vDiffR Limit3
    Gui, Add, UpDown, vdR Range0-255 Wrap
    Gui, Add, Text, x+5, % Lang["DiffG"]
    Gui, Add, Edit, x+5 w70 vDiffG Limit3
    Gui, Add, UpDown, vdG Range0-255 Wrap
    Gui, Add, Text, x+5, % Lang["DiffB"]
    Gui, Add, Edit, x+5 w70 vDiffB Limit3
    Gui, Add, UpDown, vdB Range0-255 Wrap
    Gui, Add, Button, x+5 yp-3 vColorDiff2Two Hwndid, % Lang["ColorDiff2Two"]
    %Gui_G%()
    Gui, Tab, 6
    Gui, Add, Text, x+10 y+15, % Lang["DiffRGB"]
    Gui, Add, Edit, x+5 w80 vDiffRGB Limit3
    Gui, Add, UpDown, vdRGB Range0-255 Wrap
    Gui, Add, Checkbox, x+15 yp+5 vMultColor Hwndid, % Lang["MultColor"]
    %Gui_G%()
    Gui, Add, Button, x+10 yp-5 vUndo Hwndid, % Lang["Undo"]
    %Gui_G%()
    Gui, Tab
    ;--------------
    Gui, Add, Button, xm vReset Hwndid, % Lang["Reset"]
    %Gui_G%()
    Gui, Add, Checkbox, x+15 yp+5 vModify Hwndid, % Lang["Modify"]
    %Gui_G%()
    Gui, Add, Text, x+30, % Lang["Comment"]
    Gui, Add, Edit, x+5 yp-2 w150 vComment
    Gui, Add, Button, x+30 yp-3 vSplitAdd Hwndid, % Lang["SplitAdd"]
    %Gui_G%()
    Gui, Add, Button, x+10 vAllAdd Hwndid, % Lang["AllAdd"]
    %Gui_G%()
    Gui, Add, Button, x+10 w80 vButtonOK Hwndid, % Lang["ButtonOK"]
    %Gui_G%()
    Gui, Add, Button, x+10 wp vClose gCancel, % Lang["Close"]
    Gui, Add, Button, xm vBind0 Hwndid, % Lang["Bind0"]
    %Gui_G%()
    Gui, Add, Button, x+15 vBind1 Hwndid, % Lang["Bind1"]
    %Gui_G%()
    Gui, Add, Button, x+15 vBind2 Hwndid, % Lang["Bind2"]
    %Gui_G%()
    Gui, Add, Button, x+15 vBind3 Hwndid, % Lang["Bind3"]
    %Gui_G%()
    Gui, Add, Button, x+15 vBind4 Hwndid, % Lang["Bind4"]
    %Gui_G%()
    Gui, Show, Hide, % Lang["3"]
    return
  Case "MakeMainWindow":
    Gui, FindText_Main: New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12 cBlack, Verdana
    Gui, Add, Text, xm, % Lang["NowHotkey"]
    Gui, Add, Edit, x+5 w200 vNowHotkey ReadOnly
    Gui, Add, Hotkey, x+5 w200 vSetHotkey1
    Gui, Add, DDL, x+5 w180 vSetHotkey2
      , % "||F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    Gui, Add, GroupBox, xm y+0 w280 h55 vMyGroup
    Gui, Add, Text, xp+15 yp+20 Section, % Lang["Myww"] ": "
    Gui, Add, Text, x+0 w60, %ww%
    Gui, Add, UpDown, vMyww Range1-50, %ww%
    Gui, Add, Text, x+15 ys, % Lang["Myhh"] ": "
    Gui, Add, Text, x+0 w60, %hh%
    Gui, Add, UpDown, vMyhh Range1-50, %hh%
    GuiControlGet, p, Pos, Myhh
    GuiControl, Move, MyGroup, % "w" (pX+pW) " h" (pH+30)
    x:=pX+pW+15*2
    Gui, Add, Button, x%x% ys-8 w150 vApply Hwndid, % Lang["Apply"]
    %Gui_G%()
    Gui, Add, Checkbox, x+15 ys Checked vAddFunc, % Lang["AddFunc"] " FindText()"
    Gui, Add, Button, xm y+18 w144 vCutL2 Hwndid, % Lang["CutL2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutR2 Hwndid, % Lang["CutR2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutU2 Hwndid, % Lang["CutU2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutD2 Hwndid, % Lang["CutD2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vUpdate Hwndid, % Lang["Update"]
    %Gui_G%()
    Gui, Font, s6 bold, Verdana
    Gui, Add, Edit, xm y+10 w720 r20 vMyPic -Wrap
    Gui, Font, s12 norm, Verdana
    Gui, Add, Button, xm w240 vCapture Hwndid, % Lang["Capture"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vTest Hwndid, % Lang["Test"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCopy Hwndid, % Lang["Copy"]
    %Gui_G%()
    Gui, Add, Button, xm y+0 wp vCaptureS Hwndid, % Lang["CaptureS"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vGetRange Hwndid, % Lang["GetRange"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vTestClip Hwndid, % Lang["TestClip"]
    %Gui_G%()
    Gui, Font, s12 cBlue, Verdana
    Gui, Add, Edit, xm w720 h350 vscr Hwndhscr -Wrap HScroll
    Gui, Show, Hide, % Lang["4"]
    return
  Case "Capture","CaptureS":
    Critical
    Gui, FindText_Main: +Hwndid
    if (show_gui:=(WinExist()=id))
    {
      Gui, FindText_Main: Default
      Gui, +LastFound
      WinMinimize
      Gui, Hide
    }
    ShowScreenShot:=InStr(cmd,"CaptureS")
    if (ShowScreenShot)
      FindText.ShowScreenShot(1)
    ;----------------------
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *RButton, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
    CoordMode, Mouse
    KeyWait, RButton
    KeyWait, Ctrl
    w:=ww, h:=hh, oldx:=oldy:="", r:=StrSplit(Lang["5"],"|")
    if (!show_gui)
      w:=20, h:=8
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y, Bind_ID
      if (!show_gui)
      {
        w:=x<=1 ? w-1 : x>=A_ScreenWidth-2 ? w+1:w
        h:=y<=1 ? h-1 : y>=A_ScreenHeight-2 ? h+1:h
        w:=(w<1 ? 1:w), h:=(h<1 ? 1:h)
      }
      %Gui_%("Mini_Show")
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
    KeyWait, RButton
    KeyWait, Ctrl
    px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      %Gui_%("Mini_Show")
      MouseGetPos, x1, y1
      if (oldx=x1 and oldy=y1)
        Continue
      oldx:=x1, oldy:=y1
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
    KeyWait, RButton
    KeyWait, Ctrl
    ToolTip
    %Gui_%("Mini_Hide")
    ListLines, %lls%
    Hotkey, *RButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    if (ShowScreenShot)
      FindText.ShowScreenShot(0)
    if (!show_gui)
      return [px-w, py-h, px+w, py+h]
    ;-----------------------
    %Gui_%("getcors", !ShowScreenShot)
    %Gui_%("Reset")
    Gui, FindText_Capture: Default
    Loop, 71
      GuiControl,, % C_[71*25+A_Index], 0
    Loop, 6
      GuiControl,, Edit%A_Index%
    GuiControl,, Modify, % Modify:=0
    GuiControl,, MultColor, % MultColor:=0
    GuiControl,, GrayDiff, 50
    GuiControl, Focus, Gray2Two
    GuiControl, +Default, Gray2Two
    Gui, Show, Center
    Event:=Result:=""
    DetectHiddenWindows, Off
    Critical, Off
    WinWaitClose, ahk_id %Capture_ID%
    Critical
    ToolTip
    Gui, FindText_Main: Default
    ;--------------------------------
    if (cors.bind!="")
    {
      WinGetTitle, tt, ahk_id %Bind_ID%
      WinGetClass, tc, ahk_id %Bind_ID%
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
      Result:="`nSetTitleMatchMode, 2`nid:=WinExist(""" tt """)"
        . "`nFindText.BindWindow(id" (cors.bind=0 ? "":"," cors.bind)
        . ")  `; " Lang["6"] " FindText.BindWindow(0)`n`n" Result
    }
    if (Event="ButtonOK")
    {
      if (!A_IsCompiled)
      {
        FileRead, s, %A_LineFile%
        s:=SubStr(s, s~="i)\n[;=]+ Copy The")
      }
      else s:=""
      GuiControl,, scr, % Result "`n" s
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(FindText.ASCII(Result),"`n")
      Result:=s:=""
    }
    else if (Event="SplitAdd") or (Event="AllAdd")
    {
      GuiControlGet, s,, scr
      i:=j:=0, r:="<[^>\n]*>[^$\n]+\$[\w+/.\-]+"
      While j:=RegExMatch(s,r,"",j+1)
        i:=InStr(s,"`n",0,j)
      GuiControl,, scr, % SubStr(s,1,i) . Result . SubStr(s,i+1)
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(FindText.ASCII(Result),"`n")
      Result:=s:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "Mini_Show":
    Gui, FindText_Mini_4: +LastFoundExist
    IfWinNotExist
    {
      Loop, 4
      {
        i:=A_Index
        Gui, FindText_Mini_%i%: +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
        Gui, FindText_Mini_%i%: Show, Hide, Mini
      }
    }
    d:=2, w:=w<0 ? 0:w, h:=h<0 ? 0:h, c:=A_MSec<500 ? "Red":"Blue"
    Loop, 4
    {
      i:=A_Index
      x1:=Floor(i=3 ? x+w+1 : x-w-d)
      y1:=Floor(i=4 ? y+h+1 : y-h-d)
      w1:=Floor(i=1 or i=3 ? d : 2*(w+d)+1)
      h1:=Floor(i=2 or i=4 ? d : 2*(h+d)+1)
      Gui, FindText_Mini_%i%: Color, %c%
      Gui, FindText_Mini_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
    }
    return
  Case "Mini_Hide":
    Gui, FindText_Mini_4: +Hwndid
    Loop, 4
      Gui, FindText_Mini_%A_Index%: Destroy
    WinWaitClose, ahk_id %id%,, 3
    return
  Case "getcors":
    FindText.xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
    if (w<1 or h<1)
      return
    SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
    if (arg1) or (!FindText.GetBitsFromScreen(0,0,0,0,0).hBM)
      FindText.ScreenShot()
    cors:=[], gray:=[], k:=0
    ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
    Loop, %nH%
    {
      j:=py-hh+A_Index-1, i:=px-ww
      Loop, %nW%
        cors[++k]:=c:=FindText.GetColor(i++,j,0)
        , gray[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    }
    ListLines, %lls%
    cors.CutLeft:=Abs(px-ww-x)
    cors.CutRight:=Abs(px+ww-(x+w-1))
    cors.CutUp:=Abs(py-hh-y)
    cors.CutDown:=Abs(py+hh-(y+h-1))
    SetBatchLines, %bch%
    return
  Case "GetRange":
    Critical
    Gui, FindText_Main: +Hwndid
    if (show_gui:=(WinExist()=id))
      Gui, FindText_Main: Hide
    ;---------------------
    Gui, FindText_GetRange: New
    Gui, +LastFound +AlWaysOnTop +ToolWindow -Caption -DPIScale +E0x08000000
    Gui, Color, White
    WinSet, Transparent, 10
    FindText.xywh2xywh(0,0,0,0,0,0,0,0,x,y,w,h)
    Gui, Show, NA x%x% y%y% w%w% h%h%, GetRange
    ;---------------------
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *LButton, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
    CoordMode, Mouse
    KeyWait, LButton
    KeyWait, Ctrl
    oldx:=oldy:="", r:=Lang["7"]
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, %r%
    }
    Until GetKeyState("LButton","P") or GetKeyState("Ctrl","P")
    px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      w:=Abs(px-x)//2, h:=Abs(py-y)//2, x:=(px+x)//2, y:=(py+y)//2
      %Gui_%("Mini_Show")
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, %r%
    }
    Until !(GetKeyState("LButton","P") or GetKeyState("Ctrl","P"))
    ToolTip
    %Gui_%("Mini_Hide")
    ListLines, %lls%
    Hotkey, *LButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    Gui, FindText_GetRange: Destroy
    Clipboard:=p:=(x-w) ", " (y-h) ", " (x+w) ", " (y+h)
    if (!show_gui)
      return StrSplit(p, ",", " ")
    ;---------------------
    Gui, FindText_Main: Default
    GuiControlGet, s,, scr
    if RegExMatch(s, "i)(=\s*FindText\()([^,]*,){4}", r)
    {
      s:=StrReplace(s, r, r1 . p ",", 0, 1)
      GuiControl,, scr, %s%
    }
    Gui, Show
    return
  Case "Test","TestClip":
    Gui, FindText_Main: Default
    Gui, +LastFound
    WinMinimize
    Gui, Hide
    DetectHiddenWindows, Off
    WinWaitClose, % "ahk_id " WinExist()
    Sleep, 100
    ;----------------------
    if (cmd="Test")
      GuiControlGet, s,, scr
    else
      s:=Clipboard
    if (!A_IsCompiled) and InStr(s,"MCode(") and (cmd="Test")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n" s "`nExitApp`n"
      Thread:= new FindText.Thread(s)
      DetectHiddenWindows, On
      WinWait, % "ahk_class AutoHotkey ahk_pid " Thread.pid,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
      Thread:=""  ; kill the Thread
    }
    else
    {
      Gui, +OwnDialogs
      t:=A_TickCount, n:=150000
      , RegExMatch(s,"<[^>\n]*>[^$\n]+\$[\w+/.\-]+",v)
      , ok:=FindText.FindText(-n, -n, n, n, 0, 0, v)
      , X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
      r:=StrSplit(Lang["8"],"|")
      MsgBox, 4096, Tip, % r.1 ":`t" Round(ok.MaxIndex()) "`n`n"
        . r.2 ":`t" (A_TickCount-t) " " r.3 "`n`n"
        . r.4 ":`t" X ", " Y "`n`n"
        . r.5 ":`t" (ok ? r.6 " ! " Comment : r.7 " !"), 3
      for i,v in ok
        if (i<=2)
          FindText.MouseTip(ok[i].x, ok[i].y)
      ok:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "Copy":
    Gui, FindText_Main: Default
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      GuiControlGet, s,, scr
      GuiControlGet, r,, AddFunc
      if (r != 1)
        s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
    }
    Clipboard:=RegExReplace(s,"\R","`r`n")
    ;----------------------
    Gui, Hide
    Sleep, 100
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "Apply":
    Gui, FindText_Main: Default
    GuiControlGet, NowHotkey
    GuiControlGet, SetHotkey1
    GuiControlGet, SetHotkey2
    if (NowHotkey!="")
      Hotkey, *%NowHotkey%,, Off UseErrorLevel
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Hotkey, *%k%, %Gui_ScreenShot%, On UseErrorLevel
    GuiControl,, NowHotkey, %k%
    GuiControl,, SetHotkey1
    GuiControl, Choose, SetHotkey2, 0
    ;------------------------
    GuiControlGet, Myww
    GuiControlGet, Myhh
    if (Myww!=ww or Myhh!=hh)
    {
      nW:=71, dx:=dy:=0
      Loop, % 71*25
        k:=A_Index, c:=WindowColor, %Gui_%("SetColor")
      ww:=Myww, hh:=Myhh, nW:=2*ww+1, nH:=2*hh+1
      i:=nW>71, j:=nH>25
      Gui, FindText_Capture: Default
      GuiControl, Enable%i%, MySlider1
      GuiControl, Enable%j%, MySlider2
      GuiControl,, MySlider1, % MySlider1:=0
      GuiControl,, MySlider2, % MySlider2:=0
    }
    return
  Case "ScreenShot":
    Critical
    FindText.ScreenShot()
    Gui, FindText_Tip: New
    ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
    Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000020
    Gui, Color, Yellow
    Gui, Font, cRed s48 bold
    Gui, Add, Text,, % Lang["9"]
    WinSet, Transparent, 200
    Gui, Show, NA y0, ScreenShot Tip
    Sleep, 1000
    Gui, Destroy
    return
  Case "Bind0","Bind1","Bind2","Bind3","Bind4":
    Critical
    FindText.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,0))
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *RButton, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
    CoordMode, Mouse
    KeyWait, RButton
    KeyWait, Ctrl
    oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ;---------------
      px:=x, py:=y, %Gui_%("getcors",1)
      %Gui_%("Reset"), r:=StrSplit(Lang["10"],"|")
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until GetKeyState("RButton","P") or GetKeyState("Ctrl","P")
    KeyWait, RButton
    KeyWait, Ctrl
    ToolTip
    ListLines, %lls%
    Hotkey, *RButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    FindText.BindWindow(0), cors.bind:=bind_mode
    return
  Case "MySlider1","MySlider2":
    Thread, Priority, 10
    Critical, Off
    dx:=nW>71 ? Round((nW-71)*MySlider1/100) : 0
    dy:=nH>25 ? Round((nH-25)*MySlider2/100) : 0
    if (oldx=dx and oldy=dy)
      return
    oldx:=dx, oldy:=dy, k:=0
    Loop, % nW*nH
      c:=(!show[++k] ? WindowColor
      : bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), %Gui_%("SetColor")
    if (cmd="MySlider2")
      return
    Loop, 71
      GuiControl,, % C_[71*25+A_Index], 0
    Loop, % nW
    {
      i:=A_Index-dx
      if (i>=1 && i<=71 && show[nW*nH+A_Index])
        GuiControl,, % C_[71*25+i], 100
    }
    return
  Case "Reset":
    show:=[], ascii:=[], bg:=""
    CutLeft:=CutRight:=CutUp:=CutDown:=k:=0
    Loop, % nW*nH
      show[++k]:=1, c:=cors[k], %Gui_%("SetColor")
    Loop, % cors.CutLeft
      %Gui_%("CutL")
    Loop, % cors.CutRight
      %Gui_%("CutR")
    Loop, % cors.CutUp
      %Gui_%("CutU")
    Loop, % cors.CutDown
      %Gui_%("CutD")
    return
  Case "SetColor":
    if (nW=71 && nH=25)
      tk:=k
    else
    {
      tx:=Mod(k-1,nW)-dx, ty:=(k-1)//nW-dy
      if (tx<0 || tx>=71 || ty<0 || ty>=25)
        return
      tk:=ty*71+tx+1
    }
    c:=c="Black" ? 0x000000 : c="White" ? 0xFFFFFF
      : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
    SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[tk]
    return
  Case "RepColor":
    show[k]:=1, c:=(bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), %Gui_%("SetColor")
    return
  Case "CutColor":
    show[k]:=0, c:=WindowColor, %Gui_%("SetColor")
    return
  Case "RepL":
    if (CutLeft<=cors.CutLeft)
    or (bg!="" and InStr(color,"**")
    and CutLeft=cors.CutLeft+1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutL3":
    Loop, 3
      %Gui_%("CutL")
    return
  Case "RepR":
    if (CutRight<=cors.CutRight)
    or (bg!="" and InStr(color,"**")
    and CutRight=cors.CutRight+1)
      return
    k:=1-CutRight, CutRight--
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutR3":
    Loop, 3
      %Gui_%("CutR")
    return
  Case "RepU":
    if (CutUp<=cors.CutUp)
    or (bg!="" and InStr(color,"**")
    and CutUp=cors.CutUp+1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutU3":
    Loop, 3
      %Gui_%("CutU")
    return
  Case "RepD":
    if (CutDown<=cors.CutDown)
    or (bg!="" and InStr(color,"**")
    and CutDown=cors.CutDown+1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutD3":
    Loop, 3
      %Gui_%("CutD")
    return
  Case "Gray2Two":
    Gui, FindText_Capture: Default
    GuiControl, Focus, Threshold
    GuiControlGet, Threshold
    if (Threshold="")
    {
      pp:=[]
      Loop, 256
        pp[A_Index-1]:=0
      Loop, % nW*nH
        if (show[A_Index])
          pp[gray[A_Index]]++
      IP:=IS:=0
      Loop, 256
        k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
      Threshold:=Floor(IP/IS)
      Loop, 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop, % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP-IP1, IS2:=IS-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      GuiControl,, Threshold, %Threshold%
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop, % nW*nH
    {
      ascii[++k]:=v:=(gray[k]<=Threshold)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "GrayDiff2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, GrayDiff
    if (GrayDiff="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % "`n" Lang["11"] " !`n", 1
      return
    }
    if (CutLeft=cors.CutLeft)
      %Gui_%("CutL")
    if (CutRight=cors.CutRight)
      %Gui_%("CutR")
    if (CutUp=cors.CutUp)
      %Gui_%("CutU")
    if (CutDown=cors.CutDown)
      %Gui_%("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop, % nW*nH
    {
      j:=gray[++k]+GrayDiff
      , ascii[k]:=v:=( gray[k-1]>j or gray[k+1]>j
      or gray[k-nW]>j or gray[k+nW]>j
      or gray[k-nW-1]>j or gray[k-nW+1]>j
      or gray[k+nW-1]>j or gray[k+nW+1]>j )
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "Color2Two","ColorPos2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % "`n" Lang["12"] " !`n", 1
      return
    }
    UsePos:=(cmd="ColorPos2Two") ? 1:0
    GuiControlGet, n,, Similar1
    n:=Round(n/100,2), color:=c "@" n
    , n:=Floor(9*255*255*(1-n)*(1-n)), k:=i:=0
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    Loop, % nW*nH
    {
      c:=cors[++k], r:=((c>>16)&0xFF)-rr
      , g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
      , ascii[k]:=v:=(3*r*r+4*g*g+2*b*b<=n)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "ColorDiff2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % "`n" Lang["12"] " !`n", 1
      return
    }
    GuiControlGet, dR
    GuiControlGet, dG
    GuiControlGet, dB
    rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
    , color:=StrReplace(c "-" n,"0x"), k:=i:=0
    Loop, % nW*nH
    {
      c:=cors[++k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF
      , b:=c&0xFF, ascii[k]:=v:=(Abs(r-rr)<=dR
      and Abs(g-gg)<=dG and Abs(b-bb)<=dB)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "Modify":
    GuiControlGet, Modify
    return
  Case "MultColor":

    GuiControlGet, MultColor
    Result:=""
    ToolTip
    return
  Case "Undo":
    Result:=RegExReplace(Result,"/\w+/\w+/\w+$")
    ToolTip, % Trim(Result,"/")
    return
  Case "Similar1":
    GuiControl, FindText_Capture:, Similar2, %Similar1%
    return
  Case "Similar2":
    GuiControl, FindText_Capture:, Similar1, %Similar2%
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    ListLines, % (lls:=A_ListLines=0?"Off":"On")?"Off":"Off"
    k:=0
    Loop, %nH%
    {
      v:=""
      Loop, %nW%
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines, %lls%
    return
  Case "Auto":
    %Gui_%("GetTxt")
    if (txt="")
    {
      Gui, FindText_Capture: +OwnDialogs
      MsgBox, 4096, Tip, % "`n" Lang["13"] " !`n", 1
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt,"^" bg "+\n"), %Gui_%("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt,"m`n)" bg "$"), %Gui_%("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt,"\n\K" bg "+\n$"), %Gui_%("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt,"m`n)^" bg), %Gui_%("CutL")
      else Break
    }
    txt:=""
    return
  Case "ButtonOK","SplitAdd","AllAdd":
    Gui, FindText_Capture: Default
    Gui, +OwnDialogs
    %Gui_%("GetTxt")
    if (txt="") and (!MultColor)
    {
      MsgBox, 4096, Tip, % "`n" Lang["13"] " !`n", 1
      return
    }
    if InStr(color,"@") and (UsePos)
    {
      r:=StrSplit(color,"@")
      k:=i:=j:=0
      Loop, % nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=cors.SelPos)
        {
          j:=i
          Break
        }
      }
      if (j=0)
      {
        MsgBox, 4096, Tip, % "`n" Lang["12"] " !`n", 1
        return
      }
      color:="#" (j-1) "@" r.2
    }
    GuiControlGet, Comment
    if (cmd="SplitAdd") and (!MultColor)
    {
      if InStr(color,"#")
      {
        MsgBox, 4096, Tip, % Lang["14"], 3
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop, % w:=nW-CutLeft-CutRight
      {
        i++
        if (!show[k++] and A_Index<w)
          Continue
        i:=Format("{:d}",i)
        v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
        txt:=RegExReplace(txt,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}",InStr(v,"`n")-1) "." FindText.bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    if (!MultColor)
    {
      txt:=Format("{:d}",InStr(txt,"`n")-1) "." FindText.bit2base64(txt)
      s:="`nText.=""|<" Comment ">" color "$" txt """`n"
    }
    else
    {
      GuiControlGet, dRGB
      color:="##" dRGB, r:=StrSplit(Trim(Result,"/"),"/")
      , s:="", x:=r.1, y:=r.2, i:=1
      Loop, % r.MaxIndex()//3
        s.="/" (r[i++]-x) "/" (r[i++]-y) "/" r[i++]
      s:="`nText.=""|<" Comment ">" color "$" Trim(s,"/") """`n"
    }
    if (cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    x:=px-ww+CutLeft+(nW-CutLeft-CutRight)//2
    y:=py-hh+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["8"],"|")
    s:="`; #Include <FindText>`n"
    . "`n t1:=A_TickCount, X:=Y:=""""`n" s
    . "`n if (ok:=FindText(" x "-150000, " y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n {"
    . "`n   CoordMode, Mouse"
    . "`n   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id"
    . "`n   `; Click, `%X`%, `%Y`%"
    . "`n }`n"
    . "`n MsgBox, 4096, Tip, `% """ r.1 ":``t"" Round(ok.MaxIndex())"
    . "`n   . ""``n``n" r.2 ":``t"" (A_TickCount-t1) "" " r.3 """"
    . "`n   . ""``n``n" r.4 ":``t"" X "", "" Y"
    . "`n   . ""``n``n" r.5 ":``t"" (ok ? """ r.6 " !"" : """ r.7 " !"")`n"
    . "`n for i,v in ok"
    . "`n   if (i<=2)"
    . "`n     FindText.MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    Gui, Hide
    return
  Case "KeyDown":
    Critical
    if (A_Gui="FindText_Main" && A_GuiControl="scr")
      SetTimer, %Gui_ShowPic%, -150
    return
  Case "ShowPic":
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    GuiControl, FindText_Main:, MyPic, % Trim(FindText.ASCII(s),"`n")
    return
  Case "LButtonDown":
    Critical
    if (A_Gui!="FindText_Capture")
      return %Gui_%("KeyDown")
    MouseGetPos,,,, k2, 2
    if (k1:=Round(Cid_[k2]))<1
      return
    Gui, FindText_Capture: Default
    if (k1>71*25)
    {
      GuiControlGet, k3,, %k2%
      GuiControl,, %k2%, % k3 ? 0:100
      show[nW*nH+(k1-71*25)+dx]:=(!k3)
      return
    }
    k2:=Mod(k1-1,71)+dx, k3:=(k1-1)//71+dy
    if (k2>=nW || k3>=nH)
      return
    k1:=k, k:=k3*nW+k2+1, k2:=c
    if (MultColor and show[k])
    {
      c:="/" Mod(k-1,nW) "/" k3 "/"
      . Format("{:06X}",cors[k]&0xFFFFFF)
      , Result.=InStr(Result,c) ? "":c
      ToolTip, % Trim(Result,"/")
    }
    else if (Modify and bg!="" and show[k])
    {
      c:=((ascii[k]:=!ascii[k]) ? "Black":"White")
      , %Gui_%("SetColor")
    }
    else
    {
      c:=cors[k], cors.SelPos:=k
      GuiControl,, SelGray, % gray[k]
      GuiControl,, SelColor, % Format("0x{:06X}",c&0xFFFFFF)
      GuiControl,, SelR, % (c>>16)&0xFF
      GuiControl,, SelG, % (c>>8)&0xFF
      GuiControl,, SelB, % c&0xFF
    }
    k:=k1, c:=k2
    return
  Case "MouseMove":
    static PrevControl:=""
    if (PrevControl!=A_GuiControl)
    {
      PrevControl:=A_GuiControl
      SetTimer, %Gui_ToolTip%, % PrevControl ? -500 : "Off"
      SetTimer, %Gui_ToolTipOff%, % PrevControl ? -5500 : "Off"
      ToolTip
    }
    return
  Case "ToolTip":
    MouseGetPos,,, _TT
    IfWinExist, ahk_id %_TT% ahk_class AutoHotkeyGUI
      ToolTip, % Tip_Text[PrevControl ""]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2","CutR2","CutU2","CutD2":
    Gui, FindText_Main: Default
    GuiControlGet, s,, MyPic
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    GuiControl,, MyPic, % Trim(s,"`n")
    return
  Case "Update":
    Gui, FindText_Main: Default
    GuiControl, Focus, scr
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    if !RegExMatch(s,"(<[^>]*>[^$]+\$)\d+\.[\w+/]+",r)
      return
    GuiControlGet, v,, MyPic
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s,r,r1 . w "." FindText.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend,, %v%, ahk_id %hscr%
    Control, EditPaste, %s%,, ahk_id %hscr%
    ControlSend,, {Home}, ahk_id %hscr%
    return
  Case "Load_Language_Text":
    s=
    (
Myww       = Width = Adjust the width of the capture range
Myhh       = Height = Adjust the height of the capture range
AddFunc    = Add = Additional FindText() in Copy
NowHotkey  = Hotkey = Current screenshot hotkey
SetHotkey1 = = First sequence Screenshot hotkey
SetHotkey2 = = Second sequence Screenshot hotkey
Apply      = Apply = Apply new screenshot hotkey and adjusted capture range values
CutU2      = CutU = Cut the Upper Edge of the text in the edit box below
CutL2      = CutL = Cut the Left Edge of the text in the edit box below
CutR2      = CutR = Cut the Right Edge of the text in the edit box below
CutD2      = CutD = Cut the Lower Edge of the text in the edit box below
Update     = Update = Update the text in the edit box below to the line of code
GetRange   = GetRange = Get screen range to clipboard and replace the range in the code
TestClip   = TestClipboard = Test the Text data in the clipboard for searching images
Capture    = Capture = Initiate Image Capture Sequence
CaptureS   = CaptureS = Restore the last screenshot and then start capturing
Test       = Test = Test Results of Code
Copy       = Copy = Copy Code to Clipboard
Reset      = Reset = Reset to Original Captured Image
SplitAdd   = SplitAdd = Using Markup Segmentation to Generate Text Library
AllAdd     = AllAdd = Append Another FindText Search Text into Previously Generated Code
ButtonOK   = OK = Create New FindText Code for Testing
Close      = Close = Close the Window Don't Do Anything
Gray2Two      = Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
GrayDiff2Two  = GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
Color2Two     = Color2Two = Converts Image Pixels from Color Similar to Black or White
ColorPos2Two  = ColorPos2Two = Converts Image Pixels from Color Position to Black or White
ColorDiff2Two = ColorDiff2Two = Converts Image Pixels from Color Difference to Black or White
SelGray    = Gray = Gray value of the selected color
SelColor   = Color = The selected color
SelR       = R = Red component of the selected color
SelG       = G = Green component of the selected color
SelB       = B = Blue component of the selected color
RepU       = -U = Undo Cut the Upper Edge by 1
CutU       = U = Cut the Upper Edge by 1
CutU3      = U3 = Cut the Upper Edge by 3
RepL       = -L = Undo Cut the Left Edge by 1
CutL       = L = Cut the Left Edge by 1
CutL3      = L3 = Cut the Left Edge by 3
Auto       = Auto = Automatic Cut Edge after image has been converted to black and white
RepR       = -R = Undo Cut the Right Edge by 1
CutR       = R = Cut the Right Edge by 1
CutR3      = R3 = Cut the Right Edge by 3
RepD       = -D = Undo Cut the Lower Edge by 1
CutD       = D = Cut the Lower Edge by 1
CutD3      = D3 = Cut the Lower Edge by 3
Modify     = Modify = Allows Modify the Black and White Image
MultColor  = FindMultColor = Click multiple colors with the mouse, and then find multiple colors
Undo       = Undo = Undo the last selected color
Comment    = Comment = Optional Comment used to Label Code ( Within <> )
Threshold  = Gray Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
GrayDiff   = Gray Difference = Gray Difference which Determines Black or White Pixel Conversion (0-255)
Similar1   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar2   = Similarity = Adjust color similarity as Equivalent to The Selected Color
DiffR      = R = Red Difference which Determines Black or White Pixel Conversion (0-255)
DiffG      = G = Green Difference which Determines Black or White Pixel Conversion (0-255)
DiffB      = B = Blue Difference which Determines Black or White Pixel Conversion (0-255)
DiffRGB    = R/G/B = Determine the allowed R/G/B Error (0-255) when Find MultiColor
Bind0      = BindWindow1 = Bind the window and Use GetDCEx() to get the image of background window
Bind1      = BindWindow1+ = Bind the window Use GetDCEx() and Modify the window to support transparency
Bind2      = BindWindow2 = Bind the window and Use PrintWindow() to get the image of background window
Bind3      = BindWindow2+ = Bind the window Use PrintWindow() and Modify the window to support transparency
Bind4      = BindWindow3 = Bind the window and Use PrintWindow(,,3) to get the image of background window
1  = FindText
2  = Gray|GrayDiff|Color|ColorPos|ColorDiff|MultColor
3  = Capture Image To Text
4  = Capture Image To Text And Find Text Tool
5  = Position|First click RButton\nMove the mouse away\nSecond click RButton
6  = Unbind Window using
7  = Please drag a range with the LButton\nCoordinates are copied to clipboard
8  = Found|Time|ms|Pos|Result|Success|Failed
9  = Success
10 = The Capture Position|Perspective binding window\nRight click to finish capture
11 = Please Set Gray Difference First
12 = Please select the core color first
13 = Please convert the image to black or white first
14 = Can't be used in ColorPos mode, because it can cause position errors
    )
    Lang:=[], Tip_Text:=[]
    Loop, Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v,"\n","`n"), "=", "`t ")
        , Lang[r.1 ""]:=r.2, Tip_Text[r.1 ""]:=r.3
    return
  }
}

}  ;// Class End

;================= The End =================
;============================
;Checking for Game element based off unity loading symbol
Loop
{
sleep 120

Text:="|<>0xFFFFFF@1.00$71.00007zzzzzzk0003zzzzzzzU000zzzzzzzz000Tzzzzzzzy001zzzzzzzzy003zzzzzzzzw00Dzzzzzzzzs00Tzzzzzzzzs01zzzzzrzzzk07zzzzsDzzzU0Dzzzw0Tzzz00zzzz01zzzz01zzzU07zzzy07zzk00Dzzzw0Dzs000zzzzs0zw0001zzDzkTy00007zyTzzz00000Dzszzzk00000zzVzzzU00003zz1zzy000007zw3zzs00000Tzs7zzU00000zzU7zy000003zy0Dzs000007zw0Tz"

	if (ok:=FindText(1127-150000, 551-150000, 1127+150000, 551+150000, 0, 0, Text))
	{
	Goto checklogin
	}
}




;===========================CLAIM AND NEWS CLOSE============================
checklogin:
/*
Text:="|<>0xFFFFFF@1.00$71.00000000000000000000000000000000000000000000000000000000000000000000000Dz3007w3UTz0Ty600Ds70zz3U0A01kQC773b00M03UsQCC7C00k071ksQQCQ01U0C3VkssQs0300Tz3Vlktk0600zy73XVnU0A01kQC773b00M03UsQCC7C00k071ksQQCQ01U0C3VkssQDz1zsQ73VlksTy1zksC73XVk00000000000000000000000000000000000000000000000000000000001"
;claim button
 if (ok:=FindText(1121-150000, 750-150000, 1121+150000, 750+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
 }
 

Loop, 10
{
Sleep 800
Text:="|<>0xFFFFFF@1.00$71.0000000000000000000000000000s3U000000001s70000000003kC0000000007UQ000000000D0s000000000Tzk000000000Dy0000000000Dw0000000000Ts0000000000zk0000000001zU0000000003z0000000000zzU000000001s70000000003kC0000000007UQ000000000D0s000000000Q1k0000000000000000000000000000000000000000000000000000000000000001"
;X button for closing news and item/claim reward screens and bait.
 if (ok:=FindText(1313-150000, 445-150000, 1313+150000, 445+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
 }


 

if bountiescheck = 0
{
Text:="|<>0x7B5E33@1.00$10.NVa0003UC0y3sC7sTsDUy3sDyzu080zXyC0s000002" 
; Bounty Board
 if (ok:=FindText(858-150000, 876-150000, 858+150000, 876+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
	sleep 600
 }

Text:="|<>0xFFFFFF@1.00$71.0000000000000000000000000000000000000000000000000000000000000000000000003007w0zUDzU0600Ds1zUTz00A01sQD3k7U00M03UsQ3U7000k071ks70C001U0C3VkC0Q00300Q73UQ0s00600sC70s1k00A01kQC1k3U00M03UsQ3U7000k071ks70C001U0C3VkC0Q003zsTz3zw0s001zkDs1z01k003zUTk3y03U000000000000000000000000000000000000000000000001" 
; Bounty board Loot button
 if (ok:=FindText(1262-150000, 586-150000, 1262+150000, 586+150000, 0, 0, Text))
 {
Sleep 150
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
 }
}

*/
;Auto Use
Home::
if AutoUse = true
{
Text:="|<>0x393A3B@1.00$25.0s003U001k000s000U000E000800003s001w000y003z001zU00zk00zs00Tw00Dy00zz00TzU000000000000000000000000000000E"
;lower left check
 if (ok:=FindText(804-150000, 954-150000, 804+150000, 954+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 900
 }   
   Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zzk000000003zzU000000007zz0000000001zk0000000003zU0000000007z00000000001k00000000003U0000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
;Clicks the menu drop down so consumables can be selected, regardless if its the one being displayed already
 if (ok:=FindText(1270-150000, 458-150000, 1270+150000, 458+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 900
 }  
Text:="|<>0xFFFFFF@1.00$101.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000Tw3y0Tk1zksC1zy00zs7w0zU3zVkQ3zw0Dzkzy7zkzz3UsTzy6Q01kQC1Vk071ksMQAs03UsQ33U0C3VkksNk071ks6700Q73VVknU0C3VkADz0sC733Vb00Q73UM3y1kQC673C00sC70k7z3UsQAC6Q01kQC1U0C71ksMQAs03UsQ300QC3VkksNk071ks600sQ73VVknzwDzVkA7zkzy733VUzs7w3UMTy0TkC6731zkDs70kzw0zUQAC60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
;consumables search
 if (ok:=FindText(1072-150000, 686-150000, 1072+150000, 686+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   send {esc}
   sleep 900
 }
 Text:="|<>0x2B2B2B@0.93$18.0000000000000000000003zk3zk0z00z00A00A0000000000000000000U"
;scrolling down to the minor boosts
 if (ok:=FindText(1277-150000, 760-150000, 1277+150000, 760+150000, 0, 0, Text))
 {
		Loop, 18
		{
			CoordMode, Mouse
			X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
			Click, %X%, %Y%
			sleep 100
		}
 }
goto autoconsume
}
else
{
;goto mainloop
}

AutoConsume:
;check for minor exp, item find and gold boosts and use them
Text:="|<>0xFFDF5A@0.85$61.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000S000000000DU000000007s000000003XU00000001lk00000000ss0000000000000000000000000000000000000003w000000001y000000000z000000000Q000000000C00000000070000000003w000000001y000000000z000000003w000000001y000000000z00000003UTU0000001kDk0000000s7s0000000Q000000000C00000000070000000003U000000001k000000000s000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
;Gold pot check
 if (ok:=FindText(1284-150000, 674-150000, 1284+150000, 674+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 900
Text:="|<>0xFFFFFF@0.93$97.000000000000000000000000000000001w1zUz1U0TUDUDw00y0zkTUk0Dk7s7y01Ukk0sMM0QCA66000kMM0MAA0C7633000MAA0A66073X01U00Dy7k7z303zlU0y007w3s3z1U1zsk0T00361U1k0k0sQM0A001XUk0k0M0QCA06000kMM0M0A0C7633000MADyA07z73XzVzk0A63z600zXVkT0Ts0000000000000000000000000000000002"
;checking to see if there is a replace buff screen
 if (ok:=FindText(1124-150000, 738-150000, 1124+150000, 738+150000, 0, 0, Text))
{
send {esc}
sleep 900
goto expconsume
}
;checking that we actually hit a minor tier consumable
Text:="|<>0x97FF7D@0.93$61.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zw71z0Tk7wzy3UzUDs3yTzlkzwDz7zssssMC63XUwQQQA731lkSCCC63VUssD77731kkQTwXXXVUsMCDyFllkkQA7778sssMC63XXwQQQA731lkSCCC63VzssD77731kTkQ7XXXVUsDsC3U0000000000000000000000000000000000000001"
 if (ok:=FindText(1207-150000, 710-150000, 1207+150000, 710+150000, 0, 0, Text))
{
Text:="|<>0xFFFFFF@0.93$57.00000000000000000000000000000000000000000000000000000000000000000003Us7zUTw00Q70zw7zU03UsS01k000Q73U0A0003UsQ01U000Q73U0C0003zsTk1zk007w3y03y000zUTk0Tw001k3U003U00C0Q000Q001k3U003U00C0TzVzw001k0zwDy000C07zVzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
;yes button consume screen
 if (ok:=FindText(1053-150000, 830-150000, 1053+150000, 830+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 1000
 }
}
}
expconsume:
Text:="|<>0x0095B2@0.96$41.000000000000000000000000000000000003XU00007700000CC00003XXU0007770000CCC00003XU00007700000CC00003XXU0007770000CCC00003XXU0007770000CCC0003XXU0007770000CCC00003XXU0007770000CCC0003XXU0007770000CCC00003XU00007700000CC00000QQQ0000sss0001llk0000000000000001"
;EXP tome check
 if (ok:=FindText(1353-150000, 671-150000, 1353+150000, 671+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 900
Text:="|<>0xFFFFFF@0.93$97.000000000000000000000000000000001w1zUz1U0TUDUDw00y0zkTUk0Dk7s7y01Ukk0sMM0QCA66000kMM0MAA0C7633000MAA0A66073X01U00Dy7k7z303zlU0y007w3s3z1U1zsk0T00361U1k0k0sQM0A001XUk0k0M0QCA06000kMM0M0A0C7633000MADyA07z73XzVzk0A63z600zXVkT0Ts0000000000000000000000000000000002"
;checking to see if there is a replace buff screen
 if (ok:=FindText(1124-150000, 738-150000, 1124+150000, 738+150000, 0, 0, Text))
{
sleep 900
send {esc}
sleep 500
mousemove, 400, 400
sleep 100
goto itemscrollconsume
}

;checking that we actually hit a minor tier consumable
Text:="|<>0x97FF7D@0.93$61.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zw71z0Tk7wzy3UzUDs3yTzlkzwDz7zssssMC63XUwQQQA731lkSCCC63VUssD77731kkQTwXXXVUsMCDyFllkkQA7778sssMC63XXwQQQA731lkSCCC63VzssD77731kTkQ7XXXVUsDsC3U0000000000000000000000000000000000000001"
 if (ok:=FindText(1207-150000, 710-150000, 1207+150000, 710+150000, 0, 0, Text))
{
Text:="|<>0xFFFFFF@0.93$57.00000000000000000000000000000000000000000000000000000000000000000003Us7zUTw00Q70zw7zU03UsS01k000Q73U0A0003UsQ01U000Q73U0C0003zsTk1zk007w3y03y000zUTk0Tw001k3U003U00C0Q000Q001k3U003U00C0TzVzw001k0zwDy000C07zVzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
;yes button consume screen
 if (ok:=FindText(1053-150000, 830-150000, 1053+150000, 830+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 1000
 }
}
}
itemscrollconsume:
Text:="|<>0xD4CCAC@0.86$41.0008410000E0000008000004TUDk00A000000Q0000007z00000Dy00000Tw000000000000000000000000s000001k000003U00000zzs0001zzk0003zzU000zzz0001zzy0003zzw00000z000001y000003w00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
;Item Find scroll check
 if (ok:=FindText(1213-150000, 747-150000, 1213+150000, 747+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 900
Text:="|<>0xFFFFFF@1.00$83.00000000000000000000000000007s3y1w700y0z0MDk7w3sC01y1y0kksk0MAQ0A66371UlU0kMs0MAA6A31X01Ulk0kMM0M7z7s3zXU1zkk0wDsDk7w703zVU1sMkM0A0C063303UlUk0M0Q0A66061UlU0k0s0MAA6A31XzVU1zskMTwS631z300zlUkTUA00000000000000000000000000000000000000000E"
;checks for existing buff
 if (ok:=FindText(1174-150000, 635-150000, 1174+150000, 635+150000, 0, 0, Text))
{
goto teamclose
}

;checking that we actually hit a minor tier consumable
Text:="|<>0x97FF7D@0.93$61.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zw71z0Tk7wzy3UzUDs3yTzlkzwDz7zssssMC63XUwQQQA731lkSCCC63VUssD77731kkQTwXXXVUsMCDyFllkkQA7778sssMC63XXwQQQA731lkSCCC63VzssD77731kTkQ7XXXVUsDsC3U0000000000000000000000000000000000000001"
 if (ok:=FindText(1207-150000, 710-150000, 1207+150000, 710+150000, 0, 0, Text))
{
Text:="|<>0xFFFFFF@0.93$57.00000000000000000000000000000000000000000000000000000000000000000003Us7zUTw00Q70zw7zU03UsS01k000Q73U0A0003UsQ01U000Q73U0C0003zsTk1zk007w3y03y000zUTk0Tw001k3U003U00C0Q000Q001k3U003U00C0TzVzw001k0zwDy000C07zVzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
;yes button consume screen
 if (ok:=FindText(1053-150000, 830-150000, 1053+150000, 830+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 1000
 }
}
}
send {esc}
;goto mainloop


;Maybe MainLoop: label here
;if raidcheck = 0
{
;Goto raidscripting
}
;Else if pvpcheck = 0
{
;Goto pvpscripting
}
;Else if 


raidscripting:
Text:="|<>0xFFFFFF@1.00$23.S3kaW8F94EWG8V4bVy9924GU" ; Raid Button

 if (ok:=FindText(756-150000, 791-150000, 756+150000, 791+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
Sleep 2000
Goto raid%raidtier%check
 }
 Else
 {
 raidcheck = 1
 settimer, raidcheckRESET, 300000
 Sleep 10
; goto mainloop
 }
 
 
raidcheckreset:
raidcheck = 0
return
;
;============Raid Functionality==================================
Raid1Check:
Text:="|<>0xD0565D@1.00$62.zUDwDy1y0zcCC00Q1UssC3XU070MCC3Uss01k63XUzyDw0Q1zszzzUz070TyDwks0Q1k73XX8C030Q1Ussu3U0k70MCC3Us0Q1k63XUsCDw0Q1UssC3Xz070MCC3U" ; Astaroth check

 if (ok:=FindText(964-150000, 801-150000, 964+150000, 801+150000, 0, 0, Text))
 {
	goto, raidsummon
 }
 else
 {
 goto, raidselector
 }
 






Raid2Check:
Text:="|<>0x32FF32@1.00$71.000000000000000000000000000000000000000000000000000000000001kQC1kDs1zkD3UsQ3UTk3zUS71ks73UsQ03UC3VkC61ks070Q73UQA3Vk0C0sC70sQ73U0Q1zw3z0zs7w0z3zs7w1zkDs1y7zk7s3zUTk3wC3U30600s070Q7060A01k0C0sC0A0M03U0Q1kQ0M0k07zks3Us0k1U03zVk71k1U3007z3U00000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(963-150000, 698-150000, 963+150000, 698+150000, 0, 0, Text))
 {
 goto raidsummon
 }
 Else
{
Goto raidselector
}
 
Raid3Check:
Text:="|<>0xF4C91E@1.00$63.00000000003XVUDs1z0zsQQA3z0Ds7zXXVUsC71ksCQQA61ksC70nXVUkC71ks6QQA61ksC70nXVUkC71ks6QQA61ksC70nXVUkC71ks6QQA61ksC70nXVUkC71ks6QQA61ksC70nzzUzy7zkzy7zk1z0Ds7z0zy0Ds1z0zsU" ; Woodbeard's Booty

 if (ok:=FindText(962-150000, 800-150000, 962+150000, 800+150000, 0, 0, Text))
 {
   Goto raidsummon
 }
else
{
Goto raidselector
}


Raid4Check:
Text:="|<>0x32FF32@1.00$71.0000000000000000000000000000000000k31kTUQQ01zU0K3Xzkss0Dz03g771Vlk0Q007MCC33XU0s00AkQQ67701k00NzszwCC03w00nzlzsQQ07s01a3XUkss0C003A771Vlk0Q006MCC33XU0s00AkQQ67701k00RUssAC3z0zk0/1lkMQ7y1zU0E0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(994-150000, 803-150000, 994+150000, 803+150000, 0, 0, Text))
 {
Goto raidsummon
 }
Else
{
Goto raidselector
}






Raid5Check:
Text:="|<>0x1AE0FF@1.00$71.000000000000000000000000000000000000000000000001U03y1zk61kDX007w3zkA3UT600sC71kM73UA01kQC1UkC70M03UsQ31UQC0k071ks630sQ1U0DzVzw3z0zX00Tz3zs3y1z600zy7zk7w3yA01kQC1U3U74M03UsQ3070C8k071ks60C0Q1zwC3Vzw0Q0s0zsQ73zU0s1k1zksC7z01k3U00000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1048-150000, 699-150000, 1048+150000, 699+150000, 0, 0, Text))
 {
   Goto raidsummon
 }
Else
{
Goto raidselector
}

Raid6check:
Text:="|<>0x2B4D93@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000007zk1z0s07006Dzk7y1k0C00RllkQ73U0Q01nXVUkC700s037731UQC01k06CC630sQ03U0AQQA7zks0700MssMDzVk0C00llkkTz3U0Q01XXVUkC700s037731UQC01k06CC630sQ03U0AQQA61kzy7zsSssMA3UTw3zkBlkkM70zs7z0M00000000000000000000000000000000000000000000001"

 if (ok:=FindText(966-150000, 697-150000, 966+150000, 697+150000, 0, 0, Text))
 {
  Goto raidsummon
 }
Else
{
Goto raidselector
}

Raid7check:
Text:="|<>0xC054FF@1.00$71.00000000000000000000000000000000000000000000000000000000000000000000001z0y0y3y0y0y1y7z7z7z7z7z00A6A6A6A6A600MAMAMAMAMA00kMsssskMkM3VUlz1zlUlUk331X633X1X1U2636A63636304A6A6A6A6A67sTwMATwTwMADUDUkMzUDUkM00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(969-150000, 699-150000, 969+150000, 699+150000, 0, 0, Text))
 {
   Goto raidsummon
 }
Else
{
Msgbox Raids > raid 7 support is not coded yet
}


;raidselector is if raidcheck doesnt match, to move one and recheck from current RaidTier variable!
RaidSelector:
Text:="|<>0xFBF8A8@0.93$71.000000000000000007s0000000000Dk0000000000TU00000000007s0000000000Dk0000000000TU0000000000zs0000000001zk0000000003zU0000000000z00000000001y00000000003w00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1362-150000, 830-150000, 1362+150000, 830+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 900
Goto raid%raidtier%check
 }




Raidsummon:
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000zsC3UTzU3zs1zkQ70zz0DzkDzUsC7zzVzzsQ01kQC773Vlks03UsQCC73XVk071ksQQC773zUC3VkssQCC1z0Q73VlksQQ3zUsC73XVkss031kQC773Vlk063UsQCC73XU0A71ksQQC773zsDzVkssQCC7z07w3VlksQQDy0Ds73XVkss000000000000000000000000000000000004"

 if (ok:=FindText(1248-150000, 808-150000, 1248+150000, 808+150000, 0, 0, Text)) ;check for summon button
{
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 1100
goto raidsummon1
}
else
{
goto teamclose
}
Raidsummon1:
Text:="|<>0xFBF8A8@0.92$71.000000000000000000000000000000TU0000000000z00000000001y00000000000TU0000000000z00000000001y00000000003zU0000000007z0000000000Dy00000000003w00000000007s0000000000Dk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1441-150000, 840-150000, 1441+150000, 840+150000, 0, 0, Text)) ;this if check is checking for a dialogue pop up after hitting the summon button
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 1200
   mousemove, 200, 200
   sleep 100
   goto raidsummon1
 }
Else
	{
Goto raiddifficulty%raiddifficulty%
	}
 



RaidDifficulty1: ;Normal button click

Text:="|<>0xFFFFFF@0.92$71.000000000000000000000000000000000000000000000000000000000000000000000000kM3s3y0kA1w1Uk7k7w3UM3s3lUksAC7XkQ87X1UkMADbUkEDy31UkMTz1UUTw631zkzy3z0lsA63y1kA7y1UkMA6A3UMC431UkMAM70kM8631UkMAC1UkEA63zUkMQ31UUMA1w1Uks63100000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(918-150000, 765-150000, 918+150000, 765+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 1000
Goto raidready
 }




RaidDifficulty2: ;Hard button click

Text:="|<>0xFFFFFF@0.92$71.00000000000000000000000000000000000000000000000031UTUTs7s000630z0zkDk000A633VkkQs000MA673VUlk000kMAC731Uk001zkTwDy31U003zUzsTs63000671VktkA6000A633VlUMA000MA673VUlk000kMAC731zU001UkMQC63w0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1123-150000, 767-150000, 1123+150000, 767+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 1000
Goto raidready
 }





RaidDifficulty3: ; Heroic button click

Text:="|<>0xFFFFFF@1.00$71.000000000000kM3y3y0TUTw1Uk7w7w0z0zs31Uk0AC730C0K31U0MAC60A0g6300kMQA0M1Tw7k1zksM0k2zsDU3y1kk1U5UkM06A3VU30/1Uk0AM73060K31U0MQC60A0g63zUkMTw7z1MA1z1UkDkDy0000000000000000000000004"

 if (ok:=FindText(1308-150000, 667-150000, 1308+150000, 667+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
    Sleep 1090
    goto, raidready
 }




RaidReady: ;team select screen
If (%AutoBestTeam% = true)
{
Text:="|<>0xFFFFFF@1.00$71.0000000000000000000000000000000000000000000000000000000000007w3UsTzUTk00Ts71kzz1zU01kQC3U7U71k030sQ70C0A3U061ksC0Q0M700C3VkQ0s0kC00Tz3Us1k1UQ00zy71k3U30s01kQC3U7061k030sQ70C0A3U061ksC0Q0M700A3VkQ0s0kC00M73zs1k1zw00kC1z03U0zU01UQ3y0301z0000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(968-150000, 898-150000, 968+150000, 898+150000, 0, 0, Text))

 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
    Sleep 1200
Goto raidstart
 }


}
Else
{
Goto raidstart
}

RaidStart: ;This part hits begin button

Text:="|<>0xFFFFFF@0.92$71.00000000000000000000000000000000000000000000000000000000000000000000000Dw0zU7w0zw3yTs1z0Ds1zs7zzwDzVzwDzkzz0sQ73UsQ01kS1ksC71ks03Uw3Vk0C01k071zz3U0Q03z0Dzzy700s07y0TzzwC01k0Dw0zz0sQ03U0Q01kC1ksC71ks03UQ3VkQC3Vk070s73zsTz3zwC1kC1z0Ds1zsQ3UQ3y0Tk3zks000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1231-150000, 995-150000, 1231+150000, 995+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 900
Goto checkshards
 }
Else 
{
Sleep 1000
Goto teamclose
}


Checkshards: ;After hitting begin, a shard check will be performed
sleep 200
Text:="|<>0xFFFFFF@0.92$71.7U7U0000zw0wD0D00001zs1sS0S00003zk3kw0w0000zzw7Vs1s0001zzsD3k3k0003k7kS7U7U0007UDUwD0D0000D0T1sT0y0000S0y3kzzw0000w1w7lzzs0001s3sDXzzk0003k7kT7zzU0007UDUyD0D0000D0T1sS0S0000S0y3kw0w0000w1w7Vs1s0001s3sD3k3k0003zzkS7U7U0007zzUwD0D00001zs1sS0S00003zk3k00000000000000000000000000000000000000000000001"

 if (ok:=FindText(1119-150000, 688-150000, 1119+150000, 688+150000, 0, 0, Text))
 {
Goto raidcancelled
 }
Else
{
Goto raidrunning
}


Raidcancelled: ;sets a var to not check raids for the time being
;declines shard purchase prompt
Raidcheck = 1

Text:="|<>0xFFFFFF@0.92$71.000000000000000000000000000000000000000000000000000C3UTs0000000Q70zk0000000yC7zs0000001wQC1k0000003zsQ3U0000007zks70000000DzVkC0000000QT3UQ0000000sy70s0000001kQC1k0000003UsQ3U00000071ks70000000C3VsS0000000Q70zk0000000sC1zU00000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1186-150000, 890-150000, 1186+150000, 890+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 800
Goto teamclose
 }


raidrunning:
;perform check to see if the player is not Autoing at raid start
Sleep 2300
Text:="|<>0xEB938F@1.00$71.00000000000000000000000000003z30000000007y6000000003w3w000000007s7s00000000D0Dk00000000S0TU00000003k00000000007U0000000000000000000000000000000000003k00000000007U00000003w0w000000007s1s00000000DkDk00000000TUTU00000000kzk000000001VzU0000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1507-150000, 832-150000, 1507+150000, 832+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   goto raidmainloop
 }
 else
 {
 goto raidmainloop
 }
 
raidmainloop: ;Raidmainloop still missing looped disconnect checks
 loop
{
 sleep 1500
	;Dialogue cancel script
	Text:="|<>0xFBF8A8@0.92$71.000000000000000000000000000000TU0000000000z00000000001y00000000000TU0000000000z00000000001y00000000003zU0000000007z0000000000Dy00000000003w00000000007s0000000000Dk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1441-150000, 840-150000, 1441+150000, 840+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   mousemove, 200, 200 ;need mousemove else the mouse will cause the dialogue arrow to not be the same image that was captured and compared before. Could add another if else statement but why bother with that when mouse can move?
   sleep 200
   goto raidmainloop
 }
Else
{
;Need to check for loss screen
Text:="|<>0xFFFFFF@1.00$71.000000000001zs01zz0Dzs1zzk03zy0Tzk3zzw0zzw7zzUzzzs1zzsDzz1zz3k3k00S003ky7w7U00w007Vw1sD001s00D3s3kT003s00S7k7Uzw07zU0zzUD1zs0Dz01zz0S3zk0Ty03zy0w7zU0zw07zw1sD001s00D3sTkS003k00S7kzUw007U00wDVs1s00D001sTzk3zzkS003zzzU3zzUw007zzs01zz1s001zzk03zy3k003s00000000000000000000000000000000000000000000001"

 if (ok:=FindText(1095-150000, 688-150000, 1095+150000, 688+150000, 0, 0, Text))
 {
   goto raiddefeat
 }
	Else
	{
 
;check for raid cleared screen and hits rerun into checkshards
Text:="|<>0xFFFFFF@1.00$71.00000000000000000000000000000000000000000000000000000000000Ts0zs7w3UM3wzk3zkDs70kDxzsTzVzwC1Uzz1ks03UsQ33US3Vk061ks670w73U0A3VkAC1sC7U0Q73UMQ3zkDs0zs70ks7zUTk1zkC1VkD70s03XUQ33USD1k0670s670w73U0A3VkAC1sC700M73UsQ3kQ3zkkC1z0s7Us7zVUQ3y1kA00000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1188-150000, 889-150000, 1188+150000, 889+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 5000
   goto checkshards
 }
	}
 
}
}
Raiddefeat:
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000Dz1k00Ts0zw0Ty3U00zk1zw0zw7003zU3zsDzsC00TzkTzkS00Q00w3Us00w00s01s71k01s01k03kC3U03k03U07UQ7zU7U0700D0s3z0D00C00S1k7y0S00Q00w3UDzUw00s01s700D1s01k03kC00S3k03U07UQ00w7zw7zwDzsDzs3zs3zs7z0Ty03zk7zk7y0zw07zUDzUDw1zs000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1113-150000, 891-150000, 1113+150000, 891+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 1900
   goto raidsummon
 }
return
;================PVP Functionality===============================
pvpscripting:
Text:="|<>0xFFFFFF@1.00$29.03nk007bU003w000000000000w8Hs14Ea828V8E4F2MUD24y0E4l00UC2010M41"
;hits PVP button from main
 if (ok:=FindText(757-150000, 571-150000, 757+150000, 571+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 1000
   goto pvpselector
 }
else
{
goto checklogin
}



pvpselector: ;One time check for missing team member on PVP team
if (%pvpteam% = 1)
{
goto pvpdifficultyselect
}
 else
{
goto pvpcheckteam
}

Pvpcheckteam: ;clicking the team button if found
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000DzUTw1z0DzU0Tz0zs3y0Tz00zy7zkzz3zzU070C01kC77300C0Q03UQCC600Q0s070sQQA00s1z0DzkssM01k3y0TzVlkk03U7w0zz3XVU070C01kC77300C0Q03UQCC600Q0s070sQQA00s1zwC1kssM01k0zsQ3Vlkk03U1zks73XVU000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
sleep 100
 if (ok:=FindText(957-150000, 815-150000, 957+150000, 815+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 700
   goto pvpsetteam
 }
else
{
msgbox cant find team button for PVP set team! going to Main label
;goto main
}

pvpsetteam: ;this checks for the ADD button on the team screen from PVP menu
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007w3zUTw00000Ds7z0zs00003zwDzVzw000070sQ73UM0000C1ksC70k0000Q3VkQC1U0000zz3UsQ300001zy71ks600003zwC3VkA000070sQ73UM0000C1ksC70k0000Q3VkQC1U0000s73zsTz00001kC7z0zs00003UQDy1zk00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
 if (ok:=FindText(1314-150000, 612-150000, 1314+150000, 612+150000, 0, 0, Text))
 {
   goto pvpautoteam	
 }
else
{
pvpteam = 1
Text:="|<>0xFFFFFF@1.00$71.0000000000000000000000000000000000000000000000000000000000007w0zU7w0Tw30Ts1z0Ds0zs63zwDzVzwDzkw70sQ73UMQ01kC1ksC70ks03UQ3Vk0C01k070zz3U0Q03z0D1zy700s07y0S3zwC01k0Ds0w70sQ03U0Q01kC1ksC70ks03UQ3VkQC1Vk070s73zsTz3zwC1kC1z0Ds0zsQ3UQ3y0Tk1zks00000000000000000000000000000000000000000000000000000000001"
;This is hitting Accept button as deemed by no 'add' button found for a missing party member, then sending you to pvpdifficultyselect to select ticket cost
 if (ok:=FindText(1226-150000, 996-150000, 1226+150000, 996+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 800
 goto pvpdifficultyselect
 }
 }
Msgbox this should not display
;if missing a team member pvp
pvpautoteam:
sleep 60
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000Ds71kzz0zU00zkC3Vzy3z003UsQ70D0C3U061ksC0Q0M700A3VkQ0s0kC00Q73Us1k1UQ00zy71k3U30s01zwC3U7061k03UsQ70C0A3U061ksC0Q0M700A3VkQ0s0kC00M73Us1k1UQ00kC7zk3U3zs01UQ3y0701z0030s7w0603y0000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(969-150000, 996-150000, 969+150000, 996+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 2300
}
   Text:="|<>0xFFFFFF@1.00$71.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007w0zU7w0Tw3wTs1z0Ds0zs7vzwDzVzwDzkzr0sQ73UMQ01kC1ksC70ks03UQ3Vk0C01k070zz3U0Q03z0Dxzy700s07y0TvzwC01k0Ds0zr0sQ03U0Q01kC1ksC70ks03UQ3VkQC1Vk070s73zsTz3zwC1kC1z0Ds0zsQ3UQ3y0Tk1zks000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
;clicks accept after hitting Auto
	if (ok:=FindText(1230-150000, 898-150000, 1230+150000, 898+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 1900
   pvpteam = 1
   goto pvpdifficultyselect
 }
 
else
{
goto teamclose
}


pvpdifficultyselect:
goto pvpdifficulty%pvpdifficulty%
;


pvpdifficulty5:
;check for a pre set ticket cost 5
Text:="|<>0xFFFFFF@0.36$44.k000000A0000000000000000000000000000000003zw00000zz00000Dzn00003zwk0000w0A0000D03s0003zky0000zwDU0003znz0000zwzk0000DDw000Dzks0003zwC0000zw3U000Dz00000000000000000000000000000000000008"

 if (ok:=FindText(1241-150000, 734-150000, 1241+150000, 734+150000, 0, 0, Text))
 {
   goto pvpplay
 }
else
{
;opening cost selector menu
Text:="|<>0xFFFFFF@1.00$20.000000000000000000000000000Tzw7zz1zzk3zU0zs0Dy00Q007001k00Q00000000000U"

	if (ok:=FindText(1314-150000, 731-150000, 1314+150000, 731+150000, 0, 0, Text))
	{
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 900
   Text:="|<>0xFFFFFF@1.00$41.000000000000000000000000000000TzU0000zz00001zy00003U000007000000C000000Tw00000Ds00000Ty000000Q000000s000001k0000TzU0000zs00001zk00000000000000000000000000000E"

		if (ok:=FindText(1106-150000, 927-150000, 1106+150000, 927+150000, 0, 0, Text))
		{
		CoordMode, Mouse
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		Click, %X%, %Y%
		sleep 1000
		goto pvpplay
		}
	}
}





pvpdifficulty4:
;check for a pre set ticket cost of 4
Text:="|<>0xFFFFFF@0.36$71.0s00000000001k0000000000Q00000000000s00000000001k0000000000Q00000D3k000s00000S7U001k00000wD00003U0001sS0000700003kw0000C00007Vs0003zU000Dzk0007z0000TzU000Dy0000Dz00003zU000Ty00007z00000w0000Dy00001s00003U00003k00007000007U0000C00000D000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1247-150000, 734-150000, 1247+150000, 734+150000, 0, 0, Text))
 {
goto pvpplay
 }
else
{
;opens cost selector menu
Text:="|<>0xFFFFFF@1.00$20.000000000000000000000000000Tzw7zz1zzk3zU0zs0Dy00Q007001k00Q00000000000U"

	if (ok:=FindText(1314-150000, 731-150000, 1314+150000, 731+150000, 0, 0, Text))
	{
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 900
   Text:="|<>0xFFFFFF@1.00$44.000000000000000000000000C1k00003UQ00000s700000C1k00003UQ00000s700000Dzk00000zw00000Dz0000001k000000Q00000070000001k000000Q00000070000000000000000000000000U"

		if (ok:=FindText(1111-150000, 867-150000, 1111+150000, 867+150000, 0, 0, Text))
		{
		CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 1000
   goto pvpplay
		}
	}
}
pvpdifficulty3:
;check for a pre set ticket cost of 3
Text:="|<>0xFFFFFF@0.85$71.000000000000000000000000000000000000000000000000000007z0000000000Dy00001k00000700003U00000C00007000000Q0001zk0000Ds0003zU0000Tk0007z00000zU0001zk0000700003zU0000C00007z00000Q00001k0003zs00003U0007z0000070000Dw000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1248-150000, 736-150000, 1248+150000, 736+150000, 0, 0, Text))
 {
   goto pvpplay
 }
else
{
;opens cost selector menu
Text:="|<>0xFFFFFF@0.85$32.000000000000000000000000000000000000001zzk00Tzw007zz000Dy0003zU000zs0001k0000Q0000700001k000000000000000000000000000000000000000000008"

 if (ok:=FindText(1314-150000, 734-150000, 1314+150000, 734+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 900
 }
	Text:="|<>0xFFFFFF@0.77$35.00000000000001zs0003zk0007zs00003k00007U0000D00007y0000Dw0000Ts00003k00007U0000D0001zy0003zk0007zU000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1107-150000, 810-150000, 1107+150000, 810+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 1000
   Goto PVPPLay
 }
}



pvpplay:
;Finding PLAY button for PVP menu
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000001zk600Ds70k03zUA00TkC1U07zkM03zsQ300C1Uk071ks600Q31U0C3VkA00s6300Q73UM01kQ600sC71k03zUA01zw3z007z0M03zs7w00C00k071k3U00Q01U0C3U7000s0300Q70C001k0600sC0Q003U07zVkQ0s007007z3Us1k0000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1272-150000, 804-150000, 1272+150000, 804+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 2900
   Goto TicketCheck
 }
 Else
 {
 msgbox Couldn't find PvpPlay button? Bot hangs at line 3289
 }
return



TicketCheck:
Text:="|<>0xFFFFFF@0.92$71.7U7U0000zw0wD0D00001zs1sS0S00003zk3kw0w0000zzw7Vs1s0001zzsD3k3k0003k7kS7U7U0007UDUwD0D0000D0T1sT0y0000S0y3kzzw0000w1w7lzzs0001s3sDXzzk0003k7kT7zzU0007UDUyD0D0000D0T1sS0S0000S0y3kw0w0000w1w7Vs1s0001s3sD3k3k0003zzkS7U7U0007zzUwD0D00001zs1sS0S00003zk3k00000000000000000000000000000000000000000000001"
;I think  this checks for the word purchase on screen
 if (ok:=FindText(1119-150000, 688-150000, 1119+150000, 688+150000, 0, 0, Text))
 {
Goto PVPCancelled
 }
Else
{
Goto PVPOpponentSelect
}

PVPCancelled:
;sets a var to not check PVP for the time being
;declines purchase prompt
PVPcheck = 1
Text:="|<>0xFFFFFF@0.92$71.000000000000000000000000000000000000000000000000000C3UTs0000000Q70zk0000000yC7zs0000001wQC1k0000003zsQ3U0000007zks70000000DzVkC0000000QT3UQ0000000sy70s0000001kQC1k0000003UsQ3U00000071ks70000000C3VsS0000000Q70zk0000000sC1zU00000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1186-150000, 890-150000, 1186+150000, 890+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
Sleep 800
Goto teamclose
 }

PVPOpponentSelect:
;Searching For FIGHT button and then referencing PVPOpponent variable as to which one to hit.
mousemove 200, 200
sleep 200
Text:="|<>0xFFFFFF@1.00$59.00000000000000000000000000000000000000000000000000zVUzVUkzs1z31z31XzkC06C0630M0M0AM0A60k0k0Mk0MA1U1y0lVkzs303w1X3Vzk607036331UA0A06A6630M0M0AMAA60k0k0MzsMA1U1U0kTUkM3000000000000000000000000000000000000000000000000008"

 if (ok:=FindText(1323-150000, 736-150000, 1323+150000, 736+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok[pvpopponent].x, Y:=ok[pvpopponent].y, Comment:=ok.1.id ;Variable specific PVP opponent selection. Big brain!
   Click, %X%, %Y%
   Sleep 1000
 }
;Clicking Accept Button to start Fight
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000000000000001z0Ds1z07z0y7y0Tk3y0Dy1wzz3zsTz3zwDtkC71ks6700Q3UQC3VkAC00s70sQ03U0Q01kDzks0700zk3yTzVk0C01zU7wzz3U0Q03y0DtkC700s0700Q3UQC3VkAC00s70sQ73UMQ01kC1kzy7zkzz3UQ3UTk3y0Dy70s70zU7w0TwC000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1229-150000, 995-150000, 1229+150000, 995+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 6000
   Goto PVPRunning
 }
Return

PVPRunning: ;PVPRunning Loop is missing Looped disconnect checks
;perform check to make sure AUTO is turned on
Text:="|<>0xFFFFFF@0.49$37.0000000000000000000000000000000000000000000007y00003z00007Vs0003kw0001sS0000wD0000TzU000Dzk0007Vs0003kw0001sS0000wD00000000000000000000000000000000000000000S7U000D3k0007Vs0003kw0001sS0000wD0000S7U000D3k0007zs0003zw0000Ts0000Dw00000000000000000000000000000000000000000TzU000Dzk0007zs0003zw00007U00003k00001s00000w00000S00000D000007U00003k00000000000000000000000000000000000000000TzU000Dzk0007zs0003zw0001sS0000wD0000S7U000D3k0007zs0003zw01"

 if (ok:=FindText(1506-150000, 773-150000, 1506+150000, 773+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
 }
Loop
{
	Sleep 900
		;Check for defeated screen
		Text:="|<>0xFFFFFF@1.00$73.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000zUs00Dw0Ty0TzkQ007y0DzUDzsC007z07zkDzw700DzsDzsTw03U07UQ700C001k03kC3U07000s01s71k03U00Q00w3Uzw1zU0C00S1k7y0zk0700D0s3z0Ts03U07UQ1zwDw01k03kC00S7000s01s700D3U00Q00w3U07VkDsDzsTzkTzkzzw1zw3zUDz07zy0zy0zk7zU1zz0Tz0Ts3zk0z00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"

 if (ok:=FindText(1122-150000, 890-150000, 1122+150000, 890+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 3000
   goto pvpplay
 }
	;Check for victory screen and hit close button
Text:="|<>0xFFFFFF@1.00$71.00000000000000000000000000000000000000000000000000000000000TwC00Ds1zk7zzsQ00Tk3zUDzzks03zsTz3zy01k071ks070403U0C3Vk0C080700Q73U0Q0E0C00sC7z0zkU0Q01kQ3y1zV00s03Us7z3z201k071k0670403U0C3U0AC080700Q700MQ0TwDzkzy7zkzzzs3zUTkDy0Dzzk7z0zUTw0Tw00000000000000000000000000000000000000000000000000000000001"
if (ok:=FindText(1001-150000, 988-150000, 1001+150000, 988+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 3000
   goto Pvpplay
 }
 }




;MENU CLOSING SCRIPT
Teamclose:
Loop,4
{
send {esc}
Sleep 1000
}
;Goto mainloop











;Fishing is sorta fucked and I can't find a good way to accomplish what I want with it.
End::
/*
Fishingstart:
 ; Clicks the fishing icon
Text:="|<>0xFFFFFF@1.00$48.D4D493kSk4E4948UU4E4948Uk4E4N48Uw4C7t48aU414948WU414948WU4S4948QU4S4948QU"

 if (ok:=FindText(1482-150000, 871-150000, 1482+150000, 871+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Sleep 800
 }
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000000000000000Tw3U07w1UQ00zs700Ds30s01zwC01zy61k030sQ03UQA3U061ks070sM700A3Vk0C1kkC00Tz3U0TzVzw00zs700zz0zU01zkC01zy1z00300Q03UQ0s00600s070s1k00A01k0C1k3U00M03zsQ3U7000k01zks70C001U03zVkC0Q0000000000000000000000000000000000000000000000000000000000001" 
; Clicks play
 if (ok:=FindText(1046-150000, 752-150000, 1046+150000, 752+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%	
sleep 200   
   goto fishstart
 }
fishstart:
Loop
	{
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000001zkzz0zU7w3zXzVzy1z0Ds7zTz3zwDzVzwDys00A0Q73UM0lk00M0sC70k1XU00k1kQC1U37z01U3zsTz063y0307zkzs0A7z060DzVzk0M060A0Q73XU0k0A0M0sC77k1U0M0k1kQC1U37zk1U3UsQ306Dy03071ks60ATw060C3VkA0M00000000000000000000000000000000000000000000000000000000000000000000001"
; Clicks start
 if (ok:=FindText(1118-150000, 906-150000, 1118+150000, 906+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
	goto, fishingcastepic
 }
Else
{
sleep 900
goto fishstart
}
	}
Fishingcastepic:
Loop
	{
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000Tw1z0Dy7zk00zs3y0TwDzU07zkTz3zsTz00C00kC7003U00Q01UQC007000s030sQ00C001k07zkzs0Q003U0DzUTk0s00700Tz0zs1k00C00kC01k3U00Q01UQ03U7000s030s070C001zw61kzy0Q000zsA3Vzk0s001zkM73zU1k0000000000000000000000000000000000000000000000000000000000000000000000001"
;Cast button detect
 if (ok:=FindText(1124-150000, 906-150000, 1124+150000, 906+150000, 0, 0, Text))

 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Sleep 640 ; Epic rod - Seems to consistently hit 48-52 most of the time as image detection is unreliable at higherFPS due to unity
    Click, %X%, %Y%
	goto, fishcatch
 } }

fishcatch: ; DOES NOT WORK PROPERLY YET, this is the check for 100% fishmeter to initiate Catch
Text:="|<>0x4EFF00@1.00$71.00000000000000000000000000000000000000000000000000000000000000k7s0z0000001UDk1y00000033zsDzU00000670kM7000000AC1UkC000000MQ31UQ000000ks630s000001VkA61k0000033UMA3U00000670kM7000000AC1UkC000000MQ31UQ000000kzy3zs000001UDk1z00000030TU3w000000000000000000000000000000000000000000000000000000000000001"
Loop
{
 if (ok:=FindText(2061-150000, 646-150000, 2061+150000, 646+150000, 0, 0, Text)) ;100% fishmeter check
{
Loop
{
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000007z0TkDzUTkC1jy0zUTz0zUQ3zwDzkzy7zks7U0Q3U70C1VkD00s70C0Q33US01kC0Q0s070w03zw0s1k0Dzs07zs1k3U0Tzk0Dzk3U700zzU0Q3U70C01kD00s70C0Q33US01kC0Q0s670zz3UQ0s1zwC1jy70s1k0zUQ3TwC1k3U1z0s600000000000000000000000000000000000000000000000000000000000000000000001"
if (ok:=FindText(1760-150000, 729-150000, 1760+150000, 729+150000, 0, 0, Text))
{
CoordMode, Mouse
X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
Click, %X%, %Y%
sleep 2200
Goto Fishresult
}
}
}
}
{
Text:="|<>0xFFFFFF@1.00$35.000000000000070Q000D0s000S1k000w3U001s70003zy0001zk0001zU0003z00007y0000Dw0000Ts0007zw000D0s000S1k000w3U001s70003UC02"

					 if (ok:=FindText(1950-150000, 689-150000, 1950+150000, 689+150000, 0, 0, Text))
					 {
					   CoordMode, Mouse
					   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
					   Click, %X%, %Y%
					   sleep 1000
					   goto fishstart
					 }
}
goto fishcatch
Fishresult:
Loop
{
Text:="|<>0xC5EF50@0.78$71.zzzzzzzzzzzzk07U1w0600y300201k0000s40000100000U800000000000E00000000000U00000000001000000000003000000000007s1k00000000Dk3U00000000TU7000000000z0C000000001y0Q000000003w0s000000007s1k00000000Dk3U00000000TU7000000000z0C000000001y0Q0000000M3w0s0008000s7w7sD1UsA03sDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

 if (ok:=FindText(1755-150000, 994-150000, 1755+150000, 994+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 750
		Text:="|<>0xFFFFFF@1.00$35.000000000000070Q000D0s000S1k000w3U001s70003zy0001zk0001zU0003z00007y0000Dw0000Ts0007zw000D0s000S1k000w3U001s70003UC02"

					 if (ok:=FindText(1950-150000, 689-150000, 1950+150000, 689+150000, 0, 0, Text))
					 {
					   CoordMode, Mouse
					   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
					   Click, %X%, %Y%
					   sleep 1000
					   goto fishstart
					 }
 }
Text:="|<>0xFFFFFF@1.00$71.000000000000000000000000000000000000000000000000zw7001zU3zk1zsC003z07zk3zkQ00Dy0DzUzzUs01zz1zz1s01k03kC3U03k03U07UQ7007U0700D0sC00D00C00S1kTy0S00Q00w3UDw0w00s01s70Ts1s01k03kC0zy3k03U07UQ00w7U0700D0s01sD00C00S1k03kTzkTzkzzUzzUDzUDzUTw1zs0Dz0Tz0Ts3zk0Ty0zy0zk7zU000000000000000000000000000000000001"
;clicks the X to close ???
 if (ok:=FindText(1754-150000, 899-150000, 1754+150000, 899+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   sleep 700
   Goto fishstart
 }
}
;====================================END====================================
*/
^i::exitapp