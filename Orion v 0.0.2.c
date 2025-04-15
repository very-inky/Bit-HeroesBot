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
currentActionIndex := 1

;------------- Multiple Choice Configuration -------------
; Specify desired zone/dungeon pairs.
desiredZones := ["Zone8"]
desiredDungeons := ["Dungeon1"]  ; Corresponding dungeon choices.
global currentSelectionIndex := 1  ; Tracks configuration index.

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
    global gameState, currentActionIndex, actionOrder, actionConfig, lastActionTime, actionCooldown, currentAction, currentSelectionIndex, desiredZones ; Added more globals needed in scope

    if (gameState = "Paused")
        Return

    ; If not logged in, check for quest icon.
    if (gameState = "NotLoggedIn") {
        DebugLog("NotLoggedIn: Checking for quest icon...")
        if (IsMainScreenAnchorDetected()) {
            DebugLog("Quest icon detected. Transitioning to NormalOperation.")
            gameState := "NormalOperation"
        } else {
            DebugLog("Quest icon not detected. Transitioning to HandlingPopups.")
            gameState := "HandlingPopups"
        }
        Return
    }

    ; Handling pop-ups before game can progress.
    if (gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: Clearing pop-ups...")
        popupAttempts := 0
        while (!IsMainScreenAnchorDetected()) {
            if (gameState = "Paused") {
                while (gameState = "Paused")
                    Sleep, 500
            }
            Send, {Esc}
            Sleep, 1000
            popupAttempts++
            DebugLog("HandlingPopups: Sent {Esc}, attempt #" . popupAttempts)
        }
        DebugLog("HandlingPopups: Quest icon detected. Transitioning to NormalOperation.")
        gameState := "NormalOperation"
        Return
    }

    ; Normal operation – start new actions OR advance if cooldown active
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex] ; Assign to global currentAction
        DebugLog("NormalOperation: Checking action: " . currentAction)
        now := A_TickCount

        if (!actionConfig[currentAction]) { ; Check if action is enabled in config
            DebugLog("NormalOperation: " . currentAction . " is disabled in config, skipping.")
            currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
            Return ; Skip to next BotMain tick
        }

        ; Check if cooldown allows the action to run
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
            }

            ; --- Handle result from the action function ---
            if (result = "started") {
                DebugLog("NormalOperation->ActionRunning: " . currentAction . " initiated.")
                gameState := "ActionRunning"
            } else if (result = "outofresource") {
                DebugLog("NormalOperation: " . currentAction . " returned 'outofresource'. Starting cooldown & advancing.")
                lastActionTime[currentAction] := now
                currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
                ; Close relevant UI (e.g., Esc out of Quest window) - Customize as needed
                Loop, 2 { 
                            Send, {Esc} Sleep 500 
                        }
            } else if (result = "retry") {
                DebugLog("NormalOperation: " . currentAction . " returned 'retry'. Will reattempt on next cycle.")
                ; No state change, no index change. Let BotMain run again.
            } else { ; Handles "success" from non-long-running actions, or other unexpected returns
                DebugLog("NormalOperation: " . currentAction . " completed immediately ('" . result . "'). Starting cooldown & advancing.")
                lastActionTime[currentAction] := now
                currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
             }
        } else {
             ; Cooldown is active for the current action
             timeRemaining := Ceil((actionCooldown - (now - lastActionTime[currentAction])) / 1000)
             DebugLog("NormalOperation: " . currentAction . " skipped - cooldown active (" . timeRemaining . "s left). Advancing action index.")
             currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
        }
        Return 
    }

; While an action is running, monitor its progress.
    if (gameState = "ActionRunning") {
        DebugLog("BotMain (" . currentAction . "): Calling MonitorActionProgress...")
        monitorResult := MonitorActionProgress() ; Monitor progress, handle completion/death/disconnect
        DebugLog("BotMain (" . currentAction . "): MonitorActionProgress returned: [" . monitorResult . "]")

        DebugLog("BotMain (" . currentAction . "): Checking monitorResult...")
        if (monitorResult = "start_next_config") {
             DebugLog("BotMain (" . currentAction . "): monitorResult IS 'start_next_config'.")
             DebugLog("BotMain (" . currentAction . "): Attempting to start next configuration.")

             actionResult := ""
             Switch currentAction {
                Case "Quest": actionResult := ActionQuest()
                Default:
                     DebugLog("BotMain: Monitor reported chain step for non-Quest action (" . currentAction . "). Returning to NormalOperation.")
                     actionResult := "error" ; Or a specific status? Set state maybe?
                     gameState := "NormalOperation" ; Default fallback for now
                     Return
             }

             ; --- Handle result of trying to start the next run ---
             if (actionResult = "started") {
                 DebugLog("BotMain: Successfully started next run for " . currentAction . ". Remaining in ActionRunning.")
             } else if (actionResult = "outofresource") {
                 DebugLog("BotMain: Out of resources trying to start next run for " . currentAction . ". Exiting action block.")
                 lastActionTime[currentAction] := A_TickCount ; Start cooldown
                 currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1 ; Advance main action
                 gameState := "NormalOperation" ; Go back to normal loop
                 ; Ensure UI is closed (might be redundant if MonitorActionProgress did it)
                 Loop, 2 {
                     Send, {Esc} Sleep 500
                 }
             } else { ; Handles "retry" or other failures
                 DebugLog("BotMain: Failed to start next run for " . currentAction . " ('" . actionResult . "'). Returning to NormalOperation.")
                 ; Consider how to handle this? Retry count? For now, just go back to Normal state.
                 gameState := "NormalOperation"
                 ; Maybe start cooldown anyway? Or advance index? Needs thought for robustness.
             }
        }
        else if (monitorResult = "outofresource") { 
             DebugLog("BotMain (" . currentAction . "): monitorResult IS 'outofresource'.") ; Log inside block
             DebugLog("BotMain (" . currentAction . "): Handling out of resources after Rerun. Exiting action block.")
             lastActionTime[currentAction] := A_TickCount ; Start cooldown
             currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1 ; Advance main action
             gameState := "NormalOperation" ; Go back to normal loop
             DebugLog("BotMain (" . currentAction . "): Set gameState to NormalOperation. Cooldown started. New gameState: " . gameState)
             ; UI should have been closed by MonitorActionProgress
        }
        else {
             DebugLog("BotMain (" . currentAction . "): monitorResult is NOT 'start_next_config' or 'outofresource'. Result=[" . monitorResult . "]. Taking no specific action this tick.") ; Log other cases
        }
        ; If monitorResult is "rerun", "in_progress", "disconnected", "player_dead", "error",
        ; MonitorActionProgress already handled state changes or necessary actions.
        ; BotMain doesn't need to do anything further in those cases for this tick.

        DebugLog("BotMain (" . currentAction . "): End of ActionRunning check for this tick. Current gameState: " . gameState)
        Return ; Finished ActionRunning logic for this tick
    }
Return
}

;===========================================
; MonitorActionProgress – Merged Logic with Enhanced Logging & Correct Loop Syntax
;===========================================
MonitorActionProgress() {
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
        Send, {Esc} ;NOT FINISHED YET
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
;town button
if (ok:=FindText(X, Y, 1796-150000, 1532-150000, 1796+150000, 1532+150000, 0, 0, Text))
{
  FindText().Click(X, Y, "L")
}

    DebugLog("ClickTownOnCompletionScreen: Attempting to find exit button...")
    if (ok:=FindText(X, Y, 1796-150000, 1532-150000, 1796+150000, 1532+150000, 0, 0, Text))
    {
        DebugLog("ClickTownOnCompletionScreen: Town button clicked.")
        return true ; Indicate success
    } else {
        DebugLog("ClickTownOnCompletionScreen: Town button NOT detected. Bot hanging?")
        return false ; Indicate failure (or maybe true if Esc is acceptable?)
    }
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
    ; Insert your reconnection logic here.
    ; This might include clicking on a 'reconnect' button,
    ; or navigating back to the main screen.
    ;DebugLog("AttemptReconnect: Executing reconnection routine...")
    ; For example, click {Esc} repeatedly, or simulate a refresh:
    ;Send, {Esc}
    ;Sleep, 1000
    ; After your reconnection routine, you may want to update gameState.
    ; For now, we simply log and let the main loop take care of resetting.
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
    ; Insert OCR or other logic to detect a disconnect.
    return false  ; Placeholder.
}

IsPlayerDead() {
    ; Insert OCR or other logic to detect if the player has died.
    return false  ; Placeholder.
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
        Sleep, 800
    } else if (result = "outofresource") {
        DebugLog("ActionQuest: Out-of-resources detected after clicking Accept; starting cooldown and rotating action.")
        return "outofresource"
    } else {
        DebugLog("ActionQuest: Accept button not confirmed; retrying.")
        return "retry"
    }
    
    ; Step 7: Check for resource shortage.
    if (CheckOutOfResources()) {
        DebugLog("ActionQuest: Detected resource shortage after Accept.")
        return "outofresource"
    }
    
    DebugLog("ActionQuest: Quest action initiated successfully.")
    ; Return a special signal indicating the action has started.
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
        return false
        DebugLog("IsHeroicSelected not finding team screen")
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
;===========================================
; Other Action Functions (PVP, WorldBoss, etc.)
;===========================================
ActionPVP() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionPVP: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionPVP: Executed successfully.")
    return "success"
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
