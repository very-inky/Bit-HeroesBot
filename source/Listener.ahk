;This will likely be the Init or start file for the bot.

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
  Gui, _MouseTip_: Show, NA x%x% y%y%
  Loop, 4
  {
    Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
    Sleep, 500
  }
  Gui, _MouseTip_: Destroy
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
run BHBot.exe
Loop
{
Text:="|<>0xFFFFFF@1.00$71.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003z0TkDUDk7s3zy0zUT0TUDk7y77031VVlkssMCA06331XVlUkQM0A06373X1zsz0M0A6C763z1y0k0MAQCA7C3U1U0kMsQMAA60301UlkskMCA06331XVlUkQQ0CC6773X1UsDs7k7sC7631kTkDUDkQCA000000000000000000000000000000000000000000000001"
;Reconnect button check
 if (ok:=FindText(1101-150000, 827-150000, 1101+150000, 827+150000, 0, 0, Text))
 {
   CoordMode, Mouse
   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
   Click, %X%, %Y%
   Process,close,BHBot.exe
   Send ^w
   sleep 200
   Run BHBot.exe
 }
Sleep 60000
 }
 