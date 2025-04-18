;===========================================
; Bit Heroes Bot – Multi-State Logic Skeleton
; (Works on 4k resolution, 150% zoom browser)
;===========================================
SetBatchLines, -1
#Include FindText.ahk
#Persistent
#SingleInstance Force

;------------- User Configurations -------------
actionConfig := {}  ; Associative array for action settings.
actionConfig["Quest"]   := True
actionConfig["PVP"]    := True
actionConfig["WorldBoss"] := True
actionConfig["Raid"]   := True
actionConfig["Trials"]  := True
actionConfig["Expedition"] := True
actionConfig["Gauntlet"] := True

; Define the rotation order of actions.
actionOrder := ["Quest", "PVP", "WorldBoss", "Raid", "Trials", "Expedition", "Gauntlet"]
currentActionIndex := 2

;------------- Questing Choice Configuration -------------
; Specify desired zone/dungeon pairs. These must be pairs!! 
desiredZones := ["Zone6"]
desiredDungeons := ["Dungeon2"]  ; Corresponding dungeon choices.
currentSelectionIndex := 1  ; Tracks configuration index.

;------------- PVP Configuration -------------
PvpTicketChoice := 1 ; How many tickets to use per fight (1-5) - User sets this
PvpOpponentChoice := 1 ; Which opponent row to fight (1-4, 1 being top/easiest) - User sets this

;------------- Dungeon Mapping Configuration -------------
; Each zone is mapped to an array of three dungeon OCR patterns.
dungeonMapping := {}
dungeonMapping["Zone1"] := ["|<>*104$85.00007k1zz0000000003s0zzU00000000Tw003k00000000Dy001s000000007z000w000000003zU00S000000001zk00D000000000w7zw7U00000000S3zy3k00000000D1zz1s000000007UzzUw000000003kTzkTw0000zzU07zzzkS3zz0Tzk03zzzsD1zzUDzs01zzzw7Uzzk7zw00zzzy3kTzs3zzw0Tzzz07zzzlzzy0DzzzU3zzzszzz07zzzk1zzzwTzzU3zzzs0zzzyDzzk1zzzw0Tzzz7zzs0zzzy0DzzzXzzw0Tzzz07zzzlzzy0DzzzU3zzzszzz07zzzk1zzzwTzzzzzzzzzzzzyDzzzzzzzzzzzzz7zzzzzzzzzzzzzXzzzzzzzzzzzzzlzzzzzzzzzzzzzszzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0zzzy00Tzzzzzw0Tzzz00Dzzzzzy0DzzzU07zzzzzz07zzzk03zzzzzzU3zzzs01zzzzzzk1zzzw00zzzzzzs0zzzy00Tzzzzzw0Tzzz00Dzzzzzy0DzzzU07zzzzzz07zzzzU3zzzzzzU3zzzzk1zzzzzzk1zzzzs0zzzzzzs0zzzzw0Tzzzzzw0Tzzzy0Dzzzzzy0Dzzzz00Ty0zzz07zzzzU0Dz0TzzU3zzzzk07zUDzzk1zzzzs03zk00zzzzzzzzzy0000Tzzzzzzzzz0000DzzzzzzzzzU0007zzzzzzzzzk0003zzzzzzzzzs00000D000007U0000007U00003k0000003k00001s0000001s00000w0000000w00000S0000Tw0S00000D0000Dy0D000007U0007z07U00003k0003zU3k00001s00007zzs00000zzz073zzw00000TzzU3Vzzy00000Dzzk1kzzz000007zzs0sTzzU00003zzw0Tzzzk00001zzzzlzzzs00000zzzzszzzw00000TzzzwTzzy00000DzzzyDzzzzzzzzzU0004", "|<>*133$75.kDU0Dz3zUw6061w01zsTw7Uk0kDU0Dz3zUw6061w01zsTw7Uk07zy0Dz3zUw000zzk1zsTw7U007zy0Dz3zUw000zzk1zsTw7U007zzzzzzzzw000zzzzzzzzzU007zzzzzzzzw000zzzzzzzzzU007zzzzzzzzw000zzzzzzzzzU077zzzzzzzzw00szzzzzzzzzU077zzzzzzzzw00szzzzzzzzzU07zzzzzzzzzw00zzzzzzzzzzU07zzzzzzzzzw00zzzzzzzzzzU07zzzzzz3zz000zzzzzzsTzs007zzzzzz3zz000zzzzzzsTzs007zzzzzz3zz000zzzzzzzzzsTy7zzzzzzzzz3zkzzzzzzzzzsTy7zzzzzzzzz3zkzy001zzUzzz1zzk00Dzw7zzsDzy001zzUzzz1zzk00Dzw7zzsDzy001zzUzzz1zzk1wDzzzUzzz7y0DVzzzw7zzszk1wDzzzUzzz7y0DVzzzw7zzss0TzzzzzUzzkz03zzzzzw7zy7s0TzzzzzUzzkz03zzzzzw7zy7s0TzzzzzUzzkzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzs1zzVzzzzzzzz0DzwDzzzzzzzs1zzVzzzzzzzz0DzwDzzzzzzzs1zzzzzzzzzzs0Dzzzzzzzzzz01zzzzzzzzzzs0Dzzzzzzzzzz01zzzzzzzzzzszzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzw0007zzzzzzzzU000zzzzzzzzw0007zzzzzzzzU07kzzzzzzzzw7zy7zzzzzzzzUzzkzzzzzzzzw7zy7zzzzzzzzU000zzzzzzzzw0007s0TzzzzzU00D703zzzzzw001ss0TzzzzzU00D703zzzzzw001s00Tzzzzzzzzzs03zzzzzzzzzz00Tzzzzzzzzzs03zzzzzzzzzz00Tzzzzzzzzzw", "|<>*120$87.zzzzzzzzzzw0T07zzzzzzzzzzU07kzzzzzzzzzzw00y7zzzzzzzzzzU07kzzzzzzzzzzw00y7zzzzzzzzzzU07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzw0Ty7zzzzzzzzzzU3zkzzzzzzzzzzw0Ty7zzzzzzzzzzU3zkzzzzzzzzzzw0Ty7zzzzzzzzzzUw7kzzzzzzzzzzw7Uy7zzzzzzzzzzUw7kzzzzzzzzzzw7Uy7zzzzzzzzzzUw7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzU3s0y7zzzzzzzzw0T07kzzzzzzzzzU3s0y7zzzzzzzzw0T07kzzzzzzzzzU3s0y7zzzzzzzy07U07kzzzzzzzzk0w00y7zzzzzzzy07U07kzzzzzzzzk0w00y7zzzzzzzy3s007kzzzzzzzzkT000y7zzzzzzzy3s007kzzzzzzzzkT000y7zzzzzzzy3s007kzzzzzzzwDU000y7zzzzzzzVw0007kzzzzzzzwDU000y7zzzzzzzVw0007kzzzzzzzwDU000y7zzzzzzzzw0007kzzzzzzzzzU000y7zzzzzzzzw0007kzzzzzzzzzU000y7zzzzzzk1w003zkzzzzzzy0DU00Ty7zzzzzzk1w003zkzzzzzzy0DU00Ty7zzzzzzk1w003zkzzzy0000DU3zUy7zzzk0001w0Tw7kzzzy0000DU3zUy7zzzk0001w0Tw7kzzzy0000DzzzUy7zzzk0001zzzw7kzzzy0000DzzzUy7zzzk0001zzzw7kzzzy0000DzzzUy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy4"]
dungeonMapping["Zone2"] := ["|<>*152$77.zzzzy7z3zzzzzzzzzwDy7zzzzzzzzzsTwDzzzzzzzzsD07UzzzzzzzzkS0D1zzzzzzzzUw0S3zzzzzzzz1s0w7zzzzzzzy3k1sDzzzzzzz3s00DVzzzzzzy7k00T3zzzzzzwDU00y7zzzzzzsT001wDzzzzzzky003sTzzzzzkS0000D1zzzzzUw0000S3zzzzz1s0000w7zzzzy3k0001sDzzzz3s00000DU3zzy7k00000T07zzwDU00000y0DzzsT000001w0Tzzky000003s0zzkS0DVzk00Dy7U0w0T3zU00Tw001s0y7z000zs003k1wDy001zk03sT3zzzzy3zy07ky7zzzzw7zw0DVwDzzzzsDzs0T3sTzzzzkTzk0y7kzzzzzUzzU03zzzzzzzzzk007zzzzzzzzzU00Dzzzzzzzzz000Tzzzzzzzzy000zzzzzzzzzw0000Dy7U07U000000TwD00D0000000zsS00S0000001zkw00w000001w01s01zk00003s03k03zU00007k07U07z00000DU0D00Dy00000T00S00Tw0000D0000003s0000S0000007k0000w000000DU0001s000000T000Tw00000001s00zs00000003k01zk00000007U03zU0000000D007z00000000S00k00007z0003s1U0000Dy0007k300000Tw000DU600000zs000T00000Dzzzzs01zU000Tzzzzk03z0000zzzzzU07y0001zzzzz00Dw0003zzzzy00Ts0Dzzzzzzzs03k0Tzzzzzzzk07U0zzzzzzzzU0D01zzzzzzzz00S03zzzzzzzy00zzzzzs1zzzzzzzzzzzk3zzzzzzzzzzzU7zzzzzzzzzzz0Dzzzzzzzzzk07z3sTzzVzzzU0Dy7kzzz3zzz00TwDVzzy7zzy00zsT3zzwDzzw01zky7zzs7zzs00000Dy00Dzzk00000Tw00TzzU00000zs00zzz000001zk007k00000007U00DU0000000D000T00000000S000y00000000w001w00000001s00zs00000000DU1zk00000000T03zU00000000y07z000000001w0Dy000000003s0S0000000007k0w000000000DU1s000000000T03k000000000y0E", "|<>*161$139.zzzzzzw7z1zzzzzUzzzzzzzzzzVzzy3zUzsDzsDVzzzzzzzzzkzzz1zkTw7zw7kzzzzzzzzzsTzzUzsDy3zy3sTzzzzzzzzwDzzkTw7z1zz1wDzzzzzzzU1sDzsDy00T3zUy7z1zkTzzk0w7zw7z00DVzkT3zUzsDzzs0S3zy3zU07kzsDVzkTw7zzw0D1zz1zk03sTw7kzsDy3zzy07UzzUzs01wDy3sTw7z1zzkzzk1wDzw7z1zk1zk1w0T3zsTzs0y7zy3zUzs0zs0y0DVzwDzw0T3zz1zkTw0Tw0T07kzy7zy0DVzzUzsDy0Dy0DU3sTk3zk1s0zzzy07Uzzz0001wDs1zs0w0Tzzz03kTzzU000y7w0zw0S0DzzzU1sDzzk000T3y0Ty0D07zzzk0w7zzs000DVz0Dz07U3zzzs0S3zzw0007kzy7zzw003zzw0007zzzkT3sTz3zzy001zzy0003zzzsDVwDzVzzz000zzz0001zzzw7ky7zkzzzU00TzzU000zzzy3sT3zsTzzk00Dzzk000Tzzz1wDVzzzzzzzzzzzzzzzzzzs0zzkyTzzzzzzzzzzzzzzzzw0TzsTDzzzzzzzzzzzzzzzzy0DzwDbzzzzzzzzzzzzzzzzz07zy7nzzzzzzzzzzzzzzzzzzzzzw7zzzzzzzzzzzzzzzzzzzzzy3zzzzzzzzzzzzzzzzzzzzzz1zzzzzzzzzzzzzzzzzzzzzzUzzzzzzzzzzzzzzzzzzzzzzkTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzDzzzzzzzzzzzzzzzzzzzzzzbzzzzzzzzzzzzzzzzzzzzzznzzzzzzzzzzzzzzzzzzzzzztzzzzzzzzzzzzzzzzzzzzzzwzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw", "|<>*106$127.0000zzU07zzzU0Dzw00000000Tzk03zzzk07zy00000000Dzs01zzzs03zz000000007zw00zzzw01zzU0000001zzzw0Tzzy0Dzzz0000000zzzy0Dzzz07zzzU000000Tzzz07zzzU3zzzk000000DzzzU3zzzk1zzzs0000007zzzk1zzzs0zzzw0000003zzzs0zzzw0Tzzy0000001zzzw0Tzzy0Dzzz0000000zzzy0Dzzz07zzzU000000Tzzz07zzzU3zzzk0007zwDzzzzzzzzzzzzzsTzs3zy7zzzzzzzzzzzzzwDzw1zz3zzzzzzzzzzzzzy7zy0zzVzzzzzzzzzzzzzz3zz0TzkzzzzzzzzzzzzzzVzzUz07zzzzzzzzzzzzzzzy0DTU3zzzzzzzzzzzzzzzz07jk1zzzzzzzzzzzzzzzzU3rs0zzzzzzzzzzzzzzzzk1vzkTzzzzzzzzzzzzzzzs0xzsDzzzzzzzzzzzzzzzw0Szw7zzzzzzzzzzzzzzzy0DTy3zzzzzzzzzzzzzzzz07jz1zzzzzzzzzzzzzzzzU3rzUzzzzs0zzzw01zzzzk1vzkTzzzw0Tzzy00zzzzs0xzsDzzzy0Dzzz00Tzzzw0Szw7zzzz07zzzU0Dzzzy0DTy3zzzzU3zzzk07zzzz07jz1zzzzk1zzzs03zzzzU3rzUzzzzs0zzzw01zzzzk1vzkTzzzw0Tzzy00zzzzs0xzsDzzzy0Dzzz00Tzzzw0Szzzzzzz07zzzy0Dzzz00DTzzzzzzU3zzzz07zzzU07jzzzzzzk1zzzzU3zzzk03o"]
dungeonMapping["Zone3"] := ["|<>*113$71.s0001zzy000000003zzw00000003zzw7U0000007zzsD0000000DzzkS0000000TzzUw0000000zzz1s0000001zkS3k0000003zUw7U0000007z1sD0000000Dy3kS0000007zw7Uw000000DzsD1s000000TzkS3k000000zzUw7U000001zz1sD0000003zy3kS0000007zw7Uw000000DzsD1s000000TzkS3k003y00zzUw7U007w01zz1sD000Ds03zy3kS000Tk07zw7Uw000zU0DzsD1s001zw0TzkS3k1zzzs0zzUw7U3zzzk1zz1sD07zzzU3zy3kS0Dzbz07zw7Uw7y3Dy0DzsD1sDw6Tw0TzkS3kTsAzs0zzUw7UzkNzk1zz1sD1zUnsS3zy3kS3z1bkw7zw7Uw7y3DVsDzsD1sDw6T3kTzkS3kTsAy7UzzUw7UzkNwD1zz1sD1zUnsS3zy3kS3z1bkw7zw7Uw7y3DVsDzsD1sDw6T3kTzkS3kTsAy7UzzUw7UzkNwD1zz1sD1zUnsS3zy3kS3z1bz3zzw7Uw7y3Dy7zzsD1sDw6TwDzzkS3kTsAzsTzzUw7UzkS3z1zz1sD1zUw7y3zy3kS3z1sDw7zw7Uw7y3kTsDzsD1sDw7UzkTzkS3kTsDy7zzzUw7UzkTwDzzz1sD1zUzsTzzy3kS3z1zkzzzw7Uw7y3zzsDzsD1sDzzzzkTzkS3kTzzzzUzzUw7Uzzzzz1zz1sD1zzzzy3zy3kS3zzzzzzzw7Uw7y3zzzzzsD1sDw7zzzzzkS3kTsDzzzzzUw7UzkNzzzzz1sDzzUnzzzzy3kTzz1bzzzzw7Uzzy3DzzzzsD1zzw6TzzzzkS3zzsA1zzzzUzzzzkM3zzzz1zzzzUk7zzzy3zzzz1UDzzzw7zzzy3000Dzzzzzz3y000Tzzzzzy7w000zzzzzzwDs001zzzzzzsTk003zzzzzzkzU007zzzUw0Tw000Dzzz1s0zs000Tzzy3k1zk000zzzw7U3zU001zz1zzzzUk003zy3zzzz1U007zw7zzzy3000DzsDzzzw6000TzkTzzzsA000zzUzzzzkQ", "|<>*95$103.0000000000000000w0000000000000000S0000000000000000D00000000000000007U000000003zzs0003k000000001zzw0001s000000000zzy000T0000000000Tzz000DU000000000DzzU007k000000003s00DU03s000000001w007k0Tw000000000y003s0Dy000000000T001w07z000000000DU001s3zU000000007k000w1zk000000003s000S3w0000000001w000D1y0000000000y0007Uz000000003zU0000DVU00000001zk00007k000000000zs00003s000000000Tw00001w0000Tzzzzzzzz0001s000DzzzzzzzzU000w0007zzzzzzzzk000S0003zzzzzzzzs000D0001zzzzzzzzw0007U00T00000007zzzzwDU0DU0000003zzzzy7k07k0000001zzzzz3s03s0000000zzzzzVw01zzzzk03zzzzzzz1s0zzzzs01zzzzzzzUw0Tzzzw00zzzzzzzkS0Dzzzy00TzzzzzzsD07zzzz00Dzzzzzzw7U3zU000zzzzzzzzy3k1zk000Tzzzzzzzz1s0zs000DzzzzzzzzUw0Tw0007zzzzzzzzkS3zU001zzzzzzzzzzz1zk000zzzzzzzzzzzUzs000TzzzzzzzzzzkTw000DzzzzzzzzzzsDy0007zzzzzzzzzzw7zw00zzzzzzzzzzzzzzy00Tzzzzzzzzzzzzzz00DzzzzzzzzzzzzzzU07zzzzzzzzzzzzVzk1zzzzzzzzzzzzzkzs0zzzzzzzzzzzzzsTw0TzzzzzzzzzzzzwDy0DzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUzzzzzzzzzzzzzzzzkTzzzzzzzzzzzzzzzsDzzzzzzzzzzzzzzzw7zzzzzzzzzzzzzzzy001zkTzzzzzzzzzzz000zsDzzzzzzzzzzzU00Tw7zzzzzzzzzzzk00Dy3zzzzzzzzzzzs000Dzzzzzzzzzzzzw0007zzzzzzzzzzzzy0003zzzzzzzzzzzzz0001zzzzzzzzzzzzzU000zzzzzzzzzzzzzk00003zzzzzzzzzzzs00001zzzzzzzzzzzw00000zzzzzzzzzzzy00000Tzzzzzzzzzzz000zzzzzzzzzzzzzzU00Tzzzzzzzzzzzzzk00Dzzzzzzzzzzzzzs007zzzzzzzzzzzzzw4", "|<>*131$99.0000001zz00000000000000Dzs000000007zy00y0Dw00zzU000zzk07k1zU07zw0007zy00y0Dw00zzU000zzk07k1zU07zw0007zy00y0Dw00zzU00D00D07k1zU3zzzs01s01s0y0Dw0Tzzz00D00D07k1zU3zzzs01s01s0y0Dw0Tzzz00D00D07k1zU3zzzs01s01s0y0Dw0Tzzz00D00D07k1zU3zzzs01s01s0y0Dw0Tzzz00D00D07k1zU3zzzs0Vs0zzzzzzzzzzzz3wD07zzzzzzzzzzzsTVs0zzzzzzzzzzzz3wD07zzzzzzzzzzzsTTzz00000Dzzzzzzw3zzs00001zzzzzzzUTzz00000Dzzzzzzw3zzs00001zzzzzzzUTzz00000Dzzzzzzw3k00Dzs0zzzzsTzzUS001zz07zzzz3zzw3k00Dzs0zzzzsTzzUS001zz07zzzz3zzw3k07k07zzzU07zzzUS00y00zzzw00zzzw3k07k07zzzU07zzzUS00y00zzzw00zzzw3kzzk07zzzU07zzzUS7zy00zzzw00zzzw3kzzk07zzzU07zzzUS7zy00zzzw00zzzw3kzzk07zzzU07zzzUzzzy00zzzw00zzz07zzzk07zzzU07zzs0zzzy00zzzw00zzz07zzzk07zzzU07zzs007z000zzzw003zU000zs007zzzU00Tw0007z000zzzw003zU000zs007zzzU00Tw0007z000zzzw003zU00000000Dzs00000000000001zz00000000000000Dzs00000000000001zz00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"]
dungeonMapping["Zone4"] := ["|<>*90$131.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zk00Dzw000000000000003zU00Tzs000000000000007z000zzk00000000000000Dy001zzU000001zk00000DU3zzw00zs00003zU00000T07zzs01zk00007z000000y0Dzzk03zU0000Dy000001w0TzzU07z00000Tw000003s0zzz00Dy0000T07U0001s0Tw000003zzs0y0D00003k0zs000007zzk1w0S00007U1zk00000DzzU3s0w0000D03zU00000Tzz00D07k00DU3s000000000000S0DU00T07k000000000000w0T000y0DU000000000001s0y001w0T0000000000003k1w003s0y000000000003s007k1s0y0000000000007k00DU3k1w000000000000DU00T07U3s000000000000T000y0D07k00000000007z00003kS0000000000000Dy00007Uw0000000000000Tw0000D1s0000000000000zs0000S3k0000000000001zk0000w7U00000000000000000007k0000001zzU00Ts000000DU0000003zz000zk000000T00000007zy001zU000000y0000000Dzw003zzs00000000000w001zzy0Dzk00000000001s003zzw0TzU00000000003k007zzs0zz000000000007U00Dzzk1zy00000000000D000TzzU3U3zz0000001zzVzzz000zz07zy0000003zz3zzy001zy0Dzw0000007zy7zzw003zw0Tzs000000DzwDzzs007zs000Dy0000Dzw7zw0007zzk000Tw0000TzsDzs000DzzU000zs0000zzkTzk000Tzz0001zk0001zzUzzU000zzy00000Tw00000zzzy00Tzzzzzzs0zs00001zzzw00zzzzzzzk1zk00003zzzs01zzzzzzzU3zU00007zzzk03zzzzzzz07z00000DzzzU07zzz0001zzU000000zzzy7zzzy0003zz0000001zzzwDzzzw0007zy0000003zzzsTzzzs000Dzw0000007zzzkzzzzk03zU000000000000Tzzzw007z0000000000000zzzzs00Dy0000000000001zzzzk00Tw0000000000003zzzzU00zs0000000000007zzzz00y000001w0000007zzzzy01w000003s000000Dzzzzw03s000007k000000Tzzzzs07k00000DU000000zzzzzk3k00003zzzs000003zzzzU7U00007zzzk000007zzzz0D00000DzzzU00000Dzzzy0S00000Tzzz000000Tzzzw0w00000zzzy000000zzzzs07z0001zzy3s000000Dzzk0Dy0003zzw7k000000TzzU0Tw0007zzsDU000000zzz00zs000DzzkT0000001zzy0S00000TzsT1s0000000TzUw00000zzky3k0000000zz1s00001zzVw7U0000001zy3k00003zz3sD00000003zw7U00007zy7kS00000007zw", "|<>*116$117.wDy000000000zs01w01zzzk000000000D00Dy00zzy0000000001s01zk07zzk000000000D00Dy00zzy0000000001s01zk07zzk000000000D00Dy00zzU0000000001zk03k07zw0000000000Dy00S00zzU0000000001zk03k07zw0000000000Dy00S00zzU00000000007k00DU7zw00000000000y001w0zzU00000000007k00DU7zw00000000000y001w0zzU00000000007k00DU7zw00000000000y0003kzzU00000000007k000S7zw00000000000y0003kzzU00000000007k000S7zw00000000000y00000zzU00000000007k00007zw00000000000y00000zzU00000000007k00007y000000000000y00000zk000000000007k00007y000000000000y00000zk000000000007k00007y000000000000y00000w0007U0001zzy0000007U000w0000Dzzk000000w0007U0001zzy0000007U000w0000Dzzk000000wDU07U000zzzzs000007Vw00w0007zzzz000000wDU07U000zzzzs00003w", "|<>*92$71.7zzzzw00zzy0Dzzzzs01zzw3zzzy0Dy0Dzzzzzzw0Tw0Tzzzzzzs0zs0zzzzzzzk1zk1zzzzzzzU3zU3zzyDzzz000y0TzwTzzy001w0zzszzzw003s1zzlzzzs007k3zzU0Tzzy3zy7zz00zzzw7zwDzy01zzzsDzsTzw03zzzkTzkzzz00Tzzzw0S3zy00zzzzs0w7zw01zzzzk1sDzs03zzzzU3kTzk07zzzz07UzwTw01zzU00zzszs03zz001zzlzk07zy003zzXzU0Dzw007zz0Tw00zs00DVy0zs01zk00T3w1zk03zU00y7s3zU07z001wDk7z00Dy003sTzzVw0Tzk1zzzzz3s0zzU3zzzzy7k1zz07zzzzwDU3zy0Dzzzw0T07zw0Tzzzs0y0Dzs0zzzzk1w0Tzk1zzzzU3s0zzU3zzzz07k1zz07zzzy00S3zy3z1sDw00w7zw7y3kTs01sDzsDw7Uzk03kTzkTsD1zU07Uzzzw01zz00D1zzzs03zy00S3zzzk07zw00w7zzzU0Dzs01sDzzz00Tzk1zzzzk000zzU3zzzzU001zz07zzzz0003zy0Dzzzy0007zzzzzzzw000Dzzzzzzzs000Tzzzzzzzk000zzzzzzzzU001zzzzzzzz0003zzzk1zzy0007zzzU3zzw000Dzzz07zzs000Tk"]
dungeonMapping["Zone5"] := ["|<>*121$71.zU0Dzzzzs001z00Tzzzzk003y00zzzzzU007w01zzzzz000Ds03zzzzy000MDw7zzs03zzzkTsDzzk07zzzUzkTzzU0Dzzz1zUzzz00TzztwDy7z1zz0003sTwDy3zy0007kzsTw7zw000DVzkzsDzs000T3zVzkTzk0031zUw0T0000Dy3z1s0y0000Tw7y3k1w0000zsDw7U3s0001z0Ts0zs0000zy0zk1zk0001zw1zU3zU0003zs3z07z00007zk7y0Dy0000Dzbzw7U0003zy0DzsD00007zw0TzkS0000Dzs0zzUw0000Tzk1zzy0007zy0Tnzzw000Dzw0zbzzs000Tzs1zDzzk000zzk3yTzzU001zzU7wzzU000zzUzztzz0001zz1zznzy0003zy3zzbzw0007zw7zzDzzz07zy0000Tzzy0Dzw0000zzzw0Tzs0001zzzs0zzk00007zw0TzzzzzzUDzs0zzzzzzz0Tzk1zzzzzzy0zzU3zzzzzzw1zz07zzzzzztzzy7zzs00003zzwDzzk00007zzsTzzU0000Dzzkzzz00000Tzzzzk00007wzzzzzU0000Dtzzzzz00000Tnzzzzy00000zbzzzzw00001zzzzzzzk1zzzzzzzzzzU3zzzzzzzzzz07zzzw", "|<>*184$139.01sDzzk1zU0000003k00Dzw00w7zzs0zk0000001s007zy00S3zzw0Ts0000000w003zz07kzzz07zw0000000Tw0Tzzw3sTzzU3zy0000000Dy0Dzzy1wDzzk1zz00000007z07zzz0y7zzs0zzU0000003zU3zzzbzzzz07zw00000001zz1zzznzzzzU3zy00000000zzUzzztzzzzk1zz00000000TzkTzzwzzzzs0zzU0000000DzsDzzyTzzzw0Tzk00000007zw7zzzzzzz07zzs00000003zzzzzzzzzzU3zzw00000001zzzzzzzzzzk1zzy00000000zzzzzzzzzzs0zzz00000000TzzzzzzzzzzzzzzU00S0000Dzzzzzzzzzzzzzzk00D00007zzzzzzzzzzzzzzs007U0003zzzzzzzzzzzzzzw003k0001zzzzzzzzzzzzzzy001s0000zzzzzzzzzzzzzzz00Tzzzw0TzzzzzzzzzzzzzzU0Dzzzy0Dzzzzzzzzzzzzzzk07zzzz07zzzzzzzzzzzzzzs03zzzzU3zzzzzzzzzzzzzzzzzzzzzzVzzzzzzzzzzzzzzzzzzzzzzkzzzzzzzzzzzzzzzzzzzzzzsTzzzzzzzzzzzzzzzzzzzzzwDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw", "|<>*161$91.VwDzzzzzzzsDzzkEy7zzzzzzzw7zzs8T3zzzzzzzy3zzw4DVzzzzzzzz1zzy1s000000007Uzzzww000000003kTzzyS000000001sDzzzD000000000w7zzzbU00000000S3zzznk0001w000D07zzxs0000y0007U3zzyw0000T0003k1zzzS0000DU001s0zzzky0007k000w00zzsT0003s000S00TzwDU001w000D00Dzy7k000y0007U07zz3s000T0003k03zz1zzzzzzzzzzzzzzUzzzzzzzzzzzzzzkTzzzzzzzzzzzzzsDzzzzzzzzzzzzzw001s000T0003sTy000w000DU001wDz000S0007k000y7zU00D0003s000T3zk007U001w000DVzs003k000y0007k1w001s000T0003s0y000w000DU001w0T000S0007k000y0DU00D0003s000T00E007U001w000DU08003k000y0007k04001s000T0003s02000w000DU001w01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw7k000y0007U000w3s000T0003k000S1w000DU001s000D0y0007k000w0007UT0003s000S0003kDU001w000D0001s7k000y0007U000w3s000T0003k000S1w000DU001s000D0y0007k000w0007UT0003s000S0003o"]
dungeonMapping["Zone6"] := ["|<>*104$105.zzzzzzzzUzzz3sTzzzzzzzzzzzsT3zzw7y3zzzzzzzzz3sTzzUzkTzzzzzzzzsT3zzw7y3zzzzzzzzz3sTzzUzkTzzzzzzzzsT3zzw7y3zzz1zkzs0w7UzzzzzzzzsDy7z07Uw7zzzzzzzz1zkzs0w7UzzzzzzzzsDy7z07Uw7zzzzzzzkzsDy7Uw7zzzzzzzzy7z1zkw7UzzzzzzzzzkzsDy7Uw7zzzzzzzzy7z1zkw7UzzzzzzzzzkzsDy7Uw7zzzzzzzzy00zs0zzzzzU00S3zzk07z07zzzzw003kTzy00zs0zzzzzU00S3zzk07z07zzzzw003kTzy00000zzzw000003zzk00007zzzU00000Tzy00000zzzw000003zzk00007zzzU00000Tzy00000zzzw000003zs000Dzzzw7Uw7UwDbz0001zzzzUw7Uw7Vwzs000Dzzzw7Uw7UwDbz0001zzzzUw7Uw7Vwy0007zzzz3sT3sT3kTk000zzzzsT3sT3sS3y0007zzzz3sT3sT3kTk000zzzzsT3sT3sS30001zzzzUw7Uw7UwDU000Dzzzw7Uw7Uw7Vw0001zzzzUw7Uw7UwDU000Dzzzw7Uw7Uw7Vw0001zzzzUw7Uw7UwDbk00Dzzz3sT3sT3sS3y001zzzsT3sT3sT3kTk00Dzzz3sT3sT3sS3y001zzzsT3sT3sT3kTzy00zzzzzUw7Uw7Vwzzk07zzzzw7Uw7UwDbzy00zzzzzUw7Uw7Vwzzk07zzzzw7Uw7UwDbzy00zzzzzUw7Uw7Vw1zk07zzzzzsT3sT3kMDy00zzzzzz3sT3sS31zk07zzzzzsT3sT3kMDy00zzzzzz3sT3sS3zzk07zzzzzzzw7UwDbzy00zzzzzzzzUw7Vwzzk07zzzzzzzw7UwDbzy00zzzzzzzzUw7Vwzzk07zzzzzzzw7UwDUDzs01zzzzzzzzzzzz1zz00DzzzzzzzzzzzsDzs01zzzzzzzzzzzz1zz00Dzzzzzzzzzzzzzzzz000zzzzzzzzzzzzzzs007zzzzzzzzzw", "|<>*152$37.0DzzkTU7zzsDk3zzw7s1zzy3zkzzz1zsTzzUzwDzzkTy7zzsDzzzzw7bzzzy3nzzzz1tzzzzUwzzzzkSTzzzsDzzzzw7zzzzy3zzzzz1zzzzzUzzzzzkTzzzzsDzzzzw7zzzzy3zzzzz1zzzzzUzzzzzkTzzzzsDkzzzw7sTzzy3wDzzz1y7zzzUz3zzzkTVzzzsDkzzzw7sTzzy3wDzzz1y7zzsTz3zzwDzVzzy7zkzzz3zsTzzVzwDzzkzy7zzsTz3zzwDzVzzy7zkzzz3zsTzzVzwDzzkzy7zzsTz3zzw0S1zzy0D0zzz07UTzzU3kDzzk1tzzzzz3zzzzzVzzzzzkzzzzzsTVzzzzzkzzzzzsTzzzzwDzzzzy7zzzzz3zzzzzVzzzzzkzzzzzsTzzzzzkTzzzzsDzzzzw7zzzzy3zzzzz1zzzzzUzzzzzkTzzzzsDzzzzw7zzzzy3zzzzz1zzzzzUzzzzzkTzzzzzkzzzzzsTzzzzwDzzzzy7zzzzz3zzzzzVzzzzzkzzzzzsTzzzzwDzzzz1zzzzzUzzzzzkTzzzzsDzzzzw7zzzw", "|<>*90$61.007UzzzzzzU03kTzzzzzk01sDzzzzzs0T07zzzzzw0DU3zzzzzy07k1zzzzzz03s0zzzzzzU1w0TzzzzzkD00Dzzzzzs7U07zzzzzw3k03zzzzzy1s01zzzzzz0w0TzzzzzzUS0DzzzzzzkD07zzzzzzs7U3zzzzzzw3k1zzzzzzy1s0zzzzzzz0w0TzzzzzzUS0DzzzzzzkD07zzzzzzs7U3zzzzzzw3k1zzzzzzy1s0zzzzzzz0w0TzzzzzzUS0DzzzzzzkD07zzzzzzs7U3zzzzzzw3k1zzzzzzy1s0zzzzzzz0zs0zzzzzzUTw0TzzzzzkDy0Dzzzzzs7z07zzzzzw3kS3zzzzzy1sD1zzzzzz0w7UzzzzzzUS3kTzzzzzkD1sDzzzzzs7Uw0Tzzzzw3kS0Dzzzzy1sD07zzzzz0w7U3zzzzzUS0DU3zzzzkD07k1zzzzs7U3s0zzzzw3k1w0Tzzzy1s0y0Dzzzz0w00w0TzzzUS00S0DzzzkD00D07zzzs7U07U3zzzw3k00DVzzzy1s007kzzzz0w003sTzzzUS001wDzzzkD000y7zzzs7U000zzzzw3k000Tzzzy1s000Dzzzz0w0007zzzzUS0003zzzzkD0001zzzzs7U000zzzzw3k000Tzzzy1s000Dzzzz0zs007U3zzUTw003k1zzkDy001s0zzs7z000w0Tzw3kTw0S0001"]
dungeonMapping["Zone7"] := ["|<>*146$71.000TzzU000000001zzzzzzzw0003zzzzzzzs0007zzzzzzzk000DzzzzzzzU000Tzzzzzzz000007zw0Tzy00000Dzs0zzw00000Tzk1zzs00000zzU3zzk0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zs0000000003zk0000000007zU000000000Dz0000000000Ty0000000000Dzzz00000000Tzzy00000000zzzw00000001zzzs000000000zzzy00000001zzzw00000003zzzs00000007zzzk0000000Dzw0Tzzzzks0Tzs0zzzzzVk0zzk1zzzzz3U1zzU3zzzzy703zz07zzzzwC1zz1zzzzzzzw3zy3zzzzzzzs7zw7zzzzzzzkDzsDzzzzzzzUTzzzzzzzzzz0zzzzzzzzzzy1zzzzzzzzzzw3zzzzzzzzzzs7zzzzzzzzzzzzzs0zzzzzzzzzzk1zzzzzzzzzzU3zzzzzzzzzz07zzzzzzz0Dzw01zzzzz60Tzs03zzzzyA0zzk07zzzzwM1zzU0Dzzzzsk3zz00TzzzzkTzkzzz000000zzVzzy000001zz3zzw000003zy7zzs0000000001w00000700003s00000C00007k00000Q0000DU00000s0000T000001k01s00000003U03k00000007007U0000000C00D00000000T00000000000600000000000A00000000000E", "|<>*89$71.U000001s000D0000003k000S0000007U000w000000D0001s000000S0003k00007k00007U0000DU0000D00000T00000S00000y00000zk000S00000zzU000w00001zz0001s00003zy0003k00007zw0007U0000Dw0007zzs0zs00000Dzzk1zk00000TzzU3zU00000zzz07z0000Dzzzy7k00000TzzzwDU00000zzzzsT000001zzzzky000003zzzzzw0Tw007zzzzzs0zs00Dzzzzzk1zk00TzzzzzU3zU00zzzzzz07z0Dzzzzzzzzk00TzzzzzzzzU00zzzzzzzzz001zzzzzzzzy00000zzzzzy000001zzzzzw000003zzzzzs000007zzzzzk00000DzzzzzU00U001zzzzzy010003zzzzzw020007zzzzzs04000Dzzzzzk08007zzzU3zVzk00Dzzz07z3zU00Tzzy0Dy7z000zzzw0TwDy001zzzs0zsTw01wDzzk07zzs03sTzzU0Dzzk07kzzz00TzzU0DVzzy00zzzw0Tzzzzk1zzzs0zzzzzU3zzzk1zzzzz07zzzU3zzzzy0Dzzz07zzzzw0TzzzzzzzzzzkzzzzzzzzzzzVzzzzzzzzzzz3zzzzzzzzzzy7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0Tzzzzzzzzy00zzzzzzzzzw01zzzzzzzzzs03zzzzzzzzzk07zzzzzzzzzU0Dzzzzzzzzz00Tzzzzzzzzy00zzzzzzzzzwD1zzzzzzs03zS3zzzzzzk07yw7zzzzzzU0DxsDzzzzzz00TvkTzzzzzy00zzzzzzzzzw01zzzzzzzzzs03zzzzzzzzzk07zzzzzzzzzU0Dzzzzzzzzz3s07zzzzzzzy7k0DzzzzzzzwDU0TzzzzzzzsT00zzzzzzzzky01zzzzzzzzU00Tzzzzzzzz000zzzzzzzzy001zzzzzzzzw003U07zzzzzzzzz00Dzzzzzzzzz"]
dungeonMapping["Zone8"] := ["|<>*91$71.0T000007zw7y0kTzk03kzzkzzUzzUw7VzzVzz1zz1sD3zz3zy3zy3kS7zy7zw7zw7UwDzwD07kzzz1sTzs00DVzzy3kzzk00T3zzw7VzzU00y7zzsD3zz001wDzw0S7zy003sTzs0wDzw007kzzk1sTzs00DVzzU3kzzk00T3zz07VzzU7ky7zzzzzzzzzVwDzzzzzzzzz3sTzzzzzzzzy7kzzzzzzzzy3zzzzzzzzzzw7zzzzzzzzzzsDzzzzzzzzzzkTzzzzzzzzzzUzzzzzzzzzzz1s0zzzzzzzzy3k1zzzzzzzzw7U3zzzzzzzzsD07zzzzzzzzkS3zy00TzzzzUw7zw00zzzzz1sDzs01zzzzy3kTzk03zzzzw7UzzU07zzzzsD1zz00DzzzzkS3zy00TzzzzUw7zw00zzzzz1sDzs01zzzzzzzzzk03zzzzzzzzzU07zzzzzzzzz00Dzzzzzzzzy00TzzzzU07zw00zzzzz00Dzs01zzzzy00Tzk03zzzzw00zzU07zzzzs01zz00Dzzzzk000TzzzzzzzU000zzzzzzzz0001zzzzzzzy0003zzzzzzzzs0000w003zzzk0001s007zzzU0003k00Dzzz00007U00Tzzy0000D000zzzzzU00S001zzzzz000w003zzzzy001s007zzzzw003k00Dzzzw00000001zzzs00000003zzzk00000007zzzU0000000Dzzz00000000Tzzzzzzzk0001zzzzzzzU0003zzzzzzz00007zzzzzzy0000Dzzzzzzzzzzzzw", "|<>*143$81.zzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zzzzzzzzzzk00Dzzzzzzzzzy001zw"]
dungeonMapping["Zone9"] := ["|<>*38$71.00000000Tzk000zzz0003zU001zzy0007z0003zzw000Dy0007zzs000Tw01zzzzzy00zs03zzzzzw01zk07zzzzzs03zU0Dzzzzzk07z00TzzzzzU0Dy00zzzy7z00Tzs1zzzwDy00zzk3zzzsTw01zzU7zzzkzs03zz0Dy00Tzk00Dy0Tw00zzU00Tw0zs01zz000zs1zk03zy001zk3zU07zw003zU7z07ky003zz0Dy0DVw007zy0Tw0T3s00Dzw0zs0y7k00Tzs1zk00000Dzs03zU00000Tzk1", "|<>*36$55.00000001zU0000000zk000000Dzs0000007zw0000003zy0000001zz0000000zzUDzzk000zk7zzs000Ts3zzw000Dw1zzy0007yTzsTzk03zDzwDzs01zbzy7zw00znzz3zy00TtzzVzz00Dzy001zU07zz000zk03zzU00Ts01zzk00Dw00zzs03zy001zw01zz000zy00zzU00Tz00Tzk00DzU0Dzs007zk000000zzs000000Tzw000000Dzy0000007zz0000000DzU0000007zk0000003zs0000001zw0000000zy0000007zz0000003zzU000001zzk000000zzzU00000Tzzk00000Dzzs000007zzw000003zzy000001zbz00000Tw3zU0000Dy1zk00007z0zs00003zU0zs0001zk0Tw0000zsE"]
dungeonMapping["Zone10"] := ["|<>*47$79.zy7ky00y00zzUTz3sT00T00Tzk00Tzzy0DU7zzzk0Dzzz07k3zzzs07zzzU3s1zzzw03zzzk1w0zzzy01s0y7zy0Tzzz00w0T3zz0DzzzU0S0DVzzU7zzzk0D07kzzk3zzzs3zz00Tzzzzzzw1zzU0Dzzzzzzy0zzk07zzzzzzz0Tzs03zzzzzzzUDzw01zzzzzzzrs0zs01zzzzzzzw0Tw00zzzzzzzy0Dy00Tzzzzzzz07z00DzzzzzzU0zzz07zzzVzkE0TzzU3zzzkzs80Dzzk1zzzsTw407zzs0zzzwDy203zzw0Tzzy7z10y00zzzy00zzU0T00Tzzz00Tzk0DU0DzzzU0Dzs07k07zzzk07zw3zs03zzzs03zzzzw01zzzw01zzzzy00zzzy00zzzzz00Tzzz00TzzzzU0DzzzU0Dzzzzk07zzzk07zzzzs03zzzs03zzzzw01zzzw01zzzzy00zzzy00zzzzU00Tzzz001zkDk00DzzzU00zs7s007zzzk00Tw3w003zzzs00Dy1y001zzzw007z000001zz00000000000zzU0000000000Tzk0000000000Dzs00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000E000000000000800000000000040000000000003", "|<>*85$71.1w003zVzz1zy3s03zzzzy3zw7k07zzzzw7zsDU0DzzzzsDzkT00TzzzzkTzUy00zzzzzUzz1w0S0000D1zy3s0w0000S3zw7k1s0000w7zsDU3k0001sDzk0zs0zzzwDzzU1zk1zzzsTzz03zU3zzzkzzy07z07zzzVzzw0D07zzzzw7zs0S0DzzzzsDzk0w0TzzzzkTzU1s0zzzzzUzz03k1zzzzz1zyzzUw0007y3zxzz1s000Dw7zvzy3k000TsDzrzw7U000zkTzU1zk00007Uzz03zU0000D1zy07z00000S3zw0Dy00000w7zs0Tw00001sDzk0zs00003kTzU1zk00007Uzz03zU0000D1zy07z00000S3zw0Dy00000w7zs0Tw00001sDzk0zs00003kTzU1zk00007Uzz03zU0000D1zy07zzs000S3zw0Dzzk000w7zs0TzzU001sDzk0zzz0003kTzU1zzzzz07Uzz03zzzzy0D1zy07zzzzw0S3zw0Dzzzzs0w7zs0Tzzzzk1sDzk0zzzzzzzzzzU1zzzzzzzzzz03zzzzzzzzzy07zzzzzzzzzw7zzs000DzzzsDzzk000TzzzkTzzU000zzzzUzzz0001zzzz1zzy0003zzzzw7z00007zzzzsDy0000DzzzzkTw0000TzzzzUzs0000zzzzU07z000000zz00Dy000001zy00Tw000003zw00zs000007zs000000000Dzk000000000TzU000000000zz0000000001zy0000000003zw7k00D000zzzsDU00S001zzzkT000w003zzzUy001s007zzzVzk03k000zzz3zU07U001zzy7z00D0003zzwDy00S0007zzsTw00w000DzzUy001s000Tzs1w003k000zzk3s007U001zzU7k00D0003zz0DU00Tw007zy0T000zs00DzwE", "|<>*123$109.7Uzs1zzzzzzzzy001zXkTw0zzzzzzzzz000zlzzy0TzzUzzU3kS2000zzz0DzzkTzk1sD1w00TzzU7zzsDzs0w7Uy00Dzzk3zzw7zw0S3kT007zzs1zzy3zy0D1sDU0Tzzw0zzzzzzzzUw4DyDzzy0TzzzzzzzkS27z7zzz0DzzzzzzzsD13zXzzzU7zzzzzzzw7UVzlzy7k3sTzzzzzVzkE00zz3s1wDzzzzzkzsD00TzVw0y7zzzzzsTw7U0Dzky0T3zzzzzwDy3k07zsT0DVzzzzzy7z1s03U3zU7z00D0003zz3zzk1zk3zU07U001zzVzzs0zs1zk03k000zzkzzw0Tw0zs01s000TzsTzlzzy0Tzzzzzz3zzwDVszzz0DzzzzzzVzzy7kwTzzU7zzzzzzkzzz3sSDzzk3zzzzzzsTzzVwD7zzs1zzzzzzwDzzky7UDzzzzzzzzzy00w7zw07zzzzzzzzzz00S3zy03zzzzzzzzzzU0D1zz01zzzzzzzzzzk07UzzUDy00zzzzzzzzy3zzzz7z00Tzzzzzzzz1zzzzXzU0DzzzzzzzzUzzzzlzk07zzzzzzzzkTzzzszs03zzzzzzzzsDzzzzzzzzzzzzzzzzw003zzzzzzzzzzzzzzy001zzzzzzzzzzzzzzz000zzzzzzzzzzzzzzzU00TzlzkzzzzzzzzzwDU3zy0zsTzzzzzzzzy7k1zz0TwDzzzzzzzzz3s0zzUDy7zzzzzzzzzVw0Tzk7z3zzzzzzzzzk1zk003zVzzzzzzzzzs0zs001zkzzzzzzzzzw0Tw000zsTzzzzzzzzy0Dy000TwDzzzzzzzzz07z001zzsDzzzzzzzzVwDVzzzzw7zzzzzzzzky7kzzzzy3zzzzzzzzsT3sTzzzz1zzzzzzzzwDVwDzzzzUzzzzzzzzzzz1zk3zzkTzzzzzzzzzzUzs1zzsDzzzzzzzzzzkTw0zzw7zzzzzzzzzzsDy0Tzy3zzzzzzzzzzw7z0Dzzy0Tzzzzs000Tzzzzzzz0Dzzzzw000DzzzzzzzU7zzzzy0007zzzzzzzk3zzzzz0003zzzzzzzsS3zzzkT0007z00TzzwD1zzzsDU003zU0Dzzy7Uzzzw7k001zk07zzz3kTzzy3s000zs03zzzVsDzzz1w000Tw01zzzzw7zzzU0000Dzw0zzzzy3zzzk00007zy0Tzzzz1zzzs00003zz0DzzzzUzzzw00001zzU7zzzzzVzzzzzy00zs03zzzzzkzzzzzz00Tw01"] 
;------------- Global Variables -------------
global previousState := ""
actionCooldown := 1200000 ; 20mins in MS
lastActionTime := {}       ; Tracks last execution time per action.
for index, act in actionOrder {
lastActionTime[act] := 0
}

;------------- Bot State Management -------------
; Global states:
; "NotLoggedIn"      - Waiting for quest icon.
; "HandlingPopups"   - Clearing pop-ups.
; "NormalOperation"  - Ready to start a new action.
; "ActionRunning"    - An action has been initiated and is in progress.
; "Paused"           - Bot is paused.
; "disconnected"     - Bot detected disconnect, should initiate recovery.
gameState := "NotLoggedIn"
DebugLog("Script started. Initial gameState = NotLoggedIn.")

; Main loop timer
SetTimer, BotMain, 1000
Return

;===========================================
; BotMain – Global State Machine
;===========================================
BotMain:
{
    global gameState, currentActionIndex, actionOrder, actionConfig, lastActionTime, actionCooldown, currentAction, currentSelectionIndex, desiredZones, PvpTicketChoice, PvpOpponentChoice ; Added PVP configs

    if (gameState = "Paused")
        Return

    ; --- NotLoggedIn State ---
    if (gameState = "NotLoggedIn") {
        DebugLog("NotLoggedIn: Checking for quest icon as the main screen anchor")
        if (IsMainScreenAnchorDetected()) {
            DebugLog("Quest icon detected. Transitioning to NormalOperation.")
            gameState := "NormalOperation"
        } else {
            DebugLog("Quest icon not detected. Attempting reconnect / pop-up handling.")
            AttemptReconnect() ; Try clicking reconnect if visible
            Sleep, 500
            gameState := "HandlingPopups" ; Proceed to popup handling anyway
        }
        Return
    }

    ; --- HandlingPopups State ---
    if (gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: Clearing pop-ups...")
        popupAttempts := 0
        while (!IsMainScreenAnchorDetected() and popupAttempts < 10) { ; Added attempt limit
            if (gameState = "Paused") {
                while (gameState = "Paused")
                    Sleep, 500
            }
            Send, {Esc}
            Sleep, 1000
            popupAttempts++
            DebugLog("HandlingPopups: Sent {Esc}, attempt #" . popupAttempts)
            if (IsDisconnected()) { ; Check disconnect during popup clearing
                 AttemptReconnect()
                 Sleep, 3000
            }
        }
        if (IsMainScreenAnchorDetected()){
             DebugLog("HandlingPopups: Quest icon detected. Transitioning to NormalOperation.")
             gameState := "NormalOperation"
        } else {
             DebugLog("HandlingPopups: Failed to clear popups/find anchor after " . popupAttempts . " attempts. Resetting to NotLoggedIn.")
             gameState := "NotLoggedIn" ; Reset if stuck
        }
        Return
    }

    ; --- NormalOperation State ---
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex]
        DebugLog("NormalOperation: Checking action: " . currentAction)
        now := A_TickCount

        if (!actionConfig[currentAction]) {
            DebugLog("NormalOperation: " . currentAction . " is disabled in config, skipping.")
            currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
            Return
        }

        if ((now - lastActionTime[currentAction]) >= actionCooldown) {
            DebugLog("NormalOperation: Cooldown ready for " . currentAction . ". Attempting action.")
            result := ""
            Switch currentAction {
                Case "Quest": result := ActionQuest()
                Case "PVP": result := ActionPVP()
                Case "WorldBoss": result := ActionWorldBoss()
                Case "Raid": result := ActionRaid()
                Case "Trials": result := ActionTrials()
                Case "Expedition": result := ActionExpedition()
                Case "Gauntlet": result := ActionGauntlet()
                Default:
                     DebugLog("NormalOperation: Unknown action '" . currentAction . "' in Switch. Skipping.")
                     result := "error_unknown_action" ; Assign a specific error status
            }

            ; --- Handle result from the action function ---
            if (result = "started") {
                DebugLog("NormalOperation->ActionRunning: " . currentAction . " initiated.")
                gameState := "ActionRunning"
            } else if (result = "outofresource") {
                DebugLog("NormalOperation: " . currentAction . " returned 'outofresource'. Starting cooldown & advancing.")
                lastActionTime[currentAction] := now
                currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
                Loop, 2 
                { Send, {Esc} 
                Sleep 500 
                } ; Attempt to clear UI
            } else if (result = "disconnected") {
                DebugLog("NormalOperation: " . currentAction . " reported disconnect. Resetting state.")
                gameState := "NotLoggedIn"
                AttemptReconnect()
            } else if (result = "player_dead") { ; Handle if Action returns this directly
                 DebugLog("NormalOperation: " . currentAction . " reported player_dead. Resetting state.")
                 gameState := "NotLoggedIn"
                 ; Assuming Esc/Town was handled by Action function or Monitor
            } else if (result = "retry") {
                DebugLog("NormalOperation: " . currentAction . " returned 'retry'. Will reattempt on next cycle.")
                ; No state change, no index change
            }
            ; --- Modified 'else' block for Success/Other Results ---
            else { ; Handles "success" or any other return value (like "error_unknown_action")
                ; *** Check specifically for PVP success to enable looping ***
                if (currentAction = "PVP" and result = "success") {
                    ; *** PVP Success: Loop immediately ***
                    DebugLog("NormalOperation: PVP completed successfully. Attempting next match (no cooldown/advance).")
                    ; ** IMPORTANT: DO NOT change lastActionTime or currentActionIndex **
                    ; By doing nothing here, BotMain will loop and check PVP again on the next tick.
                }
                else {
                    ; *** Default Success/Other/Error Handling: Start cooldown & advance ***
                    DebugLog("NormalOperation: " . currentAction . " finished ('" . result . "'). Starting cooldown & advancing.")
                    lastActionTime[currentAction] := now ; Start cooldown
                    currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1 ; Advance index
                }
            }
        } else {
            ; Cooldown is active
            timeRemaining := Ceil((actionCooldown - (now - lastActionTime[currentAction])) / 1000)
            DebugLog("NormalOperation: " . currentAction . " skipped - cooldown active (" . timeRemaining . "s left). Advancing action index.")
            currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
        }
        Return
    }

    ; --- ActionRunning State ---
    if (gameState = "ActionRunning") {
        monitorResult := ""
        DebugLog("BotMain: Monitoring current action: " . currentAction)

        ; --- Call the appropriate monitor function ---
        if (currentAction = "Quest") {
            monitorResult := MonitorQuestProgress()
        }
        ; --- Add other actions needing monitoring here ---
        else if (currentAction = "PVP") {
            monitorResult := MonitorPVPProgress()
        }
        ; --- Fallback for actions not needing monitoring or not implemented ---
        else {
             DebugLog("BotMain: No specific monitor needed/implemented for: " . currentAction . ". Returning to NormalOperation.")
             gameState := "NormalOperation"
             Return
        }

        DebugLog("BotMain (" . currentAction . "): Monitor function returned: [" . monitorResult . "]")

    if (monitorResult = "pvp_completed_continue") {
        DebugLog("BotMain: PVP match done; looping again without cooldown/advance")
        gameState := "NormalOperation"
        return
    }
    else if (monitorResult = "outofresource") {
        DebugLog("BotMain: PVP out of tickets; starting cooldown & advance")
        lastActionTime["PVP"] := A_TickCount
        currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
        gameState := "NormalOperation"
        return
    }
        ; --- Check the result FROM the monitor function ---
        DebugLog("BotMain (" . currentAction . "): Checking monitorResult...")
        if (monitorResult = "start_next_config") {
            ; --- Logic to start next quest config ---
            actionResult := ""
            Switch currentAction {
                 Case "Quest": actionResult := ActionQuest()
                 Default:
                     DebugLog("BotMain: Monitor reported 'start_next_config' for non-Quest action (" . currentAction . "). This is unexpected. Returning to NormalOperation.")
                     actionResult := "error"
                     gameState := "NormalOperation"
                     Return
             }
             ; Handle result of starting next run
             if (actionResult = "started") 
                DebugLog("BotMain: Successfully started next run for " . currentAction . ". Remaining in ActionRunning.")
             else if (actionResult = "outofresource")
                DebugLog("BotMain: Out of resources trying to start next run. Exiting action block.") ; lastActionTime[currentAction] := A_TickCount; currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1; gameState := "NormalOperation"; Loop, 2 {Send, {Esc} Sleep 500} }
             else if (actionResult = "disconnected")
                DebugLog("BotMain: Disconnected trying to start next run.") ; gameState := "NotLoggedIn"; AttemptReconnect(); }
             else
                DebugLog("BotMain: Failed to start next run ('" . actionResult . "'). Returning to NormalOperation.") ; gameState := "NormalOperation";
        }
        else if (monitorResult = "outofresource") {
            ; --- Logic for out of resources detected by monitor ---
            DebugLog("BotMain (" . currentAction . "): Monitor reported 'outofresource'. Exiting action block.")
            lastActionTime[currentAction] := A_TickCount
            currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
            gameState := "NormalOperation"
            DebugLog("BotMain (" . currentAction . "): Set gameState to NormalOperation. Cooldown started.")
        }
        else {
             ; Handles statuses where Monitor already changed gameState ("disconnected", "player_dead")
             ; OR statuses that require no BotMain action ("rerun", "in_progress", "error" if not handled above)
             DebugLog("BotMain (" . currentAction . "): Monitor returned status [" . monitorResult . "]. Monitor function handled state, or no further BotMain action needed this tick.")
        }

        DebugLog("BotMain (" . currentAction . "): End of ActionRunning check. Current gameState: " . gameState)
        Return
    }
Return ; End of BotMain
}
        
;===========================================
; MonitorActionProgress
;===========================================
MonitorQuestProgress() {
    global gameState, currentSelectionIndex, desiredZones, desiredDungeons ; Ensure globals are accessible
    DebugLog("MonitorActionProgress: --- Checking Action Progress ---") ; Log Entry

    ; --- Check 1: Action Complete? ---
    if (IsActionComplete()) {
        DebugLog("MonitorActionProgress: [Check 1] IsActionComplete = TRUE")

        ; Check if any configurations are actually defined
        if (desiredZones.Length() = 0) {
            DebugLog("MonitorActionProgress: No configurations defined - returning error state.")
            gameState := "NormalOperation" ; Fallback state
            DebugLog("MonitorActionProgress: ---> Returning 'error' (No Configs)")
            return "error"
        }

        ; Logic to cycle config index and decide next step
        oldIndex := currentSelectionIndex
        currentSelectionIndex := Mod(currentSelectionIndex, desiredZones.Length()) + 1
        DebugLog("MonitorActionProgress: Cycled to configuration index: " . currentSelectionIndex)

        ; Decide whether to rerun (if single config) or exit UI (if multiple configs)
        if (desiredZones.Length() = 1) {
            ; Single configuration defined
            DebugLog("MonitorActionProgress: Single configuration defined, attempting Rerun.")
            ClickRerun()
            Sleep, 1900

            ; Check for OutOfResources AFTER ClickRerun
            if (CheckOutOfResources()) {
                DebugLog("MonitorActionProgress: Out of resources detected after Rerun.")
                Loop, 4
                {
                    Send, {Esc}
                    Sleep, 300
                }
                Sleep, 200
                DebugLog("MonitorActionProgress: ***Attempting to return 'outofresource' status***")
                DebugLog("MonitorActionProgress: ---> Returning 'outofresource' (After Rerun)")
                return "outofresource"
            } else {
                DebugLog("MonitorActionProgress: Rerun initiated successfully (no resource issue detected).")
                DebugLog("MonitorActionProgress: ---> Returning 'rerun'")
                return "rerun"
            }
        } else {
            ; Multiple configurations defined
            DebugLog("MonitorActionProgress: Multiple configurations defined, exiting completion screen and Quest UI.")
            if (ClickTownOnCompletionScreen()) {
                Sleep, 1000

                ; Ensure Quest Window is closed, return to main screen
                DebugLog("MonitorActionProgress: Sending {Esc} to ensure Quest UI is closed.")
                Loop, 4
                {
                    Send, {Esc}
                    Sleep, 350
                }
                Sleep, 300

                DebugLog("MonitorActionProgress: Exited Quest UI, signaling BotMain to start next config.")
                DebugLog("MonitorActionProgress: ---> Returning 'start_next_config'")
                return "start_next_config"
            } else {
                DebugLog("MonitorActionProgress: Failed to click exit button cleanly. Returning error status.")
                DebugLog("MonitorActionProgress: ---> Returning 'error' (Exit Failed)")
                return "error"
            }
        }
    }

    ;Disconnect and Death checks not complete
    else if (IsDisconnected()) {
        DebugLog("MonitorActionProgress: IsActionComplete = FALSE")
        DebugLog("MonitorActionProgress: IsDisconnected = TRUE")
        DebugLog("MonitorActionProgress: Disconnect detected; attempting reconnection.")
        AttemptReconnect()
        gameState := "NotLoggedIn"
        DebugLog("MonitorActionProgress: ---> Returning 'disconnected'")
        return "disconnected"
    }
    else if (IsPlayerDead()) {
        DebugLog("MonitorActionProgress: IsActionComplete = FALSE")
        DebugLog("MonitorActionProgress: IsDisconnected = FALSE")
        DebugLog("MonitorActionProgress: IsPlayerDead = TRUE")
        DebugLog("MonitorActionProgress: Player death detected.")
        Send, {Esc}
        Sleep, 1000
        gameState := "NotLoggedIn"
        DebugLog("MonitorActionProgress: ---> Returning 'player_dead'")
        return "player_dead"
    }
    ; Condition: Action not complete, not disconnected, not dead
    else {
    if (HandleInProgressDialogue()) {
             ; Optional: Log that dialogue was handled.
             DebugLog("MonitorActionProgress: Dialogue Handled this tick.")
        }
        DebugLog("MonitorActionProgress: [Check 1] IsActionComplete = FALSE")
        DebugLog("MonitorActionProgress: [Check 2] IsDisconnected = FALSE")
        DebugLog("MonitorActionProgress: [Check 3] IsPlayerDead = FALSE")
        DebugLog("MonitorActionProgress: ---> Returning 'in_progress'")
        return "in_progress"
    }

    ; This part should not be reachable
    DebugLog("MonitorActionProgress: !!! Reached end of function unexpectedly !!!")
    return "error_unexpected_end"
}

MonitorPVPProgress() {
    global gameState
    DebugLog("MonitorPVPProgress: --- Checking PVP Progress ---")

    ; --- Check 1: Action Complete (Town Button Visible)? ---
    if (IsActionComplete()) {
        DebugLog("MonitorPVPProgress: [Check 1] IsActionComplete = TRUE (PVP Finished)")
        if (ClickTownOnCompletionScreen()) {
            DebugLog("MonitorPVPProgress: Clicked Town button after PVP.")
            sleep 900
            ; Return a status indicating success BUT that we want to loop PVP
            DebugLog("MonitorPVPProgress: ---> Returning 'pvp_completed_continue'")
            return "pvp_completed_continue"
        } else {
            DebugLog("MonitorPVPProgress: Failed to click Town button after PVP.")
            DebugLog("MonitorPVPProgress: ---> Returning 'error' (PVP Exit Failed)")
            return "error"
        }
    }
    else if (IsDisconnected()) {
        DebugLog("MonitorPVPProgress: Disconnect detected.")
        AttemptReconnect()
        gameState := "NotLoggedIn"
        return "disconnected"
    }
    else if (IsPlayerDead()) {
        DebugLog("MonitorPVPProgress: Player death detected during PVP.")
        if (ClickTownOnCompletionScreen()) {
             gameState := "NormalOperation"
             return "player_dead_handled"
        } else {
             Send, {Esc}
             Sleep, 1000
             gameState := "NotLoggedIn"
             return "player_dead"
        }
    }
    else if (HandleInProgressDialogue()) {
        DebugLog("MonitorPVPProgress: Dialogue Handled this tick.")
        ; Pvp should never have to handle dialog but its still here
    }

    DebugLog("MonitorPVPProgress: [Checks Complete] ---> Returning 'in_progress'")
    return "in_progress"
}
;===========================================
; PVP Helper Functions
;===========================================
IsPvpWindowOpen() {
Text:="|<>*144$255.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0000zzzy0000TzzzU00003zzk0001zzzw0000zzzzz00007zzzk0003zzzw00000Tzy0000DzzzU0007zzzzs0000zzzy0000TzzzU00003zzk0001zzzw0000zzzzz00007zzzk0003zzzw00000Tzy0000DzzzU0007zzzzs0000zzzy0000TzzzU00003zzk0001zzzw0000zzzzz00007zzzk0003zzzs00000Tzy0000DzzzU0007zzzzk0000Tzzw0000Dzzz000003zzU0000zzzs0000Tzzzs000003zU000001zs000000Tw0000007z0000003zzz000000Tw000000Dz0000003zU000000zs000000Tzzs000003zU000001zs000000Tw0000007z0000003zzz000000Tw000000Dz0000003zU000000zs000000Tzzs000003zU000001zs000000Tw0000007z0000003zzz03zy00Tw01zzU0Dz00TzzzzzU07zw00zs03zz00Tzzs0zzs03zU0Dzy01zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dzw01zs07zzzzzw01zzk07z00Tzs03zzz000000Tw000000Dz0000DzzzU0Dzy00zs000000Tzzs000003zU000001zs0001zzzw01zzk07z0000003zzz000000Tw000000Dz0000DzzzU0Dzy00zs000000Tzzs000003zU000001zs0001zzzw01zzk07z0000003zzz000000Tw000000Dz0000DzzzU0Dzy00zs000000Tzzs000003zU000001zs0001zzzw01zzk07z0000003zzz000000Tw00000Dzz0000DzzzU0Dzy00zs000000Tzzs000003zU00003zzs0001zzzw01zzk07z0000003zzz000000Tw00000Tzz0000DzzzU0Dzy00zs000000Tzzs000003zU00003zzs0001zzzw01zzk07z0000003zzz000000Tw00000Tzz0000DzzzU0Dzy00zs000000Tzzs000003zU00003zzs0001zzzw01zzk07z0000003zzz000000Tw00000Tzz0000DzzzU0Dzy00zs000000Tzzs0zzs03zU0Ds01zzs03zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zU00Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dw001zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zU00Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dw001zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zU00Dz00zzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dw001zs07zzzzzw01zzk07z00Tzs03zzz07zz00Tw01zzU0Dz00TzzzzzU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zs000000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz0000003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zs000000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz0000003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zs000000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0Dz0000003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zzs00000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0DzzU00003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zzw00000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0DzzU00003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zzw00000Tw01zzk07z00Tzs03zzz07zz00Tw01zzk0DzzU00003zU0Dzy00zs03zz00Tzzs0zzs03zU0Dzy01zzw00000Tw01zzk07z00Tzs03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
if (ok:=FindText(X, Y, 679, 453, 2504, 1632, 0, 0, Text))
    {
        DebugLog("IsPvpWindowOpen: PVP window detected.")
        return true
    } else {
        DebugLog("IsPvpWindowOpen: PVP window NOT detected.")
        return false
    }
}

ClickPVPButton() {
Text:="|<>*138$99.zw00000zzzy0D1sD7zU00007zzzk1sD1szw00000zzzy0D1sD7zU00000000D07ky7zw000000001s0y7kzzU00000000D07ky7zw000000001s0y7kzzU00000000D07ky7zzk00000001s01sD7zy00000000D00D1szzk00000001s01sD7zy00000000D00D1szzzU3sT0001zky7zzzzw0T3s000Dy7kzzzzzU3sT0001zky7zzzzw0T3s000Dy7kzzzzzU3sT0001zky7zvzzzsTw000001sDy0Tzzz3zU00000D1zk3zzzsTw000001sDy0Tzzz3zU00000D1zk3zzzsTw000001sDy0000Tw7U00007kzs00003zUw00000y7z00000Tw7U00007kzs00003zUw00000y7z0000Dzzs00001sDzzz001zzz00000D1zzzs00Dzzs00001sDzzz001zzz00000D1zzzs00Dzzs00001sDzzz0003zzzs007ky001s000Tzzz000y7k00D0003zzzs007ky001s000Tzzz000y7k00D401zsTzzz3sD0001sU0Dz3zzzsT1s000D401zsTzzz3sD0001sU0Dz3zzzsT1s000D401zsTzzz3sD0001szzzU07zw7Uy0000D7zzw00zzUw7k0001szzzU07zw7Uy0000D7zzw00zzUw7k0001szw0000T3sT00000D7zU0003sT3s00001szw0000T3sT00000D7zU0003sT3s00001szw0000T3sT00000D7zU00007Uzs0000zszw00000w7z00007z7zU00007Uzs0000zszw00000w7z00007z7zU0003sTzzk000y0zw0000T3zzy0007k7zU0003sTzzk000y0zw0000T3zzy0007k7zU0003sTzzk000y0zzk007Uw7zy001zkzzy000w7Uzzk00Dy7zzk007Uw7zy001zkzzy000w7Uzzk00Dy7zzk007Uw7zy001zkzzzw0T3s03zz07z07zzzU3sT00Tzs0zs0zzzw0T3s03zz07z07zzzU3sT00Tzs0zs0vzzw7Uw0007zy7k1sTzzUw7U000zzky0D3zzw7Uw0007zy7k1sTzzUw7U000zzky0D3zzw7Uw0007zy7k1sTzzz3s00001zz1zkvzzzsT00000DzsDy7Tzzz3s00001zz1zkvzzzsT00000DzsDy7Vzzzzs00001zzy7kwDzzzz00000Dzzky7Vzzzzs00001zzy7kwDzzzz00000Dzzky7Vzzzzs00001zzy7kvzzzzzw0007z1zz1sTzzzzzU000zsDzsD3zzzzzw0007z1zz1sTzzzzzU000zsDzsD7zzzzzzzUzzk1zzzzzzzzzzzw7zy0DzzzzzzzzzzzUzzk1zzzzzzzzzzzw7zy0Dzzzw"
if (ok:=FindText(X, Y, 612, 466, 2495, 1646, 0, 0, Text))
    {
    FindText().Click(X, Y, "L")
    sleep 800
    DebugLog("ClickPVPButton: PVP button clicked.")
    return true
    }    
else {
    DebugLog("ClickPVPButton: PVP button NOT detected.")
    return false
    }    
}

EnsureCorrectTicketsSelected(desired) {
;------------- PVP Ticket OCR Mapping for what user already has selected -------------
PvpTicketSelection := {}
PvpTicketSelection[1] := "|<>*148$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzz0Dzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzz0Dzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzz0Dzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzz0Dzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzk3zzzzzzzzzzU7zzzzzzzzzz0Dzzzzzzzzzy0Tzzzzzzzzzw0zzzzzzzzzzs1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
PvpTicketSelection[2] := "|<>*150$73.zzzzzzy000Dzzzzzzzz0007zzzzzzzzU000Dzzzzzzzk0007zzzzzzzs0003zzzzzzzzzzs1zzzzzzzzzzy0zzzzzzzzzzz0TzzzzzzzzzzUDzzzzzzzzzzU7zzzzzzzzk003zzzzzzzzs001zzzzzzzzw000zzzzzzzzy003zzzzzzzzU003zzzzzzzzk001zzzzzzzzs000zzzzzzzzw000Tzzzzzzzy0Tzzzzzzzzzz0DzzzzzzzzzzU7zzzzzzzzzzk3zzzzzzzzzzs0zzzzzzzzzzw0001zzzzzzzy0000zzzzzzzz0000TzzzzzzzU000Dzzzzzzzk0007zzzzzzzs0003zzzzzzzw0001zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
PvpTicketSelection[3] := "|<>*150$75.zzzzzzzzzzzzzzzzzzw000TzzzzzzzzU003zzzzzzzzw000TzzzzzzzzU003zzzzzzzzw000TzzzzzzzzU000Dzzzzzzzw0001zzzzzzzzU000Dzzzzzzzzzzs1zzzzzzzzzzzUDzzzzzzzzzzw1zzzzzzzzzzzUDzzzzzzzzzzs1zzzzzzzzzw00DzzzzzzzzzU01zzzzzzzzzw00DzzzzzzzzzU01zzzzzzzzzw00DzzzzzzzzzU01zzzzzzzzzw00DzzzzzzzzzU01zzzzzzzzzzzUDzzzzzzzzzzw1zzzzzzzzzzzUDzzzzzzzzzzw1zzzzzzzzzzz0Dzzzzzzzw0001zzzzzzzzU000Dzzzzzzzw0001zzzzzzzzU003zzzzzzzzw000TzzzzzzzzU003zzzzzzzzw000Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
PvpTicketSelection[4] := "|<>*141$99.0Tzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzz0Tzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzz0Tzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk3zU3zzzzzzzzzzzy0Tw0Tzzzzzzzzzzzk3zU3zzzzzzzzzzzy0Tw0Tzzzzzzzzzzzk3zU3zzzzzzzzzzzy0Tw0M3zzzzzzzzzzk3zU30Tzzzzzzzzzy0Tw0M3zzzzzzzzzzk3zU30Tzzzzzzzzzy0Tw0M3zzzzzzzzzzk3zU30Tzzzzzzzzzy0Tw0M3zzzzzzzzzzk3zU300Dzzzzzzzzy0000M01zzzzzzzzzk000300Dzzzzzzzzy0000M01zzzzzzzzzk000300Dzzzzzzzzzs000M01zzzzzzzzzz000300Dzzzzzzzzzs000M001zzzzzzzzz0003000Dzzzzzzzzzzw0M001zzzzzzzzzzzU3000Dzzzzzzzzzzw0M001zzzzzzzzzzzU3000Dzzzzzzzzzzw0M001zzzzzzzzzzzU3zUDzzzzzzzzzzzw0Tw1zzzzzzzzzzzzU3zUDzzzzzzzzzzzw0Tw1zzzzzzzzzzzzU3zUDzzzzzzzzzzzw0Tw1zzzzzzzzzzzzU3zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
PvpTicketSelection[5] := "|<>*150$105.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz0000zzzzzzzzzzzzzs0007zzzzzzzzzzzzz0000zzzzzzzzzzzzzs0007zzzzzzzzzzzzz0000zzzzzzzzzzzzzs0007zUDzzzzzzzzzz0000zw1zzzzzzzzzzs0007zUDzzzzzzzzzz0Dzzzw1zzzzzzzzzzs1zzzzUDzzzzzzzzzz0Dzzzw1zzzzzzzzzzs1zzzzUDzzzzzzzzzz0Dzzs000zzzzzzzzzs000z0007zzzzzzzzz0007s000zzzzzzzzzs000z0007zzzzzzzzzw007s000zzzzzzzzzzk0070007zzzzzzzzzy000s000zzzzzzzzzzk007zU007zzzzzzzzy000zw000zzzzzzzzzzzs7zU007zzzzzzzzzzz0zw000zzzzzzzzzzzs7zU007zzzzzzzzzzz0zw000zzzzzzzzzzzk7zU007zzzzzzzz0000zzy0zzzzzzzzzs0007zzk7zzzzzzzzz0000zzy0zzzzzzzzzs000zzzk7zzzzzzzzz0007zzy0zzzzzzzzzs000zzzk7zzzzzzzzz0007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"

PvpTicketMenuPatterns := {}
PvpTicketMenuPatterns[1] := "|<>*148$31.zzzzzzzzzzzzzzzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzz07zzzU3zzzk1zzzs0zzzw0Tzzy0Dzzzzzzzzzzzzzzzzzzzzzzk"
PvpTicketMenuPatterns[2] := "|<>*145$35.k000TzU000zz0001zy0003zw0000Ds0000Tk0000zzzzU1zzzzU3zzzz07zzzy0Dzzzw0Tzzzs0zy0001zw0003zs0007zk000Ds000Dzk000TzU000zz0001zy0Dzzzw0zzzzs1zzzzk3zzzzU7zzzz07zzzy00007w0000Ds0000Tk0000zU0001z00003y00007w0000Dzzzzzzzzzzzzzzzzzzzzzzzw"
PvpTicketMenuPatterns[3] := "|<>*148$39.s000Dzz0001zzs000Dzz0001zzs000Dzz00003zs0000Tz00003zzzzs0TzzzzU3zzzzw0TzzzzU3zzzzw0TzzzzU3zzz000Tzzs003zzz000Tzzs003zzz000Tzzs003zzz000Tzzs003zzzzw0TzzzzU3zzzzw0TzzzzU3zzzzw0Tzzzz03zs0000Tz00003zs0000Tz0001zzs000Dzz0001zzs000Dzz0001zzzzzzzzzzzzzzzzzzzzzw"
PvpTicketMenuPatterns[4] := "|<>*143$33.zzzzzzzzzzzzzzzzzzzzzzk3zs0y0Tz07k3zs0y0Tz07k3zs0y0Tz07k3zs0y0Tz07k3zs0y0Tz07k3zs0y0Tz07k3zs0y0Dz07k0000y00007k0000y00007z0000zs0007z0000zs0007zzzk0zzzz07zzzs0zzzz07zzzs0zzzz07zzzs0zzzz07zzzs0zzzz07zzzs0zzzz07zzzs0zzzz07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
PvpTicketMenuPatterns[5] := "|<>*145$37.w0000Dy00007z00003zU0001zk0000zs0000Tw0000Dy00007z07zzzzU7zzzzk3zzzzs1zzzzw0zzzzy0Dzzzz0001zzU000zzk000Tzs000Dzzk000Dzs0007zw0003zy0001zzzzk0zzzzw0Tzzzy0Dzzzz07zzzzU3zzzzU1zk0000zs0000Tw0000Dy0001zz0001zzU000zzk000Tzs000Dzzzzzzzzzzzzzzzzzzzw"

    current := ""
    for count, pat in PvpTicketSelection {
        if (ok:=FindText(X, Y, 675, 470, 2496, 1641, 0, 0, pat)) {
            current := count
            break
        }
    }
    if (current = desired) {
        DebugLog("Tickets already set to " . desired)
        return true
    }
;Open dropdown if selection needs altered
Text:="|<>*126$37.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy00000D000007U00003k00001s00000w00000Ty000Tzz000DzzU007zzk003zzs001zzw000zzy000TzzzUTzsTzkDzwDzs7zy7zw3zz3zy1zzVzz0zzkzzUTzs0Tzzs00Dzzw007zzy003zzz001zzzU00zzzk00Tzzs0007s004"
if (ok:=FindText(X, Y, 2030-150000, 920-150000, 2030+150000, 920+150000, 0, 0, Text))
{
  FindText().Click(X, Y, "L")
  DebugLog("Desired ticket count not matching the current selection. Dropdown opened.")
}
    Sleep, 900

    ; 3) Select the desired entry
    entryPattern := PvpTicketMenuPatterns[desired]
    if (ok:=FindText(X, Y, 905, 470, 2196, 1669, 0, 0, entryPattern)) {
        FindText().Click(X, Y, "L")
        Sleep, 900
        DebugLog("Tickets changed from " . current . " to " . desired)
        return true
    }

    DebugLog("Failed to select tickets=" . desired)
    return false
}

ClickPvpPlayButton() {
    Text:="|<>*144$141.zzzzzvzzy000TzzzyzzzzzzrU000zz0Dk00Ts007zk1zs0yw0007zs1y007z000zy0Dz07rU000zz0Dk01zs007zk1zs0yw0007zs1y00Dz000zy0Dz07rU000Tz0Dk01zs007zk1zs0yw0000Ds1y00DU0001y0Dz07rU0001z0Dk01w0000Dk1zs0yw0000Ds1y00DU0001y0Dz07rU0001z0Dk01w0000Dk1zs0yw0Ty0Ds1y00DU3zk1y0Dz07rU3zk1z0Dk01w0Ty0Dk1zs0yw0Ty0Ds1y00DU3zk1y0Dz07rU3zk1z0Dk01w0Ty0Dk1zs0yw0Ty0Ds1y00DU3zk1y0Dz07rU0001z0Dk01w0000Dk0000yw0000Ds1y00DU0001y00007rU0001z0Dk01w0000Dk0000yw0000Ds1y00DU0001y00007rU000Tz0Dk01w0000DzU00Dyw0007zs1y00DU0001zw001zrU000zz0Dk01w0000DzU00Dyw0007zs1zzzzU0001zw001zzU000zz0Dzzzw0000DzU00Dzw0Tzzzs1zzzzU3zk1zzs0zzzU3zzzz0Dzzzw0Ty0Dzz07zzw0Tzzzs1zzzzU3zk1zzs0zzzU3zzzz0Dzzzw0Ty0Dzz07zzw0Tzzzs0zzzzU3zk1zzs0zzzU3zzzz00003w0Ty0Dzz07zzw0Tzzzs0000TU3zk1zzs0zzzU3zzzz00003w0Ty0Dzz07zzw0Tzzzs0000TU3zk1zzs0zzzU3zzzzw0003w0Ty0Dzz07zzw0TzzzzU000TU3zk1zzs0zzzU3zzzzw0003w0Ty0Dzz07zzw0TzzzzU000TU3zk1zzs0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok:=FindText(X, Y, 659, 464, 2503, 1629, 0, 0, Text))
        {
        FindText().Click(X, Y, "L")
        mousemove, 300, 300
        Sleep, 800
        DebugLog("ClickPvpPlayButton: PVP play button clicked.")
        return true
        }
DebugLog("Could not find the PVP play button to click.")
return false
}

SelectOpponentPvpOpponentChoice(testMode := false) {

    ; fight button
    Text :="|<>*151$121.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs003s1zk007k7z0T0001w001w0zs003s3zUDU000y000y0Tw001w1zk7k000E000T0DU000y0zs3s0008000DU7k000T0Tw1w00040007k3s000DUDy0y00020003s1w000Dk7z0T00010Tzzw0y0zzzs3zUDzs3zUDzzy0T0Tzzw1zk7zw1zk7zzz0DUDzzy0zs3zy0zs1zzzU7k7zzz0Tw1zz0Tw00Tzk3s3s0DU000zzUDy00Dzs1w1w07k000Tzk7z007zw0y0y03s000Dzs3zU03zy0T0T01w0007zw1zk01zz0DUDU0y0003zy0zs00zzU7k7k0T0001zz0Tw00Tzk3s3s0DU000zzUDy0zzzs1w1zk7k7z0Tzk7z0Tzzw0y0zs3s3zUDzs3zUDzzy0T0Tw1w1zk7zw1zk7zzz0DUDy0y0zs3zy0zs3zzzU7k000T0Tw1zz0Tw1zzzk3s000DUDy0zzUDy0zzzs1w0007k7z0Tzk7z0Tzzw0zs00zs3zUDzs3zUDzzy0Tw00Tw1zk7zw1zk7zzz0Dy00Dy0zs3zy0zs3zzzU7z007z0Tw1zz0TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

    ; run the OCR over the PVP‑buttons region
    if !(ok:=FindText(X, Y, 451, 420, 2520, 1735, 0.09, 0.09, Text))
        return false

    ;--- TEST MODE: beep & move over each hit so you can verify all four are seen ---
    if (testMode) {
        for idx, hit in ok {
            MouseMove, hit.x, hit.y, 0
            SoundBeep, 1000, 200
            Sleep, 300
        }
        return true
    }

    ;--- NORMAL MODE: remap & click the one the user picked ---
    ; if OCR order != on‑screen order, adjust this map
    map := [3,1,4,2]            ; ← example: ok[1]→button#2, ok[2]→#4, etc.
    if (PvpOpponentChoice < 1 || PvpOpponentChoice > map.MaxIndex())
        return false

    realIdx := map[PvpOpponentChoice]
    if (!ok[realIdx])
        return false

    hit := ok[realIdx]
    MouseMove, hit.x, hit.y, 1
    Click
    Sleep, 200
    return true
}

ClickPvpAcceptButton() {
    Text:="|<>*137$199.zzzzs3zzzzkDzzzz0Tzzzztzzzztzzzzzzzzzy1zzzzs7zzzzUDzzzzwzzzzwzzzzzz000Try001zjs007yzU000Tz000zy00007U00Dzz000zzw003zzk000DzU00Tz00003k007zzU00Tzy001zzs0007zk00DzU0001s003zzk00Dzz000zzw0003zs007zk000000003w0000Dk0000zU0001y00007s000000001y00007s0000Tk0000z00003w000000000z00003w0000Ds0000TU0001y000000000TU0001y00007w0000Dk0000z000000Tw0Dk1zs0z03zU3y0Dzzzs0zw0Tzw0Dy0Tz07s0zw0TU3zk1z0Dzzzw0Ty0Dzz07z0DzU3w0Ty0Dk1zs0zU7zzzy0Dz07zzU3zU7zk1y0Dz07s0zw0Tk3zzzz07zU3zzk1zk3zs0z07zU3w0Ty0Ds1zzzjU3zk1xzs0zs0zs0TU3zzzy0Dzzzw0Tzs7k1zs0y1w0S00000Dk1zzzz07rzzy001w3s0000T0y0D000007s0yzzzU3vzzz000y1w0000DUT07U00003w0TDzzk1wzzzU00T0y00007kDU3k00001y0DVzzs0y7zrk00DUT00003s7k1s00000z07lzzw0T3zzs007kDU000zw3s0w00000TU3tzzy0Dbzzw003s7k000Tw1w0S00000Dk1xzzz07rzzy001w3s000Dy0y0DU00007s0zzzzU3vzzz000y1w0007y0T07k07z03w0Tzzzk1zzzzU3zz0y0Dzzs0DU3s07zk1y0Dz07s0zw0Tk3zzzz07zzw07k1w03zs0z07zU3w0Ty0Ds1zzzzU3zzw03s0y01zw0TU3zk1y0Dz07w0zzzzk1zzy01w0T00zy0Dk1zs0z07zU3y0Tzzzs0zzw00y0DU0Tz07s0000TU0001z00003w0T0000T07k0DzU3w0000Dk0000zU0001y0DU000DU3s07zk1y00007s0000Tk0000z07k0007k1w03zs0z00003w0000Ds0000TU3s0003s0y01zw0Ty000Tzw001zzk000Dk1w0001w0T00zy0DzU00Tzy001zzs0007s0y0000y0DU0Tz07zk00Dzz000zzw0003w0T0000T07k0DzU3zs007zzU00Tzy0001y0DU000DU3s07zk1zw003yTk00Dxz0000z07k0007k1wDzzzzwzzzzw3zzzzk7zzzzzzzs0003zzy7zxzzyTzzzy1zzzzs3zzzzzzzs0001zzy3zyzzz7zzzy0Tzzzw1zzzzzzzw0000Tzz1zyDzz3zzzy07zzzw0Tzzzzzzw00007zz0zw1zy0Tzzw00zzzs03zzzy3zs00000zy0E"
if (ok:=FindText(X, Y, 1862-150000, 1541-150000, 1862+150000, 1541+150000, 0, 0, Text)) ;Accept button right before being put into PVP battle
{
  FindText().Click(X, Y, "L")
  DebugLog("ClickPvpAcceptButton: PVP accept button found + clicked.")
  return true
}
return false
}
;===========================================
; Helper function to click the rerun button
;===========================================
ClickRerun() {
    ;OCR pattern for the rerun button
    Text:="|<>*143$154.000Dty000Dz001zs1zk3zs00Tk000zzs000zw007zU7z0DzU01zU003zzU003zk00Ty0Tw0zy007z000Dzy000Dz001zs1zk3zs00Tw0001y0000z0000TU7z0Dk0003k0007s0003w0001y0Tw0z0000D0000TU000Dk0007s1zk3w0000w0001y0000z0000TU7z0Dk0003k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Ty0TU7zzzk3zU7s1zk3w0zw0w1zs1y0Tzzz0Dy0TU7z0Dk3zk3k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Dy0TU7zw7k3zU7s1zk3w0zw0w0001y007kT0000TU7z0Dk3zk3k0007s00T1w0001y0Tw0z0Dz0D0000TU01w7k0007s1zk3w0zw0w000Ty007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D000DzU01w7k001zs1zk3w0zw0w000zy007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1w01y0Tzzz0DU0TU7z0Dk3zk3k7k07s1zzzw0y01y0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7s0003w0zs1y0000z0Dz0D0Ty0TU000Dk3zU7s0003w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7zU003w0zs1zs00Dz0Dz0D0Ty0Ty000Dk3zU7zU00zw0zw0w1zs1zs000z0Dy0Ty003zk3zk3k7zU7zU003w0zs1zs00Dz0Dz0DzzzzyzzzzzzzzzzrzzzyzzzzzzzzzztzzzzzzzTzzTzzznzzzzzs"
    ; Adjust the coordinates to the region where the button appears.
    if (ok:=FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickRerun: Rerun button clicked.")
    } else {
        DebugLog("ClickRerun: Rerun button NOT detected.")
    }
}

;===========================================
; Helper function to exit the completion screen (without rerunning)
;===========================================
ClickTownOnCompletionScreen() {
Text:="|<>*151$121.0000zy007zk3s1w0zw000000Tz003zs1w0y0Ty000000DzU01zw0y0T0Dz0000007s0001y0T0DU7k0000003w0000z0DU7k3s0000001y0000TU7k3s1w000zk3zz07y0Dk3s1w0y0DyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7k3s1w0zwzk3zz0Dz0Dk3s1w0y0TyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7k3s1w0zwzk3zz0Dz0Dk3s1w0y0TyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7U3k1w0zwzk3zz0000Dk00000y0TyTs1zzU0007s00000T0DzDw0zzk0003w00000DU7zby0Tzzk00zzs0003zk3znz0Dzzs00Tzw0001zs1zt"
 if (ok := FindText(X, Y, 1796-150000, 1532-150000 , 1796+150000, 1532+150000, 0, 0, Text))
    {
        FindText().Click(X, Y, "L")
        DebugLog("ClickTownOnCompletionScreen: Town button clicked.")
        return true          ; ✅ success – stop here
    }

    DebugLog("ClickTownOnCompletionScreen: Town button NOT detected.")
    return false             ; ❌ never found it at all
}
;===========================================
; Handle In-Progress Dialogue
;===========================================
HandleInProgressDialogue() {
;pattern is yellow arrow when dialogue is present
    dialoguePattern := "|<>F8F477-0.61$55.0zzU000000Tzk000000Dzs0000007zw0000003zy0000001zzzU00000zzzk00000Tzzs00000Dzzw000007zzy000003zzz000001zzzzk0000zzzzs0000Tzzzw0000Dzzzy00007zzzz00003zzzzU0001zzzzk0000zzzzzw000Tzzzzy000Dzzzzz0007zzzzzU003zzzzzk001zzzzzs000zzzzzw000Tzzzzzy00Dzzzzzz007zzzzzzU03zzzzzzk01zzzzzzs00zzzzzzw00Tzzzzzy00DzzzzzzzU7zzzzzzzk3zzzzzzzs1zzzzzzzw0zzzzzzzy0Tzzzzzzz0DzzzzzzzU7zzzzzzzk3zzzzzzzs1zzzzzzzw0zzzzzzzy0Tzzzzzzz0DzzzzzzzU7zzzzzzU03zzzzzzk01zzzzzzs00zzzzzzw00Tzzzzzy00Dzzzzzz007zzzzzzU03zzzzzk001zzzzzs000zzzzzw000Tzzzzy000Dzzzzz0007zzzzzU003zzzzzk001zzzzk0000zzzzs0000Tzzzw0000Dzzzy00007zzzz00003zzzzU0001zzzU00000zzzk00000Tzzs00000Dzzw000007zzy000003zzz000001zzzU00000zzU000000Tzk000000Dzs0000007zw0000003zy0000001zz0000000zzU000000Tk0000000Ds00000007w00000003y00000001z00000000zU000000E"
   if (ok:=FindText(X, Y, 1859, 727, 2495, 1369, 0, 0, dialoguePattern)) {
        DebugLog("HandleInProgressDialogue: Dialogue element detected")
        Send, {esc}
        DebugLog("HandleInProgressDialogue: Sent {esc} to dismiss dialogue.")
        Sleep, 20
        return true
    }
    DebugLog("HandleInProgressDialogue found no dialogue present")
    return false
}
;===========================================
; Helper function to attempt reconnection
;===========================================
AttemptReconnect() {
Text:="|<>*144$287.zzzz0TzzzzXzzzz0Tzzzs3zzzz0Tzzzs3zzzzyTzzzwzzzzzzzzy1zzzzzjzzzy1zzzzsDzzzz0zzzzs7zzzzwzzzzvzzzzzzzzy3zzzzzTzzzy3zzzzkTzzzy3zzzzkTzzzzxzzzzrzzzzs001zzk000zy001zTk00Dvy001zTk00Dzy0003zs00DzU0000003zzU001zw003zzU00Tzw003zzU00Tzw0007zk00Tz00000007zz0003zs007zz000zzs007zz000zzs000DzU00zy0000000Dzy0007zk00Dzy001zzk00Dzy001zzk000Tz001zw0000000Tzs000Dz000Tzs001zzU00Dzw001zzU000zw001zs00000003w0000TU0003y0000Tk0001y0000Dk0001y0000Dk00000007s0000z00007w0000zU0003w0000TU0003w0000TU0000000Dk0001y0000Ds0001z00007s0000z00007s0000z00000Tw0TU3zzzw0Ty0Tk3zk3y0Ty0Dk3zk1y0Dzzzk1zk1zzk1z0zw0z07zzzs0zw0zU7zU7w0zw0TU7zU3w0zzzzU7zU3zzU3y1zs1y0Dzzzk1zs1z0Dz0Ds1zs0z0Dz07s1zzzz0Dz07zz07w3zk3w0TzzzU3zk3y0Ty0Tk3zk1y0Ty0Dk3zzzy0Ty0Dzy0Ds7zU7s0zzzj07zU7w0zw0zU7zU3w0zw0TU7zzxw0zw0Tzw0Tk000Dk00DUS0Dzzzs1zs1z0Dz07s1zs0z000y3s1zzzy3s0zU000TU00T0w0Tzzzk3zk3y0Ty0Dk3zk1y001w7k3zzzs7k1z0000z000y1s0yzzzU7zU7w0zw0TU7zU3w003sDU7rzzkDU3y0001y001w3k1wzzz0Dz0Ds1zs0z0Dz07s007kT0Dbzz0T07w000zw003zzU3zzzy0Ty0Tk3zk1y0Ty0Dk00Dzy0Tzzzzy0Ds003zs007zz07zzzw0zw0zU7zU3w0zw0TU00Tzw0zzzzzw0Tk007zk00Dzy0Dzzzs1zs1z0Dz07s1zs0z000zzs1zzzzzs0zU00DzU00Tzw0Tzzzk3zk3y0Ty0Dk3zk1y001zzk3zzzzzk1z000Dz000zzs0zzzzU7zU7w0zw0TU7zU3w003zzU7zzzzzU3y1w01y0Dzzzk1zs1z0Dz0Ds1zs0z0Dz07s1zzzz0Dz07zz07w3s03w0TzzzU3zk3y0Ty0Tk3zk1y0Ty0Dk3zzzy0Ty0Dzy0Ds7k07s0zzzz07zU7w0zw0zU7zU3w0zw0TU7zzzw0zw0Tzw0TkDU0Dk1zzzy0Dz0Ds1zs1z0Dz07s1zs0z0Dzzzs1zs0zzs0zUTy0TU3zzzw0Ty0Tk3zk3y0Ty0Dk3zk1y0Dzzzk1zk1zzk1z0zw0z00007s0000zU0007w0zw0TU7zU3w0000TU0003zzU3y1zs1y0000Dk0001z0000Ds1zs0z0Dz07s0000z00007zz07w3zk3w0000TU0003y0000Tk3zk1y0Ty0Dk0001y0000Dzy0Ds7zU7zU000zy001zzk00DzU7zU3w0zw0Ty0003zk007zzw0TkDz0DzU001zw003zzU00Tz0Dz07s1zs0zw0007zk00Tzzs0zUTy0Tz0003zs007zz000zy0Ty0Dk3zk1zs000DzU00zzzk1z0zw0zy0007zk00Dzy001zw0zw0TU7zU3zk000Tz001zzzU3y1zs1zw000DzU00Tzw003zs1zs0z0Dz07zU000zy003zzz07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
if (ok:=FindText(X, Y, 696, 470, 2503, 1632, 0, 0, Text))
{
    FindText().Click(X, Y, "L")
    debugLog("AttemptReconnect clicked reconnect button.")
    sleep 3000
}
}

;===========================================
;Check Functions
;===========================================
IsActionComplete() {
    ; Town button OCR
    Text:="|<>*151$121.0000zy007zk3s1w0zw000000Tz003zs1w0y0Ty000000DzU01zw0y0T0Dz0000007s0001y0T0DU7k0000003w0000z0DU7k3s0000001y0000TU7k3s1w000zk3zz07y0Dk3s1w0y0DyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7k3s1w0zwzk3zz0Dz0Dk3s1w0y0TyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7k3s1w0zwzk3zz0Dz0Dk3s1w0y0TyTs1zzU7zU7s1w0y0T0DzDw0zzk3zk3w0y0T0DU7zby0Tzs1zs1y0T0DU7k3znz0Dzw0zw0z0DU7k3s1ztzU7zy0Ty0TU7U3k1w0zwzk3zz0000Dk00000y0TyTs1zzU0007s00000T0DzDw0zzk0003w00000DU7zby0Tzzk00zzs0003zk3znz0Dzzs00Tzw0001zs1zt"
    if (ok:=FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Text))
        return true
    return false
}

IsDisconnected() {
Text:="|<>*144$287.zzzz0TzzzzXzzzz0Tzzzs3zzzz0Tzzzs3zzzzyTzzzwzzzzzzzzy1zzzzzjzzzy1zzzzsDzzzz0zzzzs7zzzzwzzzzvzzzzzzzzy3zzzzzTzzzy3zzzzkTzzzy3zzzzkTzzzzxzzzzrzzzzs001zzk000zy001zTk00Dvy001zTk00Dzy0003zs00DzU0000003zzU001zw003zzU00Tzw003zzU00Tzw0007zk00Tz00000007zz0003zs007zz000zzs007zz000zzs000DzU00zy0000000Dzy0007zk00Dzy001zzk00Dzy001zzk000Tz001zw0000000Tzs000Dz000Tzs001zzU00Dzw001zzU000zw001zs00000003w0000TU0003y0000Tk0001y0000Dk0001y0000Dk00000007s0000z00007w0000zU0003w0000TU0003w0000TU0000000Dk0001y0000Ds0001z00007s0000z00007s0000z00000Tw0TU3zzzw0Ty0Tk3zk3y0Ty0Dk3zk1y0Dzzzk1zk1zzk1z0zw0z07zzzs0zw0zU7zU7w0zw0TU7zU3w0zzzzU7zU3zzU3y1zs1y0Dzzzk1zs1z0Dz0Ds1zs0z0Dz07s1zzzz0Dz07zz07w3zk3w0TzzzU3zk3y0Ty0Tk3zk1y0Ty0Dk3zzzy0Ty0Dzy0Ds7zU7s0zzzj07zU7w0zw0zU7zU3w0zw0TU7zzxw0zw0Tzw0Tk000Dk00DUS0Dzzzs1zs1z0Dz07s1zs0z000y3s1zzzy3s0zU000TU00T0w0Tzzzk3zk3y0Ty0Dk3zk1y001w7k3zzzs7k1z0000z000y1s0yzzzU7zU7w0zw0TU7zU3w003sDU7rzzkDU3y0001y001w3k1wzzz0Dz0Ds1zs0z0Dz07s007kT0Dbzz0T07w000zw003zzU3zzzy0Ty0Tk3zk1y0Ty0Dk00Dzy0Tzzzzy0Ds003zs007zz07zzzw0zw0zU7zU3w0zw0TU00Tzw0zzzzzw0Tk007zk00Dzy0Dzzzs1zs1z0Dz07s1zs0z000zzs1zzzzzs0zU00DzU00Tzw0Tzzzk3zk3y0Ty0Dk3zk1y001zzk3zzzzzk1z000Dz000zzs0zzzzU7zU7w0zw0TU7zU3w003zzU7zzzzzU3y1w01y0Dzzzk1zs1z0Dz0Ds1zs0z0Dz07s1zzzz0Dz07zz07w3s03w0TzzzU3zk3y0Ty0Tk3zk1y0Ty0Dk3zzzy0Ty0Dzy0Ds7k07s0zzzz07zU7w0zw0zU7zU3w0zw0TU7zzzw0zw0Tzw0TkDU0Dk1zzzy0Dz0Ds1zs1z0Dz07s1zs0z0Dzzzs1zs0zzs0zUTy0TU3zzzw0Ty0Tk3zk3y0Ty0Dk3zk1y0Dzzzk1zk1zzk1z0zw0z00007s0000zU0007w0zw0TU7zU3w0000TU0003zzU3y1zs1y0000Dk0001z0000Ds1zs0z0Dz07s0000z00007zz07w3zk3w0000TU0003y0000Tk3zk1y0Ty0Dk0001y0000Dzy0Ds7zU7zU000zy001zzk00DzU7zU3w0zw0Ty0003zk007zzw0TkDz0DzU001zw003zzU00Tz0Dz07s1zs0zw0007zk00Tzzs0zUTy0Tz0003zs007zz000zy0Ty0Dk3zk1zs000DzU00zzzk1z0zw0zy0007zk00Dzy001zw0zw0TU7zU3zk000Tz001zzzU3y1zs1zw000DzU00Tzw003zs1zs0z0Dz07zU000zy003zzz07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
if (ok:=FindText(X, Y, 696, 470, 2503, 1632, 0, 0, Text)) {
    DebugLog("IsDisconnected finds player disconnect")
    return true
    }
    else 
    return false
}

IsPlayerDead() {
   Text:="|<>*147$237.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU003zzzs0000zzU0007zw0000TzU003zy00000Tw000Tzzz00007zw0000zzU0003zw000Tzk00003zU003zzzs0000zzU0007zw0000TzU003zy00000Tw000Tzzz00007zw0000zzU0003zw000Tzk00003zU003zzzs0000zzU0007zw0000TzU001zy00000Tw0000zzU00007w00000zk00003y00000Tk00003zU0007zw00000zU00007y00000Tk00003y00000Tw0000zzU00007w00000zk00003y00000Tk00003zU0007zw00000zU00007y00000Tk00003y00000Tw0Dk0zzU1zzzzw07zzzzk0zzzzy07zs0TzzU0zzzU1y007w0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0Dk00zU1zzzzw0Dzzzzk0zzzzy07zs0TzzU1zzzU1y007w0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0Dk00zU1zzzzw0Dzzzzk0zzzzy07zs0TzzU1zzzU1y007w0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0DzU0zU003zzw000Tzzk001zzy00000TzzU1zzzU1zw07w000TzzU003zzy000Dzzk00003zzw0Dzzw0DzU0zU003zzw000Tzzk001zzy00000TzzU1zzzU1zw07w000TzzU003zzy000Dzzk00003zzw0Dzzw0DzU0zU003zzw000Tzzk001zzy00000TzzU1zzzU1zw07w000TzzU003zzy000Dzzk00003zzw0Dzzw0DzU0zU003zzw000Tzzk001zzy00000TzzU1zzzU1zw07w000TzzU003zzy000Dzzk00003zzw0Dzzw0DzU0zU003zzw000Tzzk001zzy00000TzzU1zzzU1zw07w000TzzU003zzy000Dzzk00003zzw0Dzzw0DzU0zU1zzzzw07zzzzk0zzzzy07zs0TzzU1zzzU1y007w0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0Dk00zU1zzzzw0Dzzzzk0zzzzy07zs0TzzU1zzzU1y007w0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0Dk00zU1zzzzw0Dzzzzk0zzzzy07zs0TzzU1zzzU1y03zw0DzzzzU1zzzzy07zzzzk0zz03zzw0Dzzw0000zzU00007w0Dzzzzk00003y07zs0TzzU1zzzU0007zw00000zU1zzzzy00000Tk0zz03zzw0Dzzw0000zzU00007w0Dzzzzk00003y07zs0TzzU1zzzU0007zw00000zU1zzzzy00000Tk0zz03zzw0Dzzw0000zzU00007w0Dzzzzk00003y07zs0TzzU1zzzU003zzzs0000zU1zzzzzw0000Tk0zz03zzw0Dzzw000Tzzz00007w0DzzzzzU0003y07zs0TzzU1zzzU003zzzs0000zU1zzzzzw0000Tk0zz03zzw0Dzzw000Tzzz00007w0DzzzzzU0003y07zs0TzzU1zzzU003zzzs0000zU1zzzzzw0000Tk0zz03zzw0Dzw"
if (ok:=FindText(X, Y, 672, 371, 2508, 944, 0, 0, Text)) {
    DebugLog("Found player death")
    return true
    }
    else
    return false 
}

;===========================================
; DebugLog: Helper Function for Debug Output
;===========================================
DebugLog(msg) {
    OutputDebug, % msg " Orion"
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, % timestamp " - " msg "`n", debug_log.txt
}

;===========================================
; OCR & UI Detection Functions
;===========================================
IsMainScreenAnchorDetected() {
    Text := "|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text)) {
        SoundBeep, 800, 200
        DebugLog("IsMainScreenAnchorDetected: Quest icon detected.")
        Return True
    }
    DebugLog("IsMainScreenAnchorDetected: Quest icon NOT detected.")
    Return False
}

ArePopupsPresent() {
    Text := "|<>**50$59.k07w01z00CU08000200F00E000400W00U0008014010000E028020000U04E07y03z008U00404000F000808000W000E0E0014000U0U0028001010004E003zy0008zU000000zk1000000100200000020040000004008000000800E000000E00U000000U01zU0003z0001000040000200008000040000E000080000U0000E000100000U000200001000040000200008000040000E000080000U0000E000100000U00020003z00007y0040000004008000000800E000000E00U000000U01000000103y0000003z4000zzU0028001010004E002020008U00404000F000808000W000E0E0014000U0U002E"
    if (ok := FindText(X, Y, 2177-150000, 680-150000, 2177+150000, 680+150000, 0, 0, Text)) {
        DebugLog("ArePopupsPresent: Popup detected.")
        Return True
    }
    Return False
}
;ArePopupsPresent() is not called, which is fine.
CheckOutOfResources() {
    Text:="|<>*144$123.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk07zs03zU0zzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00TzU0Dy01zzU0Tzzzzzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzzz0000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Text)) {
        DebugLog("Resources are depleted.")
        return true
        }
    return false       
}


;===========================================
; Quest Action – Full Quest Logic
;===========================================
ActionQuest() {
    ; Step 1: Open the Quest Window if not open.
    if (!IsQuestWindowOpen()) {
        DebugLog("ActionQuest: Quest window not open. Clicking quest icon.")
        ClickQuestIcon()
        Sleep, 500
        if (!IsQuestWindowOpen()) {
            DebugLog("ActionQuest: Quest window still not detected; Sending {esc}")
            send {esc}
            return "retry"
        }
    }
    
    ; Step 2: Retrieve desired zone/dungeon configuration.
    global desiredZones, desiredDungeons, currentSelectionIndex
    selectedZone := desiredZones[currentSelectionIndex]
    selectedDungeon := desiredDungeons[currentSelectionIndex]
    DebugLog("ActionQuest: Selected configuration: " . selectedZone . " - " . selectedDungeon)
    
    ; Step 3: Navigate to the desired zone.
    if (!EnsureCorrectZoneSelected(selectedZone)) {
        DebugLog("ActionQuest: Could not navigate to " . selectedZone . "; retrying.")
        return "retry"
    }
    
    ; Step 4: Navigate/select the desired dungeon.
    targetDungeonIndex := SubStr(selectedDungeon, 8)  ; Assumes "Dungeon" is 7 chars.
    if (!EnsureCorrectDungeonSelected(selectedZone, targetDungeonIndex)) {
        DebugLog("ActionQuest: Could not select dungeon " . selectedDungeon . " in " . selectedZone . "; retrying.")
        return "retry"
    }
    
    ; Step 5: Select Heroic Difficulty.
    if (!SelectHeroicDifficulty()) {
        DebugLog("ActionQuest: Heroic difficulty not confirmed; retrying.")
        return "retry"
    }
; Step 6: Click Accept.
    result := ClickAccept()
    if (result = "confirmed") {
        Sleep, 800 ; Wait a bit after confirmation seems successful
    } else if (result = "outofresource") {
        DebugLog("ActionQuest: Out-of-resources detected by ClickAccept; starting cooldown.")
        return "outofresource"
    } else { ; Handles "retry" or other unexpected results from ClickAccept
        DebugLog("ActionQuest: ClickAccept did not return 'confirmed' or 'outofresource'. Checking for disconnect...")
        ; *** ADD DISCONNECT CHECK HERE ***
        if (IsDisconnected()) {
             DebugLog("ActionQuest: Disconnect detected after ClickAccept failure.")
             AttemptReconnect() ; Optional: Try clicking reconnect button immediately
             return "disconnected" ; <<< Return specific status
        } else {
             ; If not disconnected, proceed with original retry logic
             DebugLog("ActionQuest: Accept not confirmed (and not disconnected) retrying ActionQuest.")
             return "retry"
        }
    }

    ; Step 7: Check for resource shortage (Only runs if Step 6 was "confirmed")
    if (CheckOutOfResources()) {
        DebugLog("ActionQuest: Detected resource shortage after Accept.")
        return "outofresource"
    }

    DebugLog("ActionQuest: Quest action initiated successfully.")
    return "started"
}

;===========================================
; Heroic Difficulty Functions
;===========================================
SelectHeroicDifficulty() {
    ; Define your OCR pattern for detecting the heroic difficulty button.
    Text:="|<>*133$179.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zs3zw0zzzzU1zzzk07zzzU7zs1zzzzzwTzy7zzzzsDzzzs0zzzzUzzsDzzzzzwzzyDzzzzszzzzs3zzzzXzzszzzzzzvzzwzzzzztzzzzk7zzzzjzzvzzzzzzzzzxzzzzzrzzzzUDzzzzTzzrzzzz07zU3zs000DzU00Dvz000zy0DzU00C0Dz07zk000Tz000Tzy001zw0Tz000Q0Ty0DzU000zy000zzw003zs0zy000s0zw0Tz0001zw001zzs007zk1zw001k1zs0zw0003zs003zzU007zU3zs003U3zk1y00007s0000Tk0000z07s000307zU3w0000Dk0000zU0001y0Dk00060Dz07s0000TU0001z00003w0TU000A0Ty0Dk0000z00003y00007s0z0000M0zw0TU3zzzy0DzU7w0Ty0Dk1y0Dz0k1zs0z07zzzw0Tz0Ds0zw0TU3w0Ty1U3zk1y0Dzzzs0zy0Tk1zs0z07s0zw307zU3w0Tzzzk1zw0zU3zk1y0Dk1zs60Dz07s0zzk7U1zk1z07zU3w0TU3zzw0000Dk007UD00003y0Dz07s0z07rzs0000TU00D0S00007w0Ty0Dk1y0Djzk0000z000S0w0000Ds0zw0TU3w0TDzU0001y000w1s0000Tk1zs0z07s0y7z00003w001s3k000DzU3zk1y0Dk1wDy00007s003k7U000Tz07zU3w0TU3tzw0000Dk007UD0000zy0Dz07s0z07rzs0000TU00D0S0001zw0Ty0Dk1y0Dzzk1zk0z07zz0w0D03zs0zw0TU3w0TzzU3zk1y0Dzzzs0z00Tk1zs0z07s0zw307zU3w0Tzzzk1y00zU3zk1y0Dk1zs60Dz07s0zzzzU3w01z07zU3w0TU3zkA0Ty0Dk1zzzz07s03y0Dz07s0z07zUM0zw0TU3zzzy0Dz07w0Tw0Dk1y07z0k1zs0z00003w0Tz0Ds0000TU3w0001U3zk1y00007s0zy0Tk0000z07s000307zU3w0000Dk1zw0zU0001y0Dk00060Dz07s0000TU3zs1z00003w0TU000A0Ty0DzU000z07zk3zw003zs0zy000s0zw0Tz0001y0DzU7zs007zk1zw001k1zs0zy0003w0Tz0Dzk00DzU3zs003U3zk1zw0007s0zy0TzU00Tz07zk007zzzzzvzzzzzzzzzzyTzzzyzzzjzzzzzzzzzbzzzzzzzzzzwzzzzxzzzTzzzzzyzzzDzzzzzzzrzztzzzzlzzwTzzzzzszzwDzzzzzzz7zzVzzzzVzzsTzzzzzUTzk7zzzwDzs7zy1zzzw1zz0Tzzy000000000000000000000000000000000000000000000000000000000004"
    if (ok := FindText(X, Y, 2020-150000, 1033-150000, 2020+150000, 1033+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
    }
    Sleep, 1100  ; Allow the UI to update.
    
    ; Check if we are on team screen via accept button
    if (IsHeroicSelected()) {
        DebugLog("SelectHeroicDifficulty: Heroic difficulty confirmed.")
        return true
    } else {
        DebugLog("SelectHeroicDifficulty: Heroic difficulty not confirmed.")
        return false
    }
}

IsHeroicSelected() {
    ; Define your OCR pattern for detecting if heroic difficulty is active.
    Text:="|<>*140$203.7zzzzUTzzzy1zzzzs3zzzzzDzzzzTzzzzzz000Try001zzs007yzU000Tz000zy00007y000zzw003zzk00Dzz0000zy001zw0000Dw001zzs007zzU00Tzy0001zw003zs0000Ts003zzk00Dzz000zzw0003zs007zk0000w0000Dk0000z00003y00007s0000TU0001s0000TU0001y00007w0000Dk0000z00003k0000z00003w0000Ds0000TU0001y00007U0001y00007s0000Tk0000z00003w0000D07z03w0Ty0Dk1zs0zU3zzzy0Dz07zzU3zy0Tz07s0zw0TU3zk1z0Dzzzw0Ty0Dzz07zw0zy0Dk1zs0z07zU3y0Tzzzs0zw0Tzy0Dzs1zw0TU3zk1y0Dz07w0zzzzk1zs0zzw0Tzk3zs0z07zU3w0Ty0Ds1zzzjU3zk1xzs0zzU3zU1y0Dzzzs0zzzzk1zzUT07zU3s7k1w700003w0Tzzzk1xzzzU00T0y00007kDU3kC00007s0yzzzU3vzzz000y1w0000DUT07UQ0000Dk1wzzz07nzzy001w3s0000T0y0D0s0000TU3sTzy0DVzxw003s7k0000y1w0S1k0000z07lzzw0T7zzs007kDU000zw3s0w3U0001y0Dbzzs0yTzzk00DUT0001zk7k1s700003w0TTzzk1xzzzU00T0y0003zUDU3sC00007s0zzzzU3zzzz000y1w0007y0T07kQ0Ty0Dk1zzzz07zzzy0Dzw3s0zzzU0y0DUs1zw0TU3zk1y0Dz07w0zzzzk1zzz01w0T1k3zs0z07zU3w0Ty0Ds1zzzzU3zzw03s0y3U7zk1y0Dz07s0zw0Tk3zzzz07zzs07k1w70DzU3w0Ty0Dk1zs0zU7zzzy0Dzz00DU3sC0Tz07s0000TU0001z00003w0T0000T07kQ0zy0Dk0000z00003y00007s0y0000y0DUs1zw0TU0001y00007w0000Dk1w0001w0T1k3zs0z00003w0000Ds0000TU3s0003s0y3U7zk1zs003zzk007zz0000z07k0007k1w70DzU3zs007zzU00Tzy0001y0DU000DU3sC0Tz07zk00Dzz000zzw0003w0T0000T07kQ0zy0DzU00Tzy001zzs0007s0y0000y0DUs1zw0Tz000zbw003zTk000Dk1w0001w0T1" 
    if (ok := FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Text)) {
        DebugLog("IsHeroicSelected finds heroic is clicked by finding accept button on the team screen")
        return true
    } else {
        DebugLog("IsHeroicSelected not finding team screen")
        return false
    }
}

;===========================================
; Quest Helper Functions
;===========================================
IsQuestWindowOpen() {
    Text:="|<>*143$173.00003zw003zzk00Dzz0000zy0003s00007zs007zzU00Tzy0001zw0007k0000DzU00Dzz000zzw0003zk000DU0000Tk0000z00003w00007s0000T00000zU0001y00007s0000Dk0000y00001z00003w0000Dk0000TU0001w00003y00007s0000TU0001z00003tzzk07w0Ty0Dk1zs0z07zzzy0DzzznzzU0Ds0zw0TU3zk1y0Dzzzw0Tzzzbzz00Tk1zs0z07zU3w0Tzzzs0zzzyDzy00zU3zk1y0Dz07s0zzzzk1zzzsTzw0Tz07zU3w0Ty0Dk1zzzjU3zzzU7w00zy0Dz07s0zw0TU00DUT0001zUTs01zw0Ty0Dk1zs0z000T0y0003zVzk03zs0zw0TU3zk1y000y1w0007z3zU07zk1zs0z07zU3w001w3s000DzDy07zjU3zk1y0Dz07s003s7zU00TyT00DyT07zU3w0Ty0Dk007kDz0001wy00Twy0Dz07s0zw0TU00DUTy0003tw00zzw0Ty0Dk1zs0z000Tzzw0007zs01zzs0zw0TU3zk1y000zzzs000Ds01zzzk1zs0z07zU3w0Tzzzzzzw0Tk03zzzU3zk1y0Dz07s0zzzzzzzs0zU07zzz07zU3w0Ty0Dk1zzzzzzzk1z00Dzzy0Dz07s0zw0TU3zzzzzzzU3y00Tzzw0Ty0Dk1zs0z07zzzzzzz07w0000Ds0000TU3zk1y00007w0000Ds0000Tk0000z07zU3w00007s0000Tk0000zU0001y0Dz07s0000Dk0000zU0001z00003w0Ty0Dk0000TU0001z00003zw003zs0zw0Tz0000z0001zy00007zs007zk1zs0zy0001y0003zw0000Dzk00DzU3zk1zw0003w0007zs0000TzU00Tz07zU3zs0007s000Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok := FindText(X, Y, 1045-150000, 642-150000, 1045+150000, 642+150000, 0, 0, Text))
        return true
    return false
}
ClickQuestIcon() {
    Text := "|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        Sleep, 100
        DebugLog("ClickQuestIcon: Quest icon clicked.")
    }
}

ClickAccept() {
    Text := "|<>*140$203.7zzzzUTzzzy1zzzzs3zzzzzDzzzzTzzzzzz000Try001zzs007yzU000Tz000zy00007y000zzw003zzk00Dzz0000zy001zw0000Dw001zzs007zzU00Tzy0001zw003zs0000Ts003zzk00Dzz000zzw0003zs007zk0000w0000Dk0000z00003y00007s0000TU0001s0000TU0001y00007w0000Dk0000z00003k0000z00003w0000Ds0000TU0001y00007U0001y00007s0000Tk0000z00003w0000D07z03w0Ty0Dk1zs0zU3zzzy0Dz07zzU3zy0Tz07s0zw0TU3zk1z0Dzzzw0Ty0Dzz07zw0zy0Dk1zs0z07zU3y0Tzzzs0zw0Tzy0Dzs1zw0TU3zk1y0Dz07w0zzzzk1zs0zzw0Tzk3zs0z07zU3w0Ty0Ds1zzzjU3zk1xzs0zzU3zU1y0Dzzzs0zzzzk1zzUT07zU3s7k1w700003w0Tzzzk1xzzzU00T0y00007kDU3kC00007s0yzzzU3vzzz000y1w0000DUT07UQ0000Dk1wzzz07nzzy001w3s0000T0y0D0s0000TU3sTzy0DVzxw003s7k0000y1w0S1k0000z07lzzw0T7zzs007kDU000zw3s0w3U0001y0Dbzzs0yTzzk00DUT0001zk7k1s700003w0TTzzk1xzzzU00T0y0003zUDU3sC00007s0zzzzU3zzzz000y1w0007y0T07kQ0Ty0Dk1zzzz07zzzy0Dzw3s0zzzU0y0DUs1zw0TU3zk1y0Dz07w0zzzzk1zzz01w0T1k3zs0z07zU3w0Ty0Ds1zzzzU3zzw03s0y3U7zk1y0Dz07s0zw0Tk3zzzz07zzs07k1w70DzU3w0Ty0Dk1zs0zU7zzzy0Dzz00DU3sC0Tz07s0000TU0001z00003w0T0000T07kQ0zy0Dk0000z00003y00007s0y0000y0DUs1zw0TU0001y00007w0000Dk1w0001w0T1k3zs0z00003w0000Ds0000TU3s0003s0y3U7zk1zs003zzk007zz0000z07k0007k1w70DzU3zs007zzU00Tzy0001y0DU000DU3sC0Tz07zk00Dzz000zzw0003w0T0000T07kQ0zy0DzU00Tzy001zzs0007s0y0000y0DUs1zw0Tz000zbw003zTk000Dk1w0001w0T1"
    if (ok := FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickAccept: Accept button clicked.")
        Sleep, 1400  ; Allow UI to update.
    }
    
    ; Immediately check for the out-of-resources condition.
    if (CheckOutOfResources()) {
        DebugLog("ClickAccept: Out-of-resources detected after clicking Accept.")
        Loop, 4 {
            Send, {Esc}
            Sleep, 650
        }
        ; Return a special status so the main routine triggers a cooldown and rotates to the next action.
        return "outofresource"
    }
    
    ; Finally, check if the accept confirmation appears.
    if (IsAcceptConfirmed()) {
        DebugLog("ClickAccept: Accept confirmed.")
        return "confirmed"
    }
    
    DebugLog("ClickAccept: Accept not confirmed.")
    return "retry"
}

IsAcceptConfirmed() {
    Loop, 5 {
    sleep 500 ;Checking for RED auto button
    Text:="|<>D6261E-0.90$61.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw000Tzzzzzw0003zzzzzw0001zzzzzy0000Tzzzzs00003zzzzs00000zzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU01001zzzzk00k01zzzzy01w01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs01s03zzzzs00M00zzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00001zzzzw00001zzzzzk0003zzzzzs0003zzzzzy0001zzzzzzk003zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0000DzzzzU00003zzzzk00000zzzzk00000Tzzzs00000Dzzzw000007zzzy000003zzzz000001zzzzU00000zzzzk00000Tzzzw00000Dzzzy000007zzzzU00007zzzzy0000Tzzzzzw007zzzzzzy003zzzzzzz001zzzzzzzU00zzzzzzzk00Tzzzzzzs00Dzzzzzzw007zzzzzzy003zzzzzzz001zzzzzzzU00zzzzzzzk00Tzzzzzzs00Dzzzzzzw007zzzzzzy003zzzzzzz001zzzzzzzU00zzzzzzzk00Tzzzzzzs00Dzzzzzzw007zzzzzzz003zzzzzzzU03zzzzzzzy0Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs000Dzzzzzs0003zzzzzw0001zzzzzs00007zzzzk00001zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzw00000Dzzzy000007zzzz000003zzzzU00001zzzzk00000zzzzs00000Tzzzy00000TzzzzU0000zzzzzw0001zzzzzy0000zzzzzzU000zzzzzzzzzzzzzzzzzzzzzzzw"
if (ok:=FindText(X, Y, 1186, 384, 3207, 1659, 0, 0, Text)) {
        send {space}
        DebugLog("Found that AutoPilot was turned off. Sent space to toggle")
        return true
}
    sleep 2000
    Text:="|<>8ED61E-0.90$19.7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzbzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzDzzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzTzzbzzlzzszzwTzyDzz7zzXzzlzzw"
    if (ok:=FindText(X, Y, 2480-150000, 1060-150000, 2480+150000, 1060+150000, 0, 0, Text)){
    DebugLog("Found auto pilot is already green.")
    return true
    }
}
}

OpponentsVisible() {
    ; reuse the OCR string you already have inside SelectOpponent...
    local hits
    Text :="|<>*151$121.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz..." ; truncated
    return (FindText(X, Y, 1918, 885, 2170, 1345, 0.1, 0.1, Text) != 0)
}

;-----------------------------------------------------------
;  ActionPVP 
;-----------------------------------------------------------
ActionPVP() {
    global PvpTicketChoice, PvpOpponentChoice

    DebugLog("ActionPVP: starting attempt")

    ;==================================================================
    ; STEP 0  –  are we already on the match-ready screen?
    ;==================================================================
    if (!OpponentsVisible()) {

        ;-----------------------------------------------------------
        ; STEP 1 – open PVP lobby
        ;-----------------------------------------------------------
        if (!IsPvpWindowOpen()) {
            if (!ClickPVPButton()) {
                DebugLog("    PVP button not found -> retry")
                return "retry"
            }
            Sleep, 500
        }

        ;-----------------------------------------------------------
        ; STEP 2 – set ticket count
        ;-----------------------------------------------------------
        if (!EnsureCorrectTicketsSelected(PvpTicketChoice)) {
            Send, {Esc}
            Sleep, 500
            return "retry"
        }

        ;-----------------------------------------------------------
        ; STEP 3 – click Play
        ;-----------------------------------------------------------
        if (!ClickPvpPlayButton()) {
            Send, {Esc}
            Sleep, 500
            return "retry"
        }

        Sleep, 1000                ; wait for match-ready screen

        ;-----------------------------------------------------------
        ; STEP 4 – out-of-tickets dialog (only appears *after* Play)
        ;-----------------------------------------------------------
        if (CheckOutOfResources()) {
            DebugLog("    out of PVP tickets")
            Send, {Esc}
            Sleep, 500
            return "outofresource"
        }
    }

    ;==================================================================
    ; We are definitely on the match-ready screen now
    ;==================================================================

    ; STEP 5 – select opponent
    if (!SelectOpponentPvpOpponentChoice()) { ; Uses default testMode=false
        DebugLog("    opponent selection failed.. retry")
        Sleep, 800
        return "retry"
    }
    Sleep, 800

    ; STEP 6 – accept match
    if (!ClickPvpAcceptButton()) {
        DebugLog(" accept button not found.. retry")
        return "retry"
    }
    
    ; *** NEW: STEP 7 – Check for Auto Button confirmation, log result, but proceed anyway ***
    Sleep, 500 ; Give a brief moment for the screen transition
    acceptResult := IsAcceptConfirmed() ; Call the function (it loops internally 5 times)
    
    ; Log the result of the check
    DebugLog("ActionPVP: Post-Accept Auto button check result: " . (acceptResult ? "Confirmed" : "Not Confirmed (Proceeding anyway)"))

    ; Proceed regardless of the check outcome
    DebugLog("ActionPVP: Proceeding to monitor state...")
    return "started" 
}



ActionWorldBoss() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionWorldBoss: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionWorldBoss: Executed successfully.")
    return "success"
}

ActionRaid() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionRaid: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionRaid: Executed successfully.")
    return "success"
}

ActionTrials() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionTrials: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionTrials: Executed successfully.")
    return "success"
}

ActionExpedition() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionExpedition: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionExpedition: Executed successfully.")
    return "success"
}

ActionGauntlet() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionGauntlet: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionGauntlet: Executed successfully.")
    return "success"
}

;===========================================
; Navigation Functions (Arrow Clicks & Zone Selection)
;===========================================
ClickRightArrow() {
    Text:="|<>*120$57.z0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzw"
    if (ok := FindText(X, Y, 2128, 891, 2640, 1378, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickRightArrow: Exiting function, sleep 500")
    }
    DebugLog("ClickRightArrow: Right arrow clicked.")
    Sleep, 500
}

ClickLeftArrow() {
    Text:="|<>*133$53.zzzzzzlzzzzzzzzXzzzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzy000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzw00000Dzzs00000TzU000000zz0000001zy0000003zw0000007zs000000Dzk000000TzU000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001zy0000003zw0000007zs000000Dzk000000TzU000000zz0000001zy0000003zzy000007zzw00000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzzy0000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzXzzzzzzzz7zzzzzzzyDzzzzzzzwTzzzzzzzszzzzzzzzlzz"
    if (ok := FindText(X, Y, 592, 742, 1005, 1383, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickLeftArrow: Left arrow clicked.")
    }
    DebugLog("ClickLeftArrow: Exiting function, sleep 500")
    Sleep, 500
}


EnsureCorrectZoneSelected(targetZone) {
    currentZone := DetectCurrentZone()
    attempts := 0

    zoneIndex := {}  
    zoneIndex["Zone1"] := 1
    zoneIndex["Zone2"] := 2
    zoneIndex["Zone3"] := 3
    zoneIndex["Zone4"] := 4
    zoneIndex["Zone5"] := 5
    zoneIndex["Zone6"] := 6
    zoneIndex["Zone7"] := 7
    zoneIndex["Zone8"] := 8
    zoneIndex["Zone9"] := 9
    zoneIndex["Zone10"] := 10
    zoneIndex["Zone11"] := 11
    zoneIndex["Zone12"] := 12
    zoneIndex["Zone13"] := 13
    zoneIndex["Zone14"] := 14
    zoneIndex["Zone15"] := 15
    zoneIndex["Zone16"] := 16
    zoneIndex["Zone17"] := 17
    zoneIndex["Zone18"] := 18
    zoneIndex["Zone19"] := 19
    zoneIndex["Zone20"] := 20

    while (currentZone != targetZone) {
        if (currentZone = "")
            DebugLog("EnsureCorrectZoneSelected: Unable to detect current zone; retrying.")
        else if (zoneIndex[currentZone] < zoneIndex[targetZone])
            ClickRightArrow()
        else if (zoneIndex[currentZone] > zoneIndex[targetZone])
            ClickLeftArrow()

        Sleep, 500
        currentZone := DetectCurrentZone()
        attempts++
        if (attempts > 20) {
            DebugLog("EnsureCorrectZoneSelected: Failed to select " . targetZone . " after 20 attempts.")
            return false
        }
    }
    DebugLog("EnsureCorrectZoneSelected: Desired zone selected: " . targetZone)
    return true
}

DetectCurrentZone() {
    zone1Pattern := "|<>*147$489.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000Tzy00zzzzzzU0Dzzzzzzw000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz0000001zk07zU000000zzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz0000001zk07zU000000zzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz00Tzs01zk07zzzk03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs01zz0Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00Tzk03zk07zzzzzw01zzzzzzU07zzzzzs01zz00Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzs000000Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzs000000Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs03zz0Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00Tzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00Tzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzs01zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty00zzzzzzU07zzzzzw01zzzzzzzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz0000001zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty0000003zU000000zw0000007zzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz0000001zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty0000003zU000000zw0000007zzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzU07zzzk07zz00Tzy000003zzk00000zzw000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzk07zzzk07zz00Tzz000003zzk00000zzy000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzk07zzzk07zz00Tzz000003zzk00000zzy000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone2Pattern := "|<>*142$545.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz00Tzzy00zs03zzs0000zzw0000007zzk00000zzw0000TzzzU000000zzzz00007zzzk0001zzzy000007z00Tzw01y00zzzw01zk07zzk0001zzs0000007zzU00001zzs0000zzzz0000001zzzy0000DzzzU0003zzzw00000Dy00zzs03w01zzzs03zU0DzzU0003zzk000000Dzz000003zzk0001zzzy0000003zzzw0000Tzzz00007zzzs00000Tw01zzk07s03zzzk07z00Tzz00007zzU000000Tzy000007zzU0003zzzw0000007zzzs0000zzzy0000Dzzzk00000zs03zzU0Dk07zzzU0Dy00zzy0000Dzz0000000zzw00000Dzz00007zzzs000000Dzzzk0001zzzw0000TzzzU00001zk07zz00TU0Dzzz00Tw01zzw0000Tzy0000001zzs00000Tzy0000Dzzzk000000TzzzU0003zzzs0000zzzz000003zU0Dzy00z00Tzzy00zs03zzk0000zzw0000003zzU00000zzw0000Dzzz0000000Tzzy00007zzzU0000zzzw000007z00Tzw01y00zzzw01zk07zU000000zs0000007z0000001zk000000Ty000000000zs0000007z0000001zs000000Dy00zzs03w01zzzs03zU0Dz0000001zk000000Dy0000003zU000000zw000000001zk000000Dy0000003zk000000Tw01zzk07s03zzzk07z00Ty0000003zU000000Tw0000007z0000001zs000000003zU000000Tw0000007zU000000zs03zzU0Dk07zzzU0Dy00zw0000007z0000000zs000000Dy0000003zk000000007z0000000zs000000Dz0000001zk07zz00TU0Dzzz00Tw01zs000000Dy0000003zk000000Tw0000007zU00000000Dy0000001zk000000Ty0000003zU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00DzzzU0Dzzzzzs01zzU0Dz00Ts03z00Tw00zzk03zU0Dzy00zw01zzzzzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzz00Tzzzzzk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs07zzzzzy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zk0Dzzzzzw01zzk07s03zzzk07z00Ty00zzs03zzzs03zzzw01zzzzzz00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU0Tzzzzzs03zzU0Dk07zzzU0Dy00zw01zzk07zzzk07zzzs03zzzzzy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz00zzzzzzk07zz00TU0Dzzz00Tw01zs03zzU0DzzzU0Dzzzk07zzzzzw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty01zzzzzzU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00TzzzU0Dzzzzzs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw03zzzzzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzz00Dzzzzzk03zy00Ty00zk07y00zs00zzU07z00Dzs01zs01zzzzzy00Tzk03w01zUTs03zU0Dz00Tzw01zzzw01zzzy0000DzzzU000000zw01zU0Dw01zk000000Dy0000003zk00000zzw0000007s03z0zk07z00Ty00zzs03zzzs03zzzw0000Tzzz0000001zs03z00Ts03zU000000Tw0000007zU00001zzs000000Dk07y1zU0Dy00zw01zzk07zzzk07zzzs0000zzzy0000003zk07y00zk07z0000000zs000000Dz000003zzk000000TU0Dw3z00Tw01zs03zzU0DzzzU0Dzzzk0001zzzw0000007zU0Dw01zU0Dy0000001zk000000Ty000007zzU000000z00Ts7y00zs03zk07zz00Tzzz00TzzzU0003zzzs000000Dz00Ts03z00Tw0000003zU000000zw00000Dzz0000001y00zkDw01zk07zU0Dzy00zzzy00zzzz00007zzzk00000Tzy00zk07y00zs0000007z000003zzzs0000Tzy0000003w00000003zU0Dz00Tzw01zzzw01zzzy0000DzzzU00001zzw01zU0Dw01zk000000Dy000007zzzs00000Tw0000007s00000007z00Ty00zzs03zzzs03zzzw0000Tzzz000003zzs03z00Ts03zU000000Tw00000Dzzzk00000zs000000Dk0000000Dy00zw01zzk07zzzk07zzzs0000zzzy000007zzk07y00zk07z0000000zs00000TzzzU00001zk000000TU0000000Tw01zs03zzU0DzzzU0Dzzzk0001zzzw00000DzzU0Dw01zU0Dy0000001zk00000zzzz000003zU000000z00000000zs03zk07zz00Tzzz00TzzzU0003zzzs00000Tzz00Ts03z00Tw0000003zU00001zzzy000007z0000001y00000001zk07zU0Dzy00zzzy00zzzz00Dzzzzzk03y00Tzy00zk07y00zs01zzU07z00Dk03zzzzzzz00Dy00Tzk03w00000003zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dw000zw01zU0Dw01zk07zzU0Dy00zk003zzzzzz00Tw01zzk07s00000007z00Ty00zzs03zzzs03zzzw01zzzzzz00Ts001zs03z00Ts03zU0Dzz00Tw01zU007zzzzzy00zs03zzU0Dk0000000Dy00zw01zzk07zzzk07zzzs03zzzzzy00zk003zk07y00zk07z00Tzy00zs03z000Dzzzzzw01zk07zz00TU0000000Tw01zs03zzU0DzzzU0Dzzzk07zzzzzw01zU007zU0Dw01zU0Dy00zzw01zk07y000Tzzzzzs03zU0Dzy00z00000000zs03zk07zz00Tzzz00TzzzU0Dzzzzzs03z000Dz00Ts03z00Tw01zzs03zU0Dw000zzzzzzk07z00Tzw01y00000001zk07zU0Dzy00zzzy00zzzz00Tzzzzzk07y000Ty00zk07y00zs03zzk07z00Ts001zzzzzzU0Dy00zzs03w000zk003zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zzzzzy00Tw01zzk07s001zU007z00Ty00zzs03zzzs03zzzw0000007z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU000000zs03zzU0Dk003z000Dy00zw01zzk07zzzk07zzzs000000Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz0000001zk07zz00TU007y000Tw01zs03zzU0DzzzU0Dzzzk000000Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty0000003zU0Dzy00z000Dw000zs03zk07zz00Tzzz00TzzzU000000zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw0000007z00Tzw01y000Ts001zk07zU0Dzy00zzzy00zzzz0000001zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs000000Dy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzzz000003zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zk00000zzw01zzk07s03zzzk07z00Ty00zzs03zzzs03zzzzy000007z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU00001zzs03zzU0Dk07zzzU0Dy00zw01zzk07zzzk07zzzzw00000Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz000003zzk07zz00TU0Dzzz00Tw01zs03zzU0DzzzU0Dzzzzs00000Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty000007zzU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00Tzzzzk00000zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw00000Dzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzzzU00001zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs00000Tzy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzzz000003zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zzs03zk00000zzw01zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone3Pattern := "|<>*142$467.zy00zzzzzzzk0001zzw01zzk07zzU00000zs03zzU0Dzz00003zzk07zz00Tzz000003zzk0001zzzzw01zzzzzzzU0003zzs03zzU0Dzz000001zk07zz00Tzy00007zzU0Dzy00zzy000007zzU0003zzzzs03zzzzzzz00007zzk07zz00Tzy000003zU0Dzy00zzw0000Dzz00Tzw01zzw00000Dzz00007zzzzk07zzzzzzy0000DzzU0Dzy00zzw000007z00Tzw01zzs0000Tzy00zzs03zzs00000Tzy0000DzzzzU0Dzzzzzzw0000Tzz00Tzw01zzs00000Dy00zzs03zzk0000zzw01zzk07zzk00000zzw0000Tzzzz00Tzzzzzzs0000zzy00zzs03zzk00000Tw01zzk07zzU0001zzs03zzU0DzzU00001zzs0000zzzzy00zzzzzzzk0000zzw01zzU07zzU00000zs03zzU0Dzz00003zzk07zz00Tzy000003zzk0000zzzzw01zzzzzz0000001zs03z000Dy0000001zk07zz00Tw0000003zU0Dzy00zw0000007z0000001zzzs03zzzzzy0000003zk07y000Tw0000003zU0Dzy00zs0000007z00Tzw01zs000000Dy0000003zzzk07zzzzzw0000007zU0Dw000zs0000007z00Tzw01zk000000Dy00zzs03zk000000Tw0000007zzzU0Dzzzzzs000000Dz00Ts001zk000000Dy00zzs03zU000000Tw01zzk07zU000000zs000000Dzzz00Tzzzzzk000000Ty00zk003zU000000Tw01zzk07z0000000zs03zzU0Dz0000001zk000000Tzzy00zzzzzzU07zy00zw01zU0Dzz00Dzzzzzs03zzU0Dy00Tzs01zk07zz00Ty00zzzzzzU0Dzy00zzzw01zzzzzz00Tzw01zs00000Tzy00zzzzzzk07zz00Tw01zzs03zU0Dzy00zw03zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk00000zzw01zzzzzzU0Dzy00zs03zzk07z00Tzw01zs07zzzzzy00zzs03zzzk07zzzzzw01zzk07zU00001zzs03zzzzzz00Tzw01zk07zzU0Dy00zzs03zk0Dzzzzzw01zzk07zzzU0Dzzzzzs03zzU0Dz000003zzk07zzzzzy00zzs03zU0Dzz00Tw01zzk07zU0Tzzzzzs03zzU0Dzzz00Tzzzzzk07zz00Ty000007zzU0Dzzzzzw01zzk07z00Tzy00zs03zzU0Dz00zzzzzzk07zz00Tzzy00zzzzzzU0Dzy00zw00000Dzz00Tzzzzzs03zzU0Dy00zzw01zk07zz00Ty01zzzzzzU0Dzy00zzzw01zzzzzz00Dzs01zs0000zzzy00Tzzzzzk03zy00Tw00Tzk03zU0Dzy00zw00zzzzzz00Tzw01zzzs03zzzzzy0000003zk0001zzzw0000DzzzU000000zs0000007z00Tzw01zs0000zzzy00zzs03zzzk07zzzzzw0000007zU0003zzzs0000Tzzz0000001zk000000Dy00zzs03zk0001zzzw01zzk07zzzU0Dzzzzzs000000Dz00007zzzk0000zzzy0000003zU000000Tw01zzk07zU0003zzzs03zzU0Dzzz00Tzzzzzk000000Ty0000DzzzU0001zzzw0000007z0000000zs03zzU0Dz00007zzzk07zz00Tzzy00zzzzzzU000000zw0000Tzzz00003zzzs000000Dy0000001zk07zz00Ty0000DzzzU0Dzy00zzzw01zzzzzz0000001zs0000zzzy00007zzzk000000Tw0000003zU0Dzy00zw0000Tzzz00Tzw01zzzs03zzzzzy0000003zk0001zzzw0000DzzzU000000zs0000007z00Ts001zs0000zzzy00zzs03zzzk07zzzzzw0000007zU0003zzzs0000Tzzz0000001zk000000Dy00zk003zk0001zzzw01zzk07zzzU0Dzzzzzs000000Dz00007zzzk0000zzzy0000003zU000000Tw01zU007zU0003zzzs03zzU0Dzzz00Tzzzzzk000000Ty0000DzzzU0001zzzw0000007z0000000zs03z000Dz00007zzzk07zz00Tzzy00zzzzzzU000000zw0000Tzzz00003zzzs000000Dy0000001zk07y000Ty0000DzzzU0Dzy00zzzw01zzzzzz00Dzw01zs0000zzzy00Tzzzzzk03zy00Tw00zzk03zU0Dw00zzw01zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk00000zzw01zzzzzzU0Dzy00zs03zzk07z000003zzs07zzzzzy00zzs03zzzk07zzzzzw01zzk07zU00001zzs03zzzzzz00Tzw01zk07zzU0Dy000007zzk0Dzzzzzw01zzk07zzzU0Dzzzzzs03zzU0Dz000003zzk07zzzzzy00zzs03zU0Dzz00Tw00000DzzU0Tzzzzzs03zzU0Dzzz00Tzzzzzk07zz00Ty000007zzU0Dzzzzzw01zzk07z00Tzy00zs00000Tzz00zzzzzzk07zz00Tzzy00zzzzzzU0Dzy00zw00000Dzz00Tzzzzzs03zzU0Dy00zzw01zk00000zzy01zzzzzzU0Dzy00zzzw01zzzzzz00Tzw01zs00000Tzy00zzzzzzk07zz00Tw01zzs03zU00001zzw03zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk07y00Tzw00zzzzzzU0Dzy00zs03zzk07z00007zzzs03zzzzzy00zzs03zzzk000000Tw01zzk07zU0Dw000zs0000007z00Tzw01zk07zzU0Dy0000Dzzzk000000Tw01zzk07zzzU000000zs03zzU0Dz00Ts001zk000000Dy00zzs03zU0Dzz00Tw0000TzzzU000000zs03zzU0Dzzz0000001zk07zz00Ty00zk003zU000000Tw01zzk07z00Tzy00zs0000zzzz0000001zk07zz00Tzzy0000003zU0Dzy00zw01zU007z0000000zs03zzU0Dy00zzw01zk0001zzzy0000003zU0Dzy00zzzw0000007z00Tzw01zs03z000Dy0000001zk07zz00Tw01zzs03zU0003zzzw0000007z00Tzw01zzzzw00000Dy00zzs03zk07zz00Tzy000003zU0Dzy00zs03zzk07z000Dzzzzzs00000Dy00zzs03zzzzs00000Tw01zzk07zU0Dzy00zzw000007z00Tzw01zk07zzU0Dy000Tzzzzzs00000Tw01zzk07zzzzk00000zs03zzU0Dz00Tzw01zzs00000Dy00zzs03zU0Dzz00Tw000zzzzzzk00000zs03zzU0DzzzzU00001zk07zz00Ty00zzs03zzk00000Tw01zzk07z00Tzy00zs001zzzzzzU00001zk07zz00Tzzzz000003zU0Dzy00zw01zzk07zzU00000zs03zzU0Dy00zzw01zk003zzzzzz000003zU0Dzy00zzzzy000007z00Tzw01zs03zzU0Dzz000001zk07zz00Tw01zzs03zU007zzzzzy000007z00Tzw01zzzzw00000Dy00zzw03zk07zz00Tzz000007zU0Dzy00zw03zzk0Dz000Dzzzzzw00000Dy00zzs03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone4Pattern := "|<>*142$363.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy00007zzzU00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzk00000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw0000007zU000000zs03zzk07z00Tzw01zk000000Dy00zzzzzzk000000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw0000007zU000000zs03zzk07z00Tzw01zk000000Dy00zzzzzzk000000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw00zzk07zU0Dzzzzzs03zzk07z00Tzw01zk03zz00Dy00zzzzzzk07zzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU07zw00zw00zzzzzz00Dzs00zs03zzU0Dy00Dzs01zk07zzzzzy00Tzzzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zw00000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zw00000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zzy0000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU000000zzy000007z0000000zs03z000Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU000000zzy000007z0000000zs03z000Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU07zy00zzzzzzU07z00Dzw00zs03z00Dzy00Tzs01zk07zzzzzy00zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzw00zs03zzk07z00007zzzk07zzU0Dy00Tzzzzzk07zzzzzzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU000000zs03zzk07z00007zzzk07zzU0Dy0000003zk000000TzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU000000zs03zzk07z00007zzzk07zzU0Dy0000003zk000000TzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzk00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzs00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzs00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzs07zU00001zzs03zzk0Dz000Dzzzzs07zzU0Tzz000003zzs00000Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone5Pattern := "|<>*143$373.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU0003zzzw0000Tzzz00007zzzs000000Dzzzk0001zzzw0000TzzzU00001zzzk0001zzzy0000DzzzU0003zzzw0000007zzzs0000zzzy0000Dzzzk00000zzzs0000zzzz00007zzzk0001zzzy0000003zzzw0000Tzzz00007zzzs00000Tzzw0000TzzzU0003zzzs0000zzzz0000001zzzy0000DzzzU0003zzzw00000Dzzy0000Dzzzk0001zzzw0000TzzzU000000zzzz00007zzzk0001zzzy000007zzz00007zzzs0000zzzy0000Dzzzk000000TzzzU0003zzzs0000zzzz000003zzzU0001zzzs0000Tzzz00003zzzk0000007zzzU0001zzzw0000Dzzz000001zzU000000zw0000007z0000001zs000000003zk000000Tw0000007zU000000zzk000000Ty0000003zU000000zw000000001zs000000Dy0000003zk000000Tzs000000Dz0000001zk000000Ty000000000zw0000007z0000001zs000000Dzw0000007zU000000zs000000Dz000000000Ty0000003zU000000zw0000007zy0000003zk000000Tw0000007zU00000000Dz0000001zk000000Ty0000003zz00Dzw01zs03zzU0Dy00Tzs03zk07y00zk07zU0Dzw00zs03zzU0Dz00TzzzzzzU0Dzy00zw01zzk07z00Tzy01zs03z00Ts03zk0Dzz00Tw01zzk07zU0Dzzzzzzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zzs03zk07zzzzzzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zw03zzk07z00Tzw01zs03zzzzzzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Ty01zzs03zU0Dzy00zw01zzzzzzy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0Dz00zzw01zk07zz00Ty00zzzzzzz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zU0Tzy00zs03zzU0Dz00TzzzzzzU07zw00zw00zzU07z00Dzs01zs03z00Ts03zk0Dzz00Tw00zzU07zU07zzzzzzk000000Ty0000003zU000000zw01zU0Dw01zs07zzU0Dy0000003zk0001zzzzs000000Dz0000001zk000000Ty00zk07y00zw03zzk07z0000001zs0000zzzzw0000007zU000000zs000000Dz00Ts03z00Ty01zzs03zU000000zw0000Tzzzy0000003zk000000Tw0000007zU0Dw01zU0Dz00zzw01zk000000Ty0000Dzzzz0000001zs000000Dy0000003zk07y00zk07zU0Tzy00zs000000Dz00007zzzzU000000zw00000Dzz0000001zs03z00Ts03zk0Dzz00Tw00000DzzU0003zzzzk000000Ty000007zzU000000zw01zU0Dw01zs07zzU0Dy000007zzk0001zzzzs000000Dz000003zzk000000Ty00zk07y00zw03zzk07z000003zzs0000zzzzw0000007zU00001zzs000000Dz00Ts03z00Ty01zzs03zU00001zzw0000Tzzzy0000003zk00000zzw0000007zU0Dw01zU0Dz00zzw01zk00000zzy0000Dzzzz0000001zs00000Tzy0000003zk07y00zk07zU0Tzy00zs00000Tzz00007zzzzU07zy00zw00z00Dzz00Dzw01zs03z00Ts03zk0Dzz00Tw00z00DzzU0Dzzzzzzk07zz00Ty00zk003zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zk003zk07zzzzzzs03zzU0Dz00Ts001zk07zzU0Ty00zk07y00zw03zzk07z00Ts001zs03zzzzzzw01zzk07zU0Dw000zs03zzk0Dz00Ts03z00Ty01zzs03zU0Dw000zw01zzzzzzy00zzs03zk07y000Tw01zzs07zU0Dw01zU0Dz00zzw01zk07y000Ty00zzzzzzz00Tzw01zs03z000Dy00zzw03zk07y00zk07zU0Tzy00zs03z000Dz00TzzzzzzU0Dzy00zw01zU007z00Tzy01zs03z00Ts03zk0Dzz00Tw01zU007zU0Dzzzzzzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zs03zz00Dy00zzs03zk07zzzzzzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zw0000007z00Tzw01zs000000Dzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Ty0000003zU0Dzy00zw0000007zy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0Dz0000001zk07zz00Ty0000003zz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zU000000zs03zzU0Dz0000001zzU0Dzy00zw01zzk07z00Tzy01zs03z00Ts03zk000000Tw01zzk07zU000000zzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zzs0000Tzy00zzs03zzk00000Tzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zzy0000Dzz00Tzw01zzw00000Dzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Tzz00007zzU0Dzy00zzy000007zy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0DzzU0003zzk07zz00Tzz000003zz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zzk0001zzs03zzU0DzzU00001z"
    zone6Pattern := "|<>*142$461.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zzzU0DzzU0003zzzs0000zzzz000003zzk0000zzzy0000Dzzzk0001zzs000000Dz00Tzw01zU0Dzzz00Tzz00007zzzk0001zzzy000007zzU0001zzzw0000TzzzU0003zzk000000Ty00zzs03z00Tzzy00zzy0000DzzzU0003zzzw00000Dzz00003zzzs0000zzzz00007zzU000000zw01zzk07y00zzzw01zzw0000Tzzz00007zzzs00000Tzy00007zzzk0001zzzy0000Dzz0000001zs03zzU0Dw01zzzs03zzs0000zzzy0000Dzzzk00000zzw0000DzzzU0003zzzw0000Tzy0000003zk07zz00Ts03zzzk07zzk0001zzzw0000TzzzU00001zzs0000Tzzz00007zzzs0000zzw0000007zU0Dzy00zk03zzzU0Dzz00003zzzs0000Tzzy000003zzk0000zzzw00007zzzU0001zzs000000Dz00Tzw01zU007y000Ty0000003zU000000Tw0000007z0000000zs000000Dz0000001zk000000Ty00zzs03z000Dw000zw0000007z0000000zs000000Dy0000001zk000000Ty0000003zU000000zw01zzk07y000Ts001zs000000Dy0000001zk000000Tw0000003zU000000zw0000007z0000001zs03zzU0Dw000zk003zk000000Tw0000003zU000000zs0000007z0000001zs000000Dy0000003zk07zz00Ts001zU007zU000000zs0000007z0000001zk000000Dy0000003zk000000Tw0000007zU0Dzy00zk001z000Dz00Tzw01zk03zz00Dy00zzzzzzU07zy00Tw01zzk07zU0Dzw00zzzy00zzzz00Tzw01zU0000000Ty00zzs03zU0Dzz00Tw01zzzzzz00Tzy00zs03zzU0Dz00zzw01zzzw01zzzy00zzs03z00000000zw01zzk07z00Tzy00zs03zzzzzy00zzw01zk07zz00Ty01zzs03zzzs03zzzw01zzk07y00000001zs03zzU0Dy00zzw01zk07zzzzzw01zzs03zU0Dzy00zw03zzk07zzzk07zzzs03zzU0Dw00000003zk07zz00Tw01zzs03zU0Dzzzzzs03zzk07z00Tzw01zs07zzU0DzzzU0Dzzzk07zz00Ts00000007zU0Dzy00zs03zzk07z00Tzzzzzk07zzU0Dy00zzs03zk0Dzz00Tzzz00TzzzU0Dzy00zk0000000Dz00Tzw01zk07zzU0Dy00zzzzzzU0Dzz00Tw01zzk07zU0Tzy00zzzy00zzzz00Tzw01zU0000000Ty00zzs03zU07zw00Tw01zzzzzz00Tzy00zs01zz00Dz00zzw01zzzw01zzzy00Tzk03z00000000zw01zzk07z0000000zs03z000Dy00zzw01zk000000Ty01zzs03zzzs03zzzw0000007y00000001zs03zzU0Dy0000001zk07y000Tw01zzs03zU000000zw03zzk07zzzk07zzzs000000Dw00000003zk07zz00Tw0000003zU0Dw000zs03zzk07z0000001zs07zzU0DzzzU0Dzzzk000000Ts00000007zU0Dzy00zs0000007z00Ts001zk07zzU0Dy0000003zk0Dzz00Tzzz00TzzzU000000zk0000000Dz00Tzw01zk000000Dy00zk003zU0Dzz00Tw0000007zU0Tzy00zzzy00zzzz0000001zU07w1z00Ty00zzs03zU00000zzw01zU007z00Tzy00zs00000Tzz00zzw01zzzw01zzzy0000003z00Ts7y00zw01zzk07z000003zzs03z000Dy00zzw01zk00000zzy01zzs03zzzs03zzzw0000007y00zkDw01zs03zzU0Dy000007zzk07y000Tw01zzs03zU00001zzw03zzk07zzzk07zzzs000000Dw01zUTs03zk07zz00Tw00000DzzU0Dw000zs03zzk07z000003zzs07zzU0DzzzU0Dzzzk000000Ts03z0zk07zU0Dzy00zs00000Tzz00Ts001zk07zzU0Dy000007zzk0Dzz00Tzzz00TzzzU000000zk07y1zU0Dz00Tzw01zk00000zzy00zk003zU0Dzz00Tw00000DzzU0Tzy00zzzy00zzzz0000001zU0Dzzz00Ty00zzs03zU07w00zzw01zzU07z00Tzy00zs01y00Tzz00zzw01zzzw01zzzy00zzk03z00Tzzy00zw01zzk07z00Ts000zs03zzU0Dy00zzw01zk07y000Ty01zzs03zzzs03zzzw01zzk07y00zzzw01zs03zzU0Dy00zk001zk07zz00Tw01zzs03zU0Dw000zw03zzk07zzzk07zzzs03zzU0Dw01zzzs03zk07zz00Tw01zU003zU0Dzy00zs03zzk07z00Ts001zs07zzU0DzzzU0Dzzzk07zz00Ts03zzzk07zU0Dzy00zs03z0007z00Tzw01zk07zzU0Dy00zk003zk0Dzz00Tzzz00TzzzU0Dzy00zk07zzzU0Dz00Tzw01zk07y000Dy00zzs03zU0Dzz00Tw01zU007zU0Tzy00zzzy00zzzz00Tzw01zU0Dzzz00Ty00zzs03zU0Dw000Tw01zzk07z00Tzy00zs03z000Dz00zzw01zzzw01zzzy00zzs03z00Tzzy00zw00zzU07z00Tzw00zs01zz00Dy00Tzs01zk07zz00Ty00zzk03zzzs03zzzw01zzk07y00zzzw01zs000000Dy00zzw01zk000000Tw0000003zU0Dzy00zw0000007zzzk07zzzs03zzU0Dw01zzzs03zk000000Tw01zzs03zU000000zs0000007z00Tzw01zs000000DzzzU0Dzzzk07zz00Ts03zzzk07zU000000zs03zzk07z0000001zk000000Dy00zzs03zk000000Tzzz00TzzzU0Dzy00zk07zzzU0Dz0000001zk07zzU0Dy0000003zU000000Tw01zzk07zU000000zzzy00zzzz00Tzw01zU0Dzzz00Ty0000003zU0Dzz00Tw0000007z0000000zs03zzU0Dz0000001zzzw01zzzy00zzs03z00Tzzy00zzy0000Dzz00Tzy00zzw0000Tzzz00003zzk07zz00Tzy00007zzzzs03zzzw01zzk07y00zzzw01zzw0000Tzy00zzw01zzs0000zzzy00007zzU0Dzy00zzy0000Dzzzzk07zzzs03zzU0Dw01zzzs03zzs0000zzw01zzs03zzk0001zzzw0000Dzz00Tzw01zzw0000TzzzzU0Dzzzk07zz00Ts03zzzk07zzk0001zzs03zzk07zzU0003zzzs0000Tzy00zzs03zzs0000zzzzz00TzzzU0Dzy00zk07zzzU0DzzU0003zzk07zzU0Dzz00007zzzk0000zzw01zzk07zzk0001zzzzy00zzzz00Tzw01zU0Dzzz00Tzz00007zzU0Dzz00Tzy0000DzzzU0001zzs03zzU0DzzU0003zzzzw01zzzy00zzs03z00Tzzz00zzy0000Dzz00Tzy01zzw0000TzzzU0007zzk07zz00Tzz0000Dzzzzs03zzzw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    zone7Pattern := "|<>*144$373.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw00000DzzU0003zzzs000000DzzU00001zzzy0000DzzzU0003zzzw0000Tzzzy000003zzk0001zzzw0000007zzk00000zzzz00007zzzk0001zzzy0000Dzzzz000001zzs0000zzzy0000003zzs00000TzzzU0003zzzs0000zzzz00007zzzzU00000zzw0000Tzzz0000001zzw00000Dzzzk0001zzzw0000TzzzU0003zzzzk00000Tzy0000DzzzU000000zzy000007zzzs0000zzzy0000Dzzzk0001zzzzs00000Dzz00007zzzk000000Tzz000003zzzw0000Tzzz00007zzzs0000zzzzw000007zz00003zzzs0000007zzU00000zzzw0000DzzzU0001zzzs0000Tzzw0000003zU000000zs000000001zk000000Ty0000003zU000000zw0000007zy0000001zk000000Tw000000000zs000000Dz0000001zk000000Ty0000003zz0000000zs000000Dy000000000Tw0000007zU000000zs000000Dz0000001zzU000000Tw0000007z000000000Dy0000003zk000000Tw0000007zU000000zzk000000Dy0000003zU000000007z0000001zs000000Dy0000003zk000000Tzs01zzzzzz00Tzw01zk03y00Tk03zU0Dzy00zw01zzU07z00Tzw01zs03zz00Dzw01zzzzzzU0Dzy00zs03z00Tw01zk07zz00Ty01zzs03zU0Dzy00zw03zzk07zy00zzzzzzk07zz00Tw01zU0Dy00zs03zzU0Dz00zzw01zk07zz00Ty01zzs03zz00Tzzzzzs03zzU0Dy00zk07z00Tw01zzk07zU0Tzy00zs03zzU0Dz00zzw01zzU0Dzzzzzw01zzk07z00Ts03zU0Dy00zzs03zk0Dzz00Tw01zzk07zU0Tzy00zzk07zzzzzy00zzs03zU0Dw01zk07z00Tzw01zs07zzU0Dy00zzs03zk0Dzz00Tzs03zzzzzz00Tzw01zk07y00zs03zU0Dzy00zw03zzk07z00Tzw01zs07zzU0Dzw01zzzzzzU07zw00zs03z00Tw01zk03zy00Ty01zzs03zU07zw00zw00zzU07zy00zzzzzzk000000Tw01zU0Dy00zs000000Dz00zzw01zk000000Ty0000003zz00Tzzzzzs000000Dy00zk07z00Tw0000007zU0Tzy00zs000000Dz0000001zzU0Dzzzzzw0000007z00Ts03zU0Dy0000003zk0Dzz00Tw0000007zU000000zzk07zzzzzy0000003zU0Dw01zk07z0000001zs07zzU0Dy0000003zk000000Tzs03zzzzzz0000001zk07y00zs03zU000000zw03zzk07z0000001zs000000Dzw01zzzzzzU000000zs03z00Tw01zk000000Ty01zzs03zU00001zzw0000007zy00zzzzzzk000000Tw01zU0Dy00zs000000Dz00zzw01zk00000zzy0000003zz00Tzzzzzs000000Dy00zk07z00Tw0000007zU0Tzy00zs00000Tzz0000001zzU0Dzzzzzw0000007z00Ts03zU0Dy0000003zk0Dzz00Tw00000DzzU000000zzk07zzzzzy0000003zU0Dw01zk07z0000001zs07zzU0Dy000007zzk000000Tzs03zzzzzz0000001zk07y00zs03zU000000zw03zzk07z000003zzs000000Dzw01zzzzzzU07zw00zs03z00Tw01zk03zy00Ty01zzs03zU07s01zzw01zzU07zy00zzzzzzk07zz00Tw01zU0Dy00zs03zzU0Dz00zzw01zk07y000Ty01zzs03zz00Tzzzzzs03zzU0Dy00zk07z00Tw01zzk07zU0Tzy00zs03z000Dz00zzw01zzU0Dzzzzzw01zzk07z00Ts03zU0Dy00zzs03zk0Dzz00Tw01zU007zU0Tzy00zzk07zzzzzy00zzs03zU0Dw01zk07z00Tzw01zs07zzU0Dy00zk003zk0Dzz00Tzs03zzzzzz00Tzw01zk07y00zs03zU0Dzy00zw03zzk07z00Ts001zs07zzU0Dzw01zzzzzzU0Dzy00zs03z00Tw01zk07zz00Ty01zzs03zU0Dw000zw03zzk07zy00Tzzzzzk07zz00Tw01zU0Dy00zs01zz00Dz00Tzs01zk07zz00Ty01zzs03zz0000000zs03zzU0Dy00zk07z00Tw0000007zU000000zs03zzU0Dz00zzw01zzU000000Tw01zzk07z00Ts03zU0Dy0000003zk000000Tw01zzk07zU0Tzy00zzk000000Dy00zzs03zU0Dw01zk07z0000001zs000000Dy00zzs03zk0Dzz00Tzs0000007z00Tzw01zk07y00zs03zU000000zw0000007z00Tzw01zs07zzU0Dzw0000003zU0Dzy00zs03z00Tw01zk000000Ty0000003zU0Dzy00zw03zzk07zzz000001zk07zz00Tw01zU0Dy00zs00000Tzzz00003zzk07zz00Ty01zzs03zzzU00000zs03zzU0Dy00zk07z00Tw00000Dzzzk0001zzs03zzU0Dz00zzw01zzzk00000Tw01zzk07z00Ts03zU0Dy000007zzzs0000zzw01zzk07zU0Tzy00zzzs00000Dy00zzs03zU0Dw01zk07z000003zzzw0000Tzy00zzs03zk0Dzz00Tzzw000007z00Tzw01zk07y00zs03zU00001zzzy0000Dzz00Tzw01zs07zzU0Dzzy000003zU0Dzy00zs03z00Tw01zk00000zzzz00007zzU0Dzy00zw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    zone8Pattern := "|<>*143$347.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs00000Tzz00007zzU0Dzzzzzzy0000Dzzzk0001zzzw0000TzzzU0003zzk00000zzy0000Dzz00Tzzzzzzw0000TzzzU0003zzzs0000zzzz00007zzU00001zzw0000Tzy00zzzzzzzs0000zzzz00007zzzk0001zzzy0000Dzz000003zzs0000zzw01zzzzzzzk0001zzzy0000DzzzU0003zzzw0000Tzy000007zzk0001zzs03zzzzzzzU0003zzzw0000Tzzz00007zzzs0000zzw00000DzzU0003zzk07zzzzzzz00007zzzs0000zzzy0000Dzzzk0001zzs00000Tzy00007zzU0Dzzzzzzw00007zzzU0001zzzs0000Dzzz00003zk000000zw0000007z00Tzzzzzs000000Dy0000001zk000000Ty0000003U000001zs000000Dy00zzzzzzk000000Tw0000003zU000000zw00000070000003zk000000Tw01zzzzzzU000000zs0000007z0000001zs000000C0000007zU000000zs03zzzzzz0000001zk000000Dy0000003zk000000Q000000Dz0000001zk07zzzzzy0000003zU000000Tw0000007zU000000s03zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Dzw00zs03zzU0Dz00Tzs01k0Dzzzzzw01zzk07z00Tzzzzzs03zzU0Dy00zzw01zk07zz00Ty01zzs03U0Tzzzzzs03zzU0Dy00zzzzzzk07zz00Tw01zzs03zU0Dzy00zw03zzk0700zzzzzzk07zz00Tw01zzzzzzU0Dzy00zs03zzk07z00Tzw01zs07zzU0C01zzzzzzU0Dzy00zs03zzzzzz00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Q03zzzzzz00Tzw01zk07zzzzzy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00s07zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Tzy00zs03zzU0Dz00zzw01k0Dzzzzzw00zzU07z00Tzzzzzs01zz00Dy00Tzs01zk03zy00Ty01zzs03U0Ts001zs000000Dy00zzzzzzk000000Tw0000003zU000000zw03zzk0700zk003zk000000Tw01zzzzzzU000000zs0000007z0000001zs07zzU0C01zU007zU000000zs03zzzzzz0000001zk000000Dy0000003zk0Dzz00Q03z000Dz0000001zk07zzzzzy0000003zU000000Tw0000007zU0Tzy00s07y000Ty0000003zU0Dzzzzzw0000007z0000000zs000000Dz00zzw01k0Dw000zw0000007z00Tzzzzzs000000Dy000003zzk000000Ty01zzs03U0Ts001zs000000Dy00zzzzzzk000000Tw00000DzzU000000zw03zzk0700zk003zk000000Tw01zzzzzzU000000zs00000Tzz0000001zs07zzU0C01zU007zU000000zs03zzzzzz0000001zk00000zzy0000003zk0Dzz00Q03z000Dz0000001zk07zzzzzy0000003zU00001zzw0000007zU0Tzy00s07y000Ty0000003zU0Dzzzzzw0000007z000003zzs000000Dz00zzw01k0Dzy00zw00zzU07z00Tzzzzzs01zz00Dy00Tk03zzk03zy00Ty01zzs03U0Tzy01zs03zzU0Dy00zzzzzzk07zz00Tw01zk003zU0Dzy00zw03zzk0700zzw03zk07zz00Tw01zzzzzzU0Dzy00zs03zU007z00Tzw01zs07zzU0C01zzs07zU0Dzy00zs03zzzzzz00Tzw01zk07z000Dy00zzs03zk0Dzz00Q03zzk0Dz00Tzw01zk07zzzzzy00zzs03zU0Dy000Tw01zzk07zU0Tzy00s07zzU0Ty00zzs03zU0Dzzzzzw01zzk07z00Tw000zs03zzU0Dz00zzw01k0Dzz00zw01zzk07z00Tzzzzzs03zzU0Dy00zs001zk07zz00Ty01zzs03U0Dzw01zs03zzU0Dy00Tzzzzzk07zz00Tw01zzk03zU0Dzy00zw03zzk070000003zk07zz00Tw0000003zU0Dzy00zs03zzk07z00Tzw01zs07zzU0C0000007zU0Dzy00zs0000007z00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Q000000Dz00Tzw01zk000000Dy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00s000000Ty00zzs03zU000000Tw01zzk07z00Tzy00zs03zzU0Dz00zzw01k000000zw01zzk07z0000000zs03zzU0Dy00zzw01zk07zz00Ty01zzs03zU00001zs03zzU0Dzz000001zk07zz00Tw01zzs03zU0Dzy00zw03zzk07z000003zk07zz00Tzy000003zU0Dzy00zs03zzk07z00Tzw01zs07zzU0Dy000007zU0Dzy00zzw000007z00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Tw00000Dz00Tzw01zzs00000Dy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00zs00000Ty00zzs03zzk00000Tw01zzk07z00Tzy00zs03zzU0Dz00zzw01zk00000zw01zzk07zzU00000zs03zzU0Dy00zzw01zk07zz00Ty01zzs03zU00001zs03zzU0DzzU00003zk07zz00Ty01zzs07zU0Dzy00zw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone9Pattern := "|<>*143$307.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy000007zzU00001zs03zzU0Dy00zzzzzzk07zz00Tzy0000Dzzzz000003zzk00000zw01zzk07z00Tzzzzzs03zzU0Dzz00007zzzzU00001zzs00000Ty00zzs03zU0Dzzzzzw01zzk07zzU0003zzzzk00000zzw00000Dz00Tzw01zk07zzzzzy00zzs03zzk0001zzzzs00000Tzy000007zU0Dzy00zs03zzzzzz00Tzw01zzs0000zzzzw00000Dzz000003zk07zz00Tw01zzzzzzU0Dzy00zzw0000Tzzzw000007zzU00001zs03zzU0Dy00zzzzzzk07zz00Tzy00007zzy0000003zU000000zw01zzk07z00Tzzzzzs03zzU0Dy0000003zz0000001zk000000Ty00zzs03zU0Dzzzzzw01zzk07z0000001zzU000000zs000000Dz00Tzw01zk07zzzzzy00zzs03zU000000zzk000000Tw0000007zU0Dzy00zs03zzzzzz00Tzw01zk000000Tzs000000Dy0000003zk07zz00Tw01zzzzzzU0Dzy00zs000000Dzw01zzzzzz00Dzzzzzs03zzU0Dy00zzzzzzk07zz00Tw00zzk07zy00zzzzzzU0Dzzzzzw01zzk07z00Tzzzzzs03zzU0Dy00zzs03zz00Tzzzzzk07zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Tzw01zzU0Dzzzzzs03zzzzzz00Tzw01zk07zzzzzy00zzs03zU0Dzy00zzk07zzzzzw01zzzzzzU0Dzy00zs03zzzzzz00Tzw01zk07zz00Tzs03zzzzzy00zzzzzzk07zz00Tw01zzzzzzU0Dzy00zs03zzU0Dzw01zzzzzz00Tzzzzzs03zzU0Dy00zzzzzzk07zz00Tw01zzk07zy00TzzzzzU07zzzzzw00zzU07z00Tzzzzzs01zz00Dy00zzs03zz00007zzzk00000zzy0000003zU0Dzzzzzw0000007z00Tzw01zzU0003zzzs00000Tzz0000001zk07zzzzzy0000003zU0Dzy00zzk0001zzzw00000DzzU000000zs03zzzzzz0000001zk07zz00Tzs0000zzzy000007zzk000000Tw01zzzzzzU000000zs03zzU0Dzw0000Tzzz000003zzs000000Dy00zzzzzzk000000Tw01zzk07zy0000Dzzzzk0000zzw0000007z00Tzzzzzzs0000Tzy00zzs03zz00007zzzzs00000Ty0000003zU0Dzzzzzzy0000Dzz00Tzw01zzU0003zzzzw00000Dz0000001zk07zzzzzzz00007zzU0Dzy00zzk0001zzzzy000007zU000000zs03zzzzzzzU0003zzk07zz00Tzs0000zzzzz000003zk000000Tw01zzzzzzzk0001zzs03zzU0Dzw0000TzzzzU00001zs000000Dy00zzzzzzzs0000zzw01zzk07zy00zzzzzzzzzzy00zw01zzU07z00Tzzzzzzzw00zzzy00zzs03zz00Tzzzzzzzzzz00Ty00zzs03zU0Dzzzzzzzz00Tzzz00Tzw01zzU0DzzzzzzzzzzU0Dz00Tzw01zk07zzzzzzzzU0DzzzU0Dzy00zzk07zzzzzzzzzzk07zU0Dzy00zs03zzzzzzzzk07zzzk07zz00Tzs03zzzzzzzzzzs03zk07zz00Tw01zzzzzzzzs03zzzs03zzU0Dzw01zzzzzzzzzzw01zs03zzU0Dy00zzzzzzzzw01zzzw01zzk07zy00zzzzzzzzzzy00zw01zzk07z00Tzzzzzzzy00zzzy00zzs03zz00Tzzzzzzzzzz00Ty00zzs03zU07zzzzzzzz00Tzzz00Tzw01zzU000000zs000000Dz00Tzw01zk000000TzzzU0DzzzU0Dzy00zzk000000Tw0000007zU0Dzy00zs000000Dzzzk07zzzk07zz00Tzs000000Dy0000003zk07zz00Tw0000007zzzs03zzzs03zzU0Dzw0000007z0000001zs03zzU0Dy0000003zzzw01zzzw01zzk07zy0000003zU000000zw01zzk07z0000001zzzy00zzzy00zzs03zzz000001zk00000Tzy00zzs03zzk00000zzzz00Tzzz00Tzw01zzzk00000zs00000Tzz00Tzw01zzs00000TzzzU0DzzzU0Dzy00zzzs00000Tw00000DzzU0Dzy00zzw00000Dzzzk07zzzk07zz00Tzzw00000Dy000007zzk07zz00Tzy000007zzzs03zzzs03zzU0Dzzy000007z000003zzs03zzU0Dzz000003zzzw01zzzw01zzk07zzz000003zU00001zzw01zzk07zzU00001zzzy00zzzy00zzs03zzzU00001zk00000zzy00zzs03zzk00000zzzz00Tzzz00Tzw01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone10Pattern := "|<>*140$265.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zz00Tzy0000Dzzzk000000TzzzU0003zzzs0000zzs03zzU0Dzz00007zzzs000000Dzzzk0001zzzw0000Tzw01zzk07zzU0003zzzw0000007zzzs0000zzzy0000Dzy00zzs03zzk0001zzzy0000003zzzw0000Tzzz00007zz00Tzw01zzs0000zzzz0000001zzzy0000DzzzU0003zzU0Dzy00zzw0000TzzzU000000zzzz00007zzzk0001zzk07zz00Tzy00007zzzU000000Dzzz00003zzzk0000Tzs03zzU0Dy0000003zk000000007z0000000zs000000Dw01zzk07z0000001zs000000003zU000000Tw0000007y00zzs03zU000000zw000000001zk000000Dy0000003z00Tzw01zk000000Ty000000000zs0000007z0000001zU0Dzy00zs000000Dz000000000Tw0000003zU000000zk07zz00Tw00zzk07zU0Dw01zU0Dy00Tzs01zk07zz00Ts03zzU0Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dw01zzk07z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07y00zzs03zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03z00Tzw01zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zU0Dzy00zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zk07zz00Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ts03zzU0Dy00Tzk03zk07y00zk07z00Tzy00zs01zz00Dw01zzk07z0000001zs03z00Ts03zU0Dzz00Tw0000007y00zzs03zU000000zw01zU0Dw01zk07zzU0Dy0000003z00Tzw01zk000000Ty00zk07y00zs03zzk07z0000001zU0Dzy00zs000000Dz00Ts03z00Tw01zzs03zU000000zk07zz00Tw0000007zU0Dw01zU0Dy00zzw01zk000000Ts03zzU0Dy0000003zk07y00zk07z00Tzy00zs00000Tzw01zzk07z0000001zs03z00Ts03zU0Dzz00Tw00000Dzy00zzs03zU000000zw01zU0Dw01zk07zzU0Dy000007zz00Tzw01zk000000Ty00zk07y00zs03zzk07z000003zzU0Dzy00zs000000Dz00Ts03z00Tw01zzs03zU00001zzk07zz00Tw0000007zU0Dw01zU0Dy00zzw01zk00000zzs03zzU0Dy00Tzs03zk07y00zk07z00Tzy00zs01y00Tzw01zzk07z00Tzw01zs03z00Ts03zU0Dzz00Tw01zU007y00zzs03zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zk003z00Tzw01zk07zz00Ty00zk07y00zs03zzk07z00Ts001zU0Dzy00zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dw000zk07zz00Tw01zzk07zU0Dw01zU0Dy00zzw01zk07y000Ts03zzU0Dy00zzs03zk07y00zk07z00Tzy00zs03z000Dw00zzU07z00Tzw01zs03z00Ts03zU07zy00Tw01zzk07y0000003zU0Dzy00zw01zU0Dw01zk000000Dy00zzs03z0000001zk07zz00Ty00zk07y00zs0000007z00Tzw01zU000000zs03zzU0Dz00Ts03z00Tw0000003zU0Dzy00zk000000Tw01zzk07zU0Dw01zU0Dy0000001zk07zz00Ts000000Dy00zzs03zk07y00zk07z0000000zs03zzU0Dzy0000Dzz00Tzw01zs03z00Ts03zzk0000zzw01zzk07zz00007zzU0Dzy00zw01zU0Dw01zzw0000Tzy00zzs03zzU0003zzk07zz00Ty00zk07y00zzy0000Dzz00Tzw01zzk0001zzs03zzU0Dz00Ts03z00Tzz00007zzU0Dzy00zzs0000zzw01zzk07zU0Dw01zU0DzzU0003zzk07zz00Tzw0000Tzy00zzs03zk07y00zk07zzk0001zzs03zzU0Dzy0000Dzz00Tzy01zs03z00Ts03zzs0000zzw01zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    zone11Pattern := "|<>*146$183.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0Dzzw07zz00000zk0Tzzzzw03zy03z01zzzU0zzs00007y03zzzzzU0Tzk0Ts0Dzzw07zz00000zk0Tzzzzw03zy03z01zzzU0zzs00007y03zzzzzU0Tzk0Ts0Dzzw07zz00000zk0Tzzzzw03zy03z001zU00zs000007y03zzzzzU0Tzk0Ts00Dw007z000000zk0Tzzzzw03zy03z001zU00zs000007y03zzzzzU0Tzk0Ts00Dw007z000000zk0Tzzzzw03zy03z001zU00zs000007y03zzzzzU0Tzk0Ts007w007z01zzzzzk0Tzzzzw03zy03z0000000zs0Dzzzzy03zzzzzU0Tzk0Ts0000007z01zzzzzk0Tzzzzw03zy03z0000000zs0Dzzzzy03zzzzzU0Tzk0Ts0000007z01zzzzzk0Tzzzzw03zy03z0000000zs0Dzzzzy03zzzzzU0Tzk0Ts0000007z01zzzzzk0Tzzzzw03zy03z0000000zs000Dzzy03zzzzzU0Tzk0Ts0000007z0001zzzk0Tzzzzw03zy03z0000000zs000Dzzy03zzzzzU0Tzk0Ts0000007z0001zzzk0Tzzzzw03zy03z00z0z00zs000Dzzy03zzzzzU0Tzk0Ts0Ds7w07z0001zzzk0Tzzzzw03y003z01z0zU0zs000Dzzy03zzzzzU0Tk00Ts0Ds7w07z0001zzzk0Tzzzzw03y003z01z0zU0zs000Dzzy03zzzzzU0Tk00Ts0Ds7w07z0001zzzk0Tzzzzw03y003z01zzzU0zs0Dzzzzy03zzzzzU0Tk0Tzs0Dzzw07z01zzzzzk0Tzzzzw00003zz01zzzU0zs0Dzzzzy03zzzzzU0000Tzs0Dzzw07z01zzzzzk0Tzzzzw00003zz01zzzU0zs0Dzzzzy03zzzzzU0000Tzs0Dzzw07z01zzzzzk0Tzzzzw00003zz01zzzU0zs07zzzzy01zzzzzU000Tzzs0Dzzw07z000000zk00000Dw0003zzz01zzzU0zs000007y000001zU000Tzzs0Dzzw07z000000zk00000Dw0003zzz01zzzU0zs000007y000001zU000Tzzs0Dzzw07zy00000zzk0000Dw003zzzz01zzzU0zzs00007zy00001zU00Tzzzs0Dzzw07zz00000zzk0000Dw003zzzz01zzzU0zzs00007zy00001zU00Tzzzs0Dzzw07zz00000zzk0000Dw003zzzz01zzzU0zzs00007zy00001zU00Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone12Pattern := "|<>*140$201.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU000000zzw0000TzzzU0003zzk00000Tzw0000007zzU0003zzzw0000Tzy000003zzU000000zzw0000TzzzU0003zzk00000Tzw0000007zzU0003zzzw0000Tzy000003zzU000000zzw0000TzzzU0003zzk00000Tzw0000007zzU0003zzzw0000Tzy000003zzU000000zzw0000Dzzz00001zzk00000Tzw0000007z0000001zs000000Dy0000001zU000000zs000000Dz0000001zk000000Dw0000007z0000001zs000000Dy0000001zU000000zs000000Dz0000001zk000000Dw0000007z0000001zs000000Dy0000001zzzzw000zs01zzU0Dz00Tzw01zk03zz00DzzzzU007z00Tzw01zs03zzU0Dy00zzw01zzzzw000zs03zzU0Dz00Tzw01zk07zzU0DzzzzU007z00Tzw01zs03zzU0Dy00zzw01zzzzw000zs03zzU0Dz00Tzw01zk07zzU0DzzzzU007z00Tzw01zs03zzU0Dy00zzw01zzzzw000zs03zzU0Dz00Tzw01zk07zzU0Dzzzz00Dzz00Tzw01zs01zz00Dy00zzw01zzzs001zzs03zzU0Dz0000001zk07zzU0Dzzz000Dzz00Tzw01zs000000Dy00zzw01zzzs001zzs03zzU0Dz0000001zk07zzU0Dzzz000Dzz00Tzw01zs000000Dy00zzw01zzzs001zzs03zzU0Dz0000001zk07zzU0Dzzy00Tzzz00Tzw01zs00000Tzy00zzw01zzk003zzzs03zzU0Dz000003zzk07zzU0Dzy000Tzzz00Tzw01zs00000Tzy00zzw01zzk003zzzs03zzU0Dz000003zzk07zzU0Dzy000Tzzz00Tzw01zs00000Tzy00zzw01zzk003zzzs03zzU0Dz000003zzk07zzU0Dzy00Tzzzz00Tzw01zs01y00Tzy00zzw01zU007zzzzs03zzU0Dz00Ts001zk07zzU0Dw000zzzzz00Tzw01zs03z000Dy00zzw01zU007zzzzs03zzU0Dz00Ts001zk07zzU0Dw000zzzzz00Tzw01zs03z000Dy00zzw01zU007zzzzs03zzU0Dz00Ts001zk07zzU0Dw000zzzzz00Tzw01zs03z000Dy00zzw01zU003zzzzs01zzU0Dz00Tzw01zk03zz00Dw0000007z0000001zs03zzU0Dy0000001zU000000zs000000Dz00Tzw01zk000000Dw0000007z0000001zs03zzU0Dy0000001zU000000zs000000Dz00Tzw01zk000000Dw0000007z0000001zs03zzU0Dy0000001zU000000zzw0000Dzz00Tzw01zk00000Tzw0000007zzU0003zzs03zzU0Dy000003zzU000000zzw0000Tzz00Tzw01zk00000Tzw0000007zzU0003zzs03zzU0Dy000003zzU000000zzw0000Tzz00Tzw01zk00000Tzw0000007zzU0003zzs03zzU0Dy000003zzU000000zzw0000Tzz00Tzw01zk00000zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone13Pattern := "|<>*143$277.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs000Dzzy0001zzzU000Tzw07zz00000zzk000Dzw00000Dw0007zzz0000zzzk000Dzy03zzU0000Tzs0007zy000007y0003zzzU000Tzzs0007zz01zzk0000Dzw0003zz000003z0001zzzk000Dzzw0003zzU0zzs00007zy0001zzU00001zU000zzzs0007zzy0001zzk0Tzw00003zz0000zzk00000k00000Dw000003z000000zs0Dw000001zU00000Ts00000M000007y000001zU00000Tw07y000000zk00000Dw00000A000003z000000zk00000Dy03z000000Ts000007y000006000001zU00000Ts000007z01zU00000Dw000003z000003000000zk00000Dw000003zU0zk000007y000001zU00001U0zzU0Ts07zs07y01zz01zk0Ts07zzzzz00zz00zzzk0Dzk0Tzk0Dw07zy03z00zzU0zs0Dw03zzzzzU0zzU0Tzzw07zs0Dzs07y03zz01zU0Tzk0Tw07y01zzzzzk0Tzk0Dzzy03zw07zw03z01zzU0zk0Dzs0Dy03z00zzzzzs0Dzs07zzz01zy03zy01zU0zzk0Ts07zw07z01zU0Tzzzzw07zw03zzzU0zz01zz00zk0Tzs0Dw03zy03zU0zk0Dzzzzy03zy01zzzk0TzU0zzU0Ts0Dzw07y01zzzzzk0Ts07zzzzz01zz00zzzs0Dzk00000Dw07zy03z00zzzzzs0Dw0003zzzU0zzU0Tzzw07zs000007y03zz01zU0Tzzzzw07y0001zzzk0Tzk0Dzzy03zw000003z01zzU0zk0Dzzzzy03z0000zzzs0Dzs07zzz01zy000001zU0zzk0Ts07zzzzz01zU000Tzzw07zw03zzzU0zz000000zk0Tzs0Dw03zzzzzU0zk000Dzzy03zy01zzzk0TzU00000Ts0Dzw07y01zzzzzk0Ts0007zzz01zz00zzzs0Dzk00000Dw07zy03z00zzzzzs0Dw0003zzzU0zzU0Tzzw07zs000007y03zz01zU0Tzzzzw07y0001zzzk0Tzk0Dzzy03zw000003z01zzU0zk0Dzzzzy03z0000zzzs0Dzs07zzz01zy000001zU0zzk0Ts07zzzzz01zU000Tzzw07zw03zzzU0zz01zz00zk0Tzs0Dw03zzzzzU0zk0Dzzzzy03zy01zzzk0TzU0zzU0Ts0Dzw07y01zz01zk0Ts07zzzzz01zz00zzzs0Dzk0Tzk0Dw07zy03z00zzU0zs0Dw03zzzzzU0zzU0Tzzw07zs0Dzs07y03zz01zU0Tzk0Tw07y01zzzzzk0Tzk0Dzzy03zw07zw03z01zzU0zk0Dzs0Dy03z00zzzzzs0Dzs07zzz01zy03zy01zU0zzk0Ts07zw07z01zU0Tzzzzw07zw03zzzU0zz01zz00zk0Tzs0Dw01zw03zU0zk07zzzzy03zy01zzzk0TzU0zzU0Ts0Dzw07y000001zk0Ts000003z01zz00zzzs0Dzk0Tzk0Dw07zy03z000000zs0Dw000001zU0zzU0Tzzw07zs0Dzs07y03zz01zU00000Tw07y000000zk0Tzk0Dzzy03zw07zw03z01zzU0zk00000Dy03z000000Ts0Dzs07zzz01zy03zy01zU0zzk0Tzs0003zz01zzU0000Dw07zw03zzzU0zz01zz00zk0Tzs0Dzw0003zzU0zzs00007y03zy01zzzk0TzU0zzU0Ts0Dzw07zy0001zzk0Tzw00003z01zz00zzzs0Dzk0Tzk0Dw07zy03zz0000zzs0Dzy00001zU0zzU0Tzzw07zs0Dzs07y03zz01zzU000Tzw07zz00000zk0Tzk0Dzzy03zw07zw03z01zzU0zzk000Dzy03zzU0000Ts0Dzs07zzz01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone14Pattern := "|<>*146$203.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0001zzzy000007zzk0001zzs03zzU0Dzzk0003zzzw00000DzzU0003zzk07zz00TzzU0007zzzs00000Tzz00007zzU0Dzy00zzz0000Dzzzk00000zzy0000Dzz00Tzw01zzy0000TzzzU00001zzw0000Tzy00zzs03zzw0000zzzz000003zzs0000zzw01zzk07zzk0000zzzy000007zzU0001zzs03zzU0DzU000000zs000000Dz0000001zk07y000Tz0000001zk000000Ty0000003zU0Dw000zy0000003zU000000zw0000007z00Ts001zw0000007z0000001zs000000Dy00zk003zs000000Dy0000003zk000000Tw01zU007zk07zy00Tw01zzzzzzU0Dzw00zs03z00TzzU0Tzy00zs03zzzzzz00zzw01zk00000zzz00zzw01zk07zzzzzy01zzs03zU00001zzy01zzs03zU0Dzzzzzw03zzk07z000003zzw03zzk07z00Tzzzzzs07zzU0Dy000007zzs07zzU0Dy00zzzzzzk0Dzz00Tw00000Dzzk0Dzz00Tw01zzzzzzU0Tzy00zs00000TzzU0Dzw00zs01zzzzzz00Tzs01zk0001zzzz0000001zk0001zzzy0000003zU0003zzzy0000003zU0003zzzw0000007z00007zzzw0000007z00007zzzs000000Dy0000Dzzzs000000Dy0000Dzzzk000000Tw0000Tzzzk000000Tw0000TzzzU000000zs0000zzzzU00001zzs0000zzzz0000001zk0001zzzz000007zzk0001zzzy0000003zU0003zzzy00000DzzU0003zzzw0000007z00007zzzw00000Tzz00007zzzs000000Dy0000Dzzzs00000zzy0000Dzzzk000000Tw0000Tzzzk00001zzw0000TzzzU000000zs0000zzzzU0Dzzzzzs01zzzzzz00Tzs01zk0001zzzz00zzzzzzk07zzzzzy01zzs03zU00001zzy01zzzzzzU0Dzzzzzw03zzk07z000003zzw03zzzzzz00Tzzzzzs07zzU0Dy000007zzs07zzzzzy00zzzzzzk0Dzz00Tw00000Dzzk0Dzzzzzw01zzzzzzU0Tzy00zs00000TzzU0Tzzzzzs03zzzzzz00zzw01zk00000zzz00zzzzzzk03zzzzzy01zzs03zU0Dw00zzy01zzzzzzU000000zw03zzk07z00Ts001zw03zzzzzz0000001zs07zzU0Dy00zk003zs07zzzzzy0000003zk0Dzz00Tw01zU007zk0Dzzzzzw0000007zU0Tzy00zs03z000DzU0Tzzzzzs000000Dz00zzw01zk07y000Tz00zzzzzzzs00000Ty01zzs03zU0Dzy00zy01zzzzzzzk00000zw03zzk07z00Tzw01zw03zzzzzzzU00001zs07zzU0Dy00zzs03zs07zzzzzzz000003zk0Dzz00Tw01zzk07zk0Dzzzzzzy000007zU0Tzy00zs03zzU0DzU0Tzzzzzzw00000Dz00zzw01zk07zz00Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone15Pattern := "|<>*141$213.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk0001zzzy0000003zzzs00000Dzz00007zzy0000Dzzzk000000Tzzz000001zzs0000zzzk0001zzzy0000003zzzs00000Dzz00007zzy0000Dzzzk000000Tzzz000001zzs0000zzzk0001zzzy0000003zzzs00000Dzz00007zzy0000Dzzzk000000Tzzz000001zzs0000zzzk0000zzzw0000001zzzs00000Dzy00003zw0000007zU00000000Dy0000001zk000000TU000000zw000000001zk000000Dy0000003w0000007zU00000000Dy0000001zk000000TU000000zw000000001zk000000Dy0000003w0000007zU00000000Dy0000001zk000000TU07zy00zw01zU0Dw01zk03zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00Dzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00007zzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00007zzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00007zzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00007zzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00007zzzk07zz00TU0Dzy00zw01zU0Dw01zk0000zzzy00zzs03w01zzk07zU0Dw01zU0Dy00Tzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU0Dzy00zw01zU0Dw01zk07zzzzzy00zzs03w01zzk07zU0Dw01zU0Dy00zzzzzzk07zz00TU07zy00zw01zU0Dw01zk03zzzzzy00zzs03w0000007zU0Dw01zU0Dy0000001zk07zz00TU000000zw01zU0Dw01zk000000Dy00zzs03w0000007zU0Dw01zU0Dy0000001zk07zz00TU000000zw01zU0Dw01zk000000Dy00zzs03w0000007zU0Dw01zU0Dy0000001zk07zz00Tzk0000zzw01zU0Dw01zzs00000Dy00zzs03zy0000DzzU0Dw01zU0Dzz000001zk07zz00Tzk0001zzw01zU0Dw01zzs00000Dy00zzs03zy0000DzzU0Dw01zU0Dzz000001zk07zz00Tzk0001zzw01zU0Dw01zzs00000Dy00zzs03zy0000DzzU0Dw01zU0Dzz000001zk07zz00Tzk0001zzw01zU0Dw01zzw00000Dy00zzs03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone16Pattern := "|<>*146$243.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs00003zU000007zzU0000Dzy0000zzzw000000zzz00000Tw000000zzw00001zzk0007zzzU000007zzs00003zU000007zzU0000Dzy0000zzzw000000zzz00000Tw000000zzw00001zzk0007zzzU000007zzs00003zU000007zz00000Dzy0000zzzw000000zz000000Tw000000zs000001zk000003z000000007s000003zU000007z000000Dy000000Ts00000000z000000Tw000000zs000001zk000003z000000007s000003zU000007z000000Dy000000Ts00000000z000000Tw000000zs000001zk000003z000000007s07zzzzzzzU07zzz00Tzzzzy01zz00Ts03w00z00z00zzzzzzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07s07zzzzzzzk0Dzzz00zzzzzy01zzU0Ts07y01z00z00zzzzzzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07s07zzzzzzzk0Dzzz00zzzzzy01zzU0Ts07y01z00z00zzzzzzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07s07zzzzzzzk0Dzzz00zzzzzy01zzU0Ts07y01z00z00000Tzzzy01zzzs0003zzzk000003z00zk0Ds07s00003zzzzk0Dzzz0000Tzzy000000Ts07y01z00z00000Tzzzy01zzzs0003zzzk000003z00zk0Ds07s00003zzzzk0Dzzz0000Tzzy000000Ts07y01z00z00000Tzzzy01zzzs0003zzzk000003z00zk0Ds07zs0003zzzzk0Dzzz0000Tzzy000000Ts07y01z00zz00000Tzzy01zzzs0003zzzk000003z00zk0Ds07zs00003zzzk0Dzzz0000Tzzy000000Ts07y01z00zz00000Tzzy01zzzs0003zzzk000003z00zk0Ds07zs00003zzzk0Dzzz0000Tzzy000000Ts07y01z00zz00000Tzzy01zzzs0003zzzk000003z00zk0Ds07zzzzw03zzzk0Dzzz00zzzzzy01zz00Ts07y01z00zzzzzk0Tzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07zzzzy03zzzk0Dzzz00zzzzzy01zzU0Ts07y01z00zzzzzk0Tzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07zzzzy03zzzk0Dzzz00zzzzzy01zzU0Ts07y01z00zzzzzk0Tzzy01zzzs07zzzzzk0Dzw03z00zk0Ds07zzzzw03zzzk0Dzzz00zzzzzy01zzU0Ts07y01z00z000000Tzzy01zzzs000001zk0Dzw03z00zk0Ds07s000003zzzk0Dzzz000000Dy01zzU0Ts07y01z00z000000Tzzy01zzzs000001zk0Dzw03z00zk0Ds07s000003zzzk0Dzzz000000Dy01zzU0Ts07y01z00z000000Tzzy01zzzs000001zk0Dzw03z00zk0Ds07s00003zzzzk0Dzzzz00000Dy01zzU0Ts07y01z00z00000Tzzzy01zzzzw00001zk0Dzw03z00zk0Ds07s00003zzzzk0DzzzzU0000Dy01zzU0Ts07y01z00z00000Tzzzy01zzzzw00001zk0Dzw03z00zk0Ds07s00003zzzzk0DzzzzU0000Dy01zzU0Ts07y01z00z00000Tzzzy01zzzzw00001zk0Dzw03z00zk0Ds07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone17Pattern := "|<>*144$153.zzzzzzzzzzzzzzzzzzzzzzzzzw000Tzs00Dzw007zU000DU7zU7U003zz001zzU00zw0001w0zw0w000Tzs00Dzw007zU000DU7zU7U001zz001zz000zw0001w0zw0w0001y0000z0000TU000DU7zU7U000Dk0007s0003w0001w0zw0w0001y0000z0000TU000DU7zU7U7z0Dk3zU7s1zk3zz0Dzw0zw0w0zs1y0Tw0z0Dy0Tzs1zzU7zU7U7z0Dk3zU7s1zk3zz0Dzw0zw0w0zs1y0Tw0z0Dy0Tzs1zzU7zU7U000Dk0007s0003zz0Dzw0000w0001y0000z0000Tzs1zzU0007U000Dk0007s0003zz0Dzw0000w0001y0000z0000Tzs1zzk0007U003zk0007s000zzz0Dzzs00Tw000Ty0000z0007zzs1zzz003zU003zk0007s000zzz0Dzzs00Tw000Ty0000z0007zzs1zzz003zU7zzzk3zU7s1w03zz0DzzzU7zw0zzzy0Tw0z0DU0Tzs1zzzw0zzU7zzzk3zU7s1w03zz0DzzzU7zw0zzzy0Tw0z0Dy0Tzs1zzzw0zzU7zzzk3zU7s1zk3zz0DzzzU7zw0zzzy0Tw0z0Dy0Tzs1zzzw0zzU7zzzk3zU7s1zk3zz0DzzzU7zw0zzzy0Tw0z0Dy0Tzs1zzzw0zzU7zzzk3zU7s1zk3zz0DzzzU7zw0zzzy0Tw0z0Dy0Tzs1zzzw0zzU7zzzk3zU7s1zk3zz0DzzzU7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone18Pattern := "|<>*145$301.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs00001zzk0003zzU0Tzw03zU0Tzs03zzU0007zzzU000Dzzzzzw00000zzs0001zzk0Dzy01zk0Dzw01zzk0003zzzk0007zzzzzy00000Tzw0000zzs07zz00zs07zy00zzs0001zzzs0003zzzzzz00000Dzy0000Tzw03zzU0Tw03zz00Tzw0000zzzw0001zzzzzzU00007zz0000Dzy01zzk0Dy01zzU0Dzy0000Tzzy0000zzzzzzU00003zzU0007zz00zzs07z00zzk07zz0000Dzzz0000Tzzzzk000001zk000003zU0Tzw03zU0Tzs03zU000007z0000007zzzs000000zs000001zk0Dzy01zk0Dzw01zk000003zU000003zzzw000000Tw000000zs07zz00zs07zy00zs000001zk000001zzzy000000Dy000000Tw03zzU0Tw03zz00Tw000000zs000000zzzz0000007z000000Dy01zzk0Dy01zzU0Dy000000Tw000000TzzzU0DzzzzzU0Tzs07z00zzs07z00zzk07z00zzk0Dy00zzU0Dzzzk0Dzzzzzk0Dzw03zU0Tzw03zU000003zU0Tzs07z00zzs07zzzs07zzzzzs07zy01zk0Dzy01zk000001zk0Dzw03zU0Tzw03zzzw03zzzzzw03zz00zs07zz00zs000000zs07zy01zk0Dzy01zzzy01zzzzzy01zzU0Tw03zzU0Tw000000Tw03zz00zs07zz00zzzz00zzzzzz00zzk0Dy01zzk0Dy000000Dy01zzU0Tw03zzU0TzzzU0TzzzzzU0Tzs07z00zzs07zz0000Dzz00zzk0Dy01zzk0Dzzzk00003zzk000003zU0Tzw03zzk0007zzU0Tzs07z00zzs07zzzs00001zzs000001zk0Dzy01zzs0003zzk0Dzw03zU0Tzw03zzzw00000zzw000000zs07zz00zzw0001zzs07zy01zk0Dzy01zzzy00000Tzy000000Tw03zzU0Tzy0000zzw03zz00zs07zz00zzzz00000Dzz000000Dy01zzk0Dzz0000Tzy01zzU0Tw03zzU0TzzzzU0007zzU00007zz00zzs07zzU000Dzz00zzk0Dy01zzk0Dzzzzs00001zk00003zzU0Tzw03zzk0007zzU0Tzs07z00zzs07zzzzw00000zs00001zzk0Dzy01zzs0003zzk0Dzw03zU0Tzw03zzzzy00000Tw00000zzs07zz00zzw0001zzs07zy01zk0Dzy01zzzzz00000Dy00000Tzw03zzU0Tzy0000zzw03zz00zs07zz00zzzzzU00007z00000Dzy01zzk0Dzz0000Tzy01zzU0Tw03zzU0Tzzzzzzzs03zU0Tk07zz00zzs07zz0000Dzz00zzk0Dy01zzk0Dzzzzzzzw01zk0Ds003zU0Tzw03zU000003zU0Tzs07z00zzs07zzzzzzzy00zs07w001zk0Dzy01zk000001zk0Dzw03zU0Tzw03zzzzzzzz00Tw03y000zs07zz00zs000000zs07zy01zk0Dzy01zzzzzzzzU0Dy01z000Tw03zzU0Tw000000Tw03zz00zs07zz00zzzzzzzzk07z00zU00Dy01zzk0Dy000000Dy01zzU0Tw03zzU0Tzzzzzzzs03zU0Tzs07z00Tzs07z00Tzk07z00zzk0Dy01zzk0Dzzzk000001zk0Dzw03zU000003zU0Tzs03zU000007z00zzs07zzzs000000zs07zy01zk000001zk0Dzw01zk000003zU0Tzw03zzzw000000Tw03zz00zs000000zs07zy00zs000001zk0Dzy01zzzy000000Dy01zzU0Tw000000Tw03zz00Tw000000zs07zz00zzzz0000007z00zzk0Dy000000Dy01zzU0Dy000000Tw03zzU0TzzzU00003zzU0Tzs07zz00007zz00zzk07zz0000Dzy01zzk0Dzzzk00003zzk0Dzw03zzk0007zzU0Tzs03zzU0007zz00zzs07zzzs00001zzs07zy01zzs0003zzk0Dzw01zzk0003zzU0Tzw03zzzw00000zzw03zz00zzw0001zzs07zy00zzs0001zzk0Dzy01zzzy00000Tzy01zzU0Tzy0000zzw03zz00Tzw0000zzs07zz00zzzz00000Dzz00zzk0Dzz0000Tzy01zzU0Dzy0000Tzw03zzU0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone19Pattern := "|<>*143$233.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU0000Dzy0000zzs07zzzzzzU000Dzzz0000zzzz00000Tzw0001zzk0Dzzzzzz0000Tzzy0001zzzy00000zzs0003zzU0Tzzzzzy0000zzzw0003zzzw00001zzk0007zz00zzzzzzw0001zzzs0007zzzs00003zzU000Dzy01zzzzzzs0003zzzk000DzzzU00007zy0000Tzw03zzzzzzk0003zzz0000Dzz000000Dy000000zs07zzzzzU00000Dy000000Ty000000Tw000001zk0Dzzzzz000000Tw000000zw000000zs000003zU0Tzzzzy000000zs000001zs000001zk000007z00zzzzzw000001zk000003zk000003zU00000Dy01zzzzzs000003zU000007zU0Tzzzzz01zzU0Tw03zzzzzk0Dzw07z00zzk0Dz00zzzzzy03zz00zs07zzzzzU0Tzs0Dy01zzU0Ty01zzzzzw07zy01zk0Dzzzzz00zzk0Tw03zz00zw03zzzzzs0Dzw03zU0Tzzzzy01zzU0zs07zy01zs07zzzzzk0Tzs07z00zzzzzw03zz01zk0Dzw03zk0DzzzzzU0zzk0Dy01zzzzzs07zy03zU0TzzzzzU0Ts007z000000Tw03zzzzzk000007z00zzzzzz00zk00Dy000000zs07zzzzzU00000Dy01zzzzzy01zU00Tw000001zk0Dzzzzz000000Tw03zzzzzw03z000zs000003zU0Tzzzzy000000zs07zzzzzs07y001zk000007z00zzzzzw000001zk0Dzzzzzk0Dw003zU00000Dy01zzzzzs000003zU0TzzzzzU0Ts007z000000Tw03zzzzzk000007z00zzzzzz00zk00Dy000000zs07zzzzzU00000Dy01zzzzzy01zU00Tw000001zk0Dzzzzz000000Tw03zzzzzw03z000zs000003zU0Tzzzzy000000zs07zzzzzs07y001zk000007z00zzzzzw000001zk0Dzzzzzk0Dzw03zU0Tzk0Dy01zzzzzs07zw03zU0TzzzzzU0Tzs07z01zzU0Tw03zzzzzk0Dzw07z00zzk0Dz00zzk0Dy03zz00zs07zzzzzU0Tzs0Dy01zzU0Ty01zzU0Tw07zy01zk0Dzzzzz00zzk0Tw03zz00zw03zz00zs0Dzw03zU0Tzzzzy01zzU0zs07zy01zs07zy01zk0Tzs07z00zzzzzw03zz01zk0Dzw03zk07zw03zU0zzk0Dy01zzzzzs07zy03zU0Tzs07zU000007z01zzU0Tw000001zk0Dzw07z000000Dz000000Dy03zz00zs000003zU0Tzs0Dy000000Ty000000Tw07zy01zk000007z00zzk0Tw000000zw000000zs0Dzw03zU00000Dy01zzU0zs000001zs000001zk0Tzs07z000000Tw03zz01zk000003zzs00003zU0zzk0Dzy00000zs07zy03zzU000Dzzzk00007z01zzU0Tzw00001zk0Dzw07zzU000TzzzU0000Dy03zz00zzs00003zU0Tzs0Dzz0000zzzz00000Tw07zy01zzk00007z00zzk0Tzy0001zzzy00000zs0Dzw03zzU0000Dy01zzU0zzw0003zzzw00001zk0Tzs07zz00000Tw03zz01zzs0007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone20Pattern := "|<>*142$217.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz000003zk07zzzzzzy0000DzzU0Dw01zU0DzzU00001zs03zzzzzzz00007zzk07y00zk07zzk00000zw01zzzzzzzU0003zzs03z00Ts03zzs00000Ty00zzzzzzzk0001zzw01zU0Dw01zzw00000Dz00Tzzzzzzs0000zzy00zk07y00zzy000007zU0Dzzzzzzw0000Tzz00Ts03z00Tzz000003zk07zzzzzzy00007zzU0Dw01zU0Dz0000001zs03zzzzzy0000003zk07y00zk07zU000000zw01zzzzzz0000001zs03z00Ts03zk000000Ty00zzzzzzU000000zw01zU0Dw01zs000000Dz00Tzzzzzk000000Ty00zk07y00zw0000007zU0Dzzzzzs000000Dz00Ts03z00Ty00Tzzzzzk07zzzzzw00zzk07zU0Dw01zU0Dz00Tzzzzzs03zzzzzy00zzs03zk07y00zk07zU0Dzzzzzw01zzzzzz00Tzw01zs03z00Ts03zk07zzzzzy00zzzzzzU0Dzy00zw01zU0Dw01zs03zzzzzz00Tzzzzzk07zz00Ty00zk07y00zw01zzzzzzU0Dzzzzzs03zzU0Dz00Ts03z00Ty00zzzzzzk07zzzzzw01zzk07zU0Dw01zU0Dz00Tzzzzzs03zzzzzy00Tzk03zk07y00zk07zU0Dzzzzzw01zzzzzz0000001zs03z00Ts03zk07zzzzzy00zzzzzzU000000zw01zU0Dw01zs03zzzzzz00Tzzzzzk000000Ty00zk07y00zw01zzzzzzU0Dzzzzzs000000Dz00Ts03z00Ty00zzzzzzk07zzzzzw0000007zU0Dw01zU0Dz00Tzzzzzs03zzzzzy0000003zk07y00zk07zU0Dzzzzzw01zzzzzz0000001zs03z00Ts03zk07zzzzzy00zzzzzzU000000zw01zU0Dw01zs03zzzzzz00Tzzzzzk000000Ty00zk07y00zw01zzzzzzU0Dzzzzzs000000Dz00Ts03z00Ty00zzzzzzk07zzzzzw0000007zU0Dw01zU0Dz00Tzzzzzs03zzzzzy00Tzs03zk07y00zk07zU0Dzzzzzw01zzzzzz00Tzw01zs03z00Ts03zk07zzzzzy00zzzzzzU0Dzy00zw01zU0Dw01zs03zzzzzz00Tzzzzzk07zz00Ty00zk07y00zw01zzzzzzU0Dzzzzzs03zzU0Dz00Ts03z00Ty00zzzzzzk07zzzzzw01zzk07zU0Dw01zU0Dz00Tzzzzzs03zzzzzy00zzs03zk07y00zk07zU07zzzzzw01zzzzzz00Tzw01zs03y00Tk03zk000000Ty0000003zU0Dzy00zw000000001zs000000Dz0000001zk07zz00Ty000000000zw0000007zU000000zs03zzU0Dz000000000Ty0000003zk000000Tw01zzk07zU00000000Dz0000001zs000000Dy00zzs03zk000000007zzk00000zzw000007z00Tzw01zzs0000007zzzs00000Tzz000003zU0Dzy00zzy0000003zzzw00000DzzU00001zk07zz00Tzz0000001zzzy000007zzk00000zs03zzU0DzzU000000zzzz000003zzs00000Tw01zzk07zzk000000TzzzU00001zzw00000Dy00zzs03zzs000000Dzzzk00000zzy000007z00Tzw01zzw0000007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    ;Zone pattern OCRs are being evaluated in the FOR loop, with a GetRange applied, see the comment in the for loop about this.

    zones := {}
    zones["Zone1"] := zone1Pattern
    zones["Zone2"] := zone2Pattern
    zones["Zone3"] := zone3Pattern
    zones["Zone4"] := zone4Pattern
    zones["Zone5"] := zone5Pattern
    zones["Zone6"] := zone6Pattern
    zones["Zone7"] := zone7Pattern
    zones["Zone8"] := zone8Pattern
    zones["Zone9"] := zone9Pattern
    zones["Zone10"] := zone10Pattern
    zones["Zone11"] := zone11Pattern
    zones["Zone12"] := zone12Pattern
    zones["Zone13"] := zone13Pattern
    zones["Zone14"] := zone14Pattern
    zones["Zone15"] := zone15Pattern
    zones["Zone16"] := zone16Pattern
    zones["Zone17"] := zone17Pattern
    zones["Zone18"] := zone18Pattern
    zones["Zone19"] := zone19Pattern
    zones["Zone20"] := zone20Pattern
    
    for zoneName, pattern in zones {
        if (ok := FindText(X, Y, 1191, 537, 1999, 700, 0, 0, pattern)) {
            DebugLog("DetectCurrentZone: Matched zone = " . zoneName)
            return zoneName
        }
    }
    DebugLog("DetectCurrentZone: No matching zone found.")
    return ""
}

EnsureCorrectDungeonSelected(zoneName, targetDungeonIndex) {
    global dungeonMapping
    dungeonArray := dungeonMapping[zoneName]
    if (!dungeonArray) {
        DebugLog("EnsureCorrectDungeonSelected: No dungeon mapping found for " . zoneName)
        return false
    }
    
    targetDungeonPattern := dungeonArray[targetDungeonIndex]
    if (ok := FindText(X, Y, 660, 496, 2501, 1680, 0, 0, targetDungeonPattern)) {
        FindText().Click(X, Y, "L")
        SoundBeep, 600, 500
        DebugLog("EnsureCorrectDungeonSelected: Target dungeon in " . zoneName . " detected using index " . targetDungeonIndex)
        return true
    } else {
        DebugLog("EnsureCorrectDungeonSelected: Target dungeon in " . zoneName . " NOT detected for index " . targetDungeonIndex)
        return false
    }
}
F12::
{
    global gameState, previousState

    if (A_IsPaused) { ; Check if the underlying thread IS paused
        ; --- RESUME ---
        Pause, Off, 1 ; Operate on the underlying thread to unpause it FIRST

        ; Restore the logical game state
        if (previousState != "") {
            gameState := previousState
            DebugLog("Resumed via hotkey. Restoring previous state: " . gameState)
            previousState := ""
        } else {
            gameState := "NotLoggedIn" ; Fallback
            DebugLog("Resumed via hotkey. No previous state; resetting to NotLoggedIn.")
        }

    } else { ; If underlying thread is not paused, PAUSE it
        ; --- PAUSE ---
        ; Save the logical state BEFORE setting to Paused
        previousState := gameState
        gameState := "Paused" ; Set our state variable for BotMain check
        DebugLog("Paused via hotkey. Previous state: " . previousState)

        Pause, On, 1 ; Operate on the underlying thread to pause it LAST
    }
}
Return
