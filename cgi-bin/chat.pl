#!/usr/bin/perl
###############################################################################
# chat.pl                                                                     #
###############################################################################
# GTChat (http://www.gtchat.de)                                               #
# GTChat 0.93 Copyright (c) 2001 by Wladimir Palant                           #
# Changes on this file are not permitted!                                     #
###############################################################################
$xWerg1pOWSCI='d6f646966697d656373716765623k8737f675946564855637e6d423hd6f646966697d6563737167656k873397930763972695d664h6796567716c69616375637k87174575f6673334a6577736h46f6d61696e64756e616e6365623k87a7c4b686d666363626c615hf28725362637e6531366754723e207c6k87476613f4a503959457e6d4hc61637474796d656k878335d494a61346f42423h449627563647f627965637e2461647k87766783662646651644c655h36c656162747271666669636k8713c46666a58525271394h4656c656475616c6961637k870553f6778693864783355513h679656770727f66696c656k87c4f6a61576c6a55746566323h4656c656475657375627k87346733e4770777e4d4a615hd6f646966697c6963747k87a4934526f63765262663hf2874374764455031366771376e207c6k87f675656386071433132794he2c6e676k8796d43514c47726359757f6h472716365627f6574756k87238763938697c6454495hd6f646966697k873773574416c6c6e457e436h46f6d61696e64756e616e63656k87640587739556a446544623hd6f64696669727f6f6d6k872454831525a64644270595h9646k878693644607458387b615hd6f646966697c696374723k8787943674977374f49433he24656f2k8765a79477349656d423h2756d696e6465627k8774138776735726547434b6h1646d696e6k87b44594c6b6f466572755hd6f6469666972616e6c696374723k87538464b4e4974793562315hd6f646966697075627d696373796f6e637k8797f643372695e6d4478414hf287b63365764347e684b49354e207c6k87c49424e6d6c4a4942715f6h7445348616470203e29333k87a725242717b4d697d414hf2871626e6f4674586938687e207c6k87b4635494e6338686275794hd6f6469666973756474796e67637k8787943674977374f49413h4656c65647562616e6c6963747k8746175645351453145594hf287953797442315254467b637e207c6k8714548647776486860546hf287d6577787036697a6433695e207c6k870316d4a7676476571695h3756e646k879574058626236614759376h56e646d61696e64756e616e63656k8746145776a766f4e494b415hf28747969627562416c6c4d4e207c6k8776447654c45575e4466376h4656c656475627f6f6d6k872697465507937363841423hd6f6469666970727f66696c656k8756f67636437387f453949553h27563656966756k87858617a637a764d4873495hf287056745c464369786463323e207c6k8797834654659743954754hc6f67696e6662716d656k87745567f60586a665156654hd6f6675637d696c6569723k870774c61493f6a763b6f437h367696d322k87a50366e4771785f6a72695h27f6f6d6k8757b4969684a7b4774676b6h4656c656475637d696c65697k87b463f454749623c487b6hc6963656e63756k87643717c44667c44793b6hb7353425940545d7k8766655397766345c4a4c695h27f6f6d6c6963747k874746c6054526961653f414h0275c6164696d69627020516c616e647k878363f695a7a66395351595h373627960747k87a585271455757583876795h2756769637475627k87969355f67745a49387d637he69636b6k87f67487f657769515257523hd6f646966697e6567737k8756f67636437387f453949513h679656772616e6c6963747k8795176575364376178454d4h6796567737d696c6569737k87537783b415052795254654hf28774a76556f476545627e614e207c6k87652643772764d4f4b476h3556474796e67637e2461647k87c6e47336653447d6a654hd6f64696669737d696c65697k87a6f677f6a51444451776h679656774756874737k87c4f6a61576c6a55746566313he616d656k875734540537c4d4d4764623h2756d6f6675636f6f6b69656k87b4732463e4c6f6d41423h6796567727f6f6d637k87849437b6a57694856566f6h3756162736865737562723k8764a6676546b475952755hf39646d3k8714640763635544b4a676h275676963747562723k8737130726944565059576f6h6796567747271666669636k871664a61667d4a4168723h4656c6564756e6567737k87a575842475765375431754h2697k87d4a5357787d66663a755h36861647e207c6k87969454b657464366b48777hd6f64696669737d696c6569723k8756f67636437387f453949533h4656c6564756d6563737167656k87a656771485343765f6d494h1646d696e6f5d61696e64756e616e63656k879326840546b693e643d437hf28713732716378316643723d4e207c6k8793336443f626a483b4b6hd6f6469666972616e6c6963747k8795031374178647361413hd6f6675637d696c65697k8733030516c455b47367a714hf287f623e493b67464031523e207c6k877724743797158786833723hd6f646966697e656773723k87950313741786473614hf2k8764072515f6a633773694h0757c6c6k874497b45383362736c4c614hd6f64696669716c696163723k87d6d466c6b655d4a6b45413hf287b4b42495532696373414e207c6k87f60716f665a7765644c623hk87a4b417261696a68714a513h22b346f6c4f67696e68292k879583d4f497337717536454h46164716k87c6e65325771623540355hf287652727456655e615c6f494e207c6k87a777e405f47525652607b6h84454505f534f4f4b49454k87e625536435951356148595hd6f64696669716c6961637k87774567163633437335a4d413h57375627c6963747k87449527156683759384e663hd6f64696669747568747k8756f67636437387f453949523hf287174743a49487464436a763e207c6k8757757346f484a46534f6hd6f6469666973756474796e6763723k87273515a7655495666337hf28766548355651553a425f6e207c6k874576a7757737832607h2756d696e646562723k874626f4845584755385f655he6f6c6f67696e6275636f62746k87c4835634979693c6236436hd6f646966697075627d696373796f6e63723k87774567163633437335a4d4hf287772647f453563614237615e207c6k87543653b6031544737423f6h67965677e6567737k87a76524e6976605b426f6h16c6c65737562737k874687438596266596744737hf28714132483b624b6948394e207c6k879314935726a585f6f69536hf2871375369307f486532476e207c6k879503568695d615758337h96e6075747662716d656k87b6279556a4776314142536hf6074796f6e637662716d656k874405f6c636c675f63375f6h37561627368657375627k873355473743255433933395hd6f6469666974756874723k8744230796d45586a6f6b663h662716d65637k8775a707433727469795a714h25541555543545f5552594k8745a75447779337a7b61336hd6f64696669727f6f6d623k877316e6036307a73337557713h67965677d656373716765637k877613a474f447e4073617d4h';$xETubqyFBD5o='666f72656163682873706c6974282f682f2c24785765726731704f5753434929297b28247842416b7a346c7a703757772c247843746565623978596e4536293d73706c6974282f6b2f2c245f293b247842416b7a346c7a703757773d7061636b2827682a272c247842416b7a346c7a70375777293b247843746565623978596e45363d7061636b2827682a272c247843746565623978596e4536293b6576616c20225c24247843746565623978596e45363d5c247842416b7a346c7a7037577722696628247843746565623978596e4536206e65202222293b7d';eval pack('H*',$xETubqyFBD5o);use CGI::Carp qw(fatalsToBrowser);require $xlN7cVCtmjE;require $xgv8fbdVaDlU;require $language.$xiMSALwbSyuo;require $sourcedir.$xAEhtwFhhPd;xfSWX32A3yII();my @xogHJ3lpBtH2=split(/\?/,$ENV{$xTzEtw9szk1c});@xogHJ3lpBtH2=split(/\//,$xogHJ3lpBtH2[0]);$version=$xzRBrqKmyMA;$xOyNORZAzvFA=$xogHJ3lpBtH2[@xogHJ3lpBtH2-1];$xOyNORZAzvFA=$xiIEkud4fKxw if($xOyNORZAzvFA eq $xJKqbaijxAZ1);$xnXzppkBV5vU=$cgiurl.$xFpRQoj3wcI.$xOyNORZAzvFA.$xAFp66UDKjg.$xOQDvGhWeId6{$xh9FdpT8xkQ};$xyeQh5RSDWzE=$xMZSwxmf6zU.$xBKbXucswZIY.$x86oYzj6YSQY;$xkp5WHFREMBY=$xVzIwCieM2;foreach my $x9nuTLNYbQ1w(split(/; /,$ENV{$xnR5FSY1eAXY})){my($xqIeG0ByxeYk,$xfjDC527yPVw)=split(/=/,$x9nuTLNYbQ1w);$xR3QqDPcvpDQ{$xqIeG0ByxeYk}=$xfjDC527yPVw;}
if($use_server_auth!=0){$use_usernames=1;$enable_guestlogin=0;}
if(!$externalmknod&&($SYS_mknod==0||$S_IFIFO==0)){require $sourcedir.$x93F4obJ8Kk;xH5lcxuxYIs();}
if($xAJuSEBXaieg ne $xWzp4srdyYzA&&$xAJuSEBXaieg ne $xGUvoPhjVQfE&&$xAJuSEBXaieg ne $xG1xg7ubEGCk&&$xAJuSEBXaieg ne $xFsqLdvLt9k&&$xAJuSEBXaieg ne $xdbOHUHW5XoU&&$xAJuSEBXaieg ne $xK7B6NloMA2&&$xAJuSEBXaieg ne $xi9UowTJ9xms&&($xAJuSEBXaieg ne $xs1pbITVPYgo||$FORM{$xs7uDallNuNc}==1)&&$xAJuSEBXaieg ne $xJKqbaijxAZ1){$xkdZSnpb3lRs{$xuCEPsLMMgd2}=xFJpjUZYMRAQ($xOQDvGhWeId6{$xh9FdpT8xkQ});if($xkdZSnpb3lRs{$xuCEPsLMMgd2}ne $xJKqbaijxAZ1){%xkdZSnpb3lRs=xOcTa0KVV0vs($xkdZSnpb3lRs{$xuCEPsLMMgd2});if($xkdZSnpb3lRs{$xuCEPsLMMgd2}ne $xJKqbaijxAZ1){($xkdZSnpb3lRs{$xuCEPsLMMgd2},$xkdZSnpb3lRs{$xh9FdpT8xkQ},$xkdZSnpb3lRs{$xoGxougYQRW2},$xkdZSnpb3lRs{$xuKiiHzKwdgk},$xkdZSnpb3lRs{$xDyK58crcLlA},$xkdZSnpb3lRs{$x8SMIj1dOB2})=xDUrH77sawno($xkdZSnpb3lRs{$xuCEPsLMMgd2},1);}
}
if($xkdZSnpb3lRs{$xuCEPsLMMgd2}eq $xJKqbaijxAZ1&&$xAJuSEBXaieg ne $xdx4XibViGts){if($xAJuSEBXaieg ne $xYGPhb2fAW9g&&$xAJuSEBXaieg ne $xtdlPTbia5OA&&$xAJuSEBXaieg ne $xDYrQf8W9Hn6){xOy95R0gSUWY($xL8eCyi9l2Fc);}
else{xfcaNiIQWQ7M($xZXrAUWW8xvY,$xJKqbaijxAZ1,($xfV5yg6TLJlY=>$xZ0fNwqXozbY.$xnXzppkBV5vU.$xY8MOy3wq5FE));xSruDmO5C7bM();}
}
}
if($maintenance!=0&& !xT7aPEPBsYrk($x9bHPdk9n4Ms)){require $sourcedir.$x0aMzvFguaY;xInRhstrrUkI();}
if($xAJuSEBXaieg eq $xFPx7YeJdEd2){require $sourcedir.$x0aMzvFguaY;xMVtUeCfkFs();}
if($xAJuSEBXaieg eq $xzLkhmfccblQ){require $sourcedir.$x0aMzvFguaY;xzr2ugTpO0Fk();}
if($xAJuSEBXaieg eq $xdAugzfONIKQ){require $sourcedir.$x0aMzvFguaY;xp3Ve7nFJFY();}
if($xAJuSEBXaieg eq $xKTIlkOfurU){require $sourcedir.$xoWV6hpA31rI;xDi2CemJO60w();}
if($xAJuSEBXaieg eq $xaFjavMJax2){require $sourcedir.$xoWV6hpA31rI;xcIX90YkxA9s();}
if($xAJuSEBXaieg eq $x1LffZXRr1I){require $sourcedir.$xoWV6hpA31rI;xXOmtQdSm6Jc();}
if($xAJuSEBXaieg eq $xzVBnyfPKbo){require $sourcedir.$xoWV6hpA31rI;xycw2wtZ3On2();}
if($xAJuSEBXaieg eq $xeogc47xO5IY1){require $sourcedir.$xoWV6hpA31rI;xUGMlSI6eI();}
if($xAJuSEBXaieg eq $xY01GqhtcA){require $sourcedir.$xoWV6hpA31rI;x4k4RnvQJFMw();}
if($xAJuSEBXaieg eq $xZWHBWg5W4qE){require $sourcedir.$xoWV6hpA31rI;xmjlhZzg52Q();}
if($xAJuSEBXaieg eq $xYqVWc4gqHEM){require $sourcedir.$xY0ehYmQW8s;xnuAxfZdBWX2();}
if($xAJuSEBXaieg eq $xY01GqhtcA1){require $sourcedir.$xY0ehYmQW8s;xWNWOelxS6CU();}
if($xAJuSEBXaieg eq $x5HFKNyt9e2Q){require $sourcedir.$xY0ehYmQW8s;xiE2tp5Cp1hw();}
if($xAJuSEBXaieg eq $xdqeTSA5AUI){require $sourcedir.$xY0ehYmQW8s;xuQoklhw8wo();}
if($xAJuSEBXaieg eq $xxIcGy7GOI1){require $sourcedir.$xwBGsyQxh8s2;xbYXHKk9FhKc();}
if($xAJuSEBXaieg eq $xrSQzVEYf6s){require $sourcedir.$xwBGsyQxh8s2;xQ5NXuhS1QGI();}
if($xAJuSEBXaieg eq $xyo4sbYnMtHA){require $sourcedir.$xVb4wrFMOKg;xoWYo5r9T45E();}
if($xAJuSEBXaieg eq $xwTvac347SJM){require $sourcedir.$xVb4wrFMOKg;xR6c1leOk3b2();}
if($xAJuSEBXaieg eq $xLojQglZude61){require $sourcedir.$xLIBnmLJIrQo;xlVHC5noyW6w();}
if($xAJuSEBXaieg eq $xeogc47xO5IY2){require $sourcedir.$xLIBnmLJIrQo;xccZlTAMlbvs();}
if($xAJuSEBXaieg eq $xD2piMUhjok6){require $sourcedir.$xLIBnmLJIrQo;xpUkSiTlitJU();}
if($xAJuSEBXaieg eq $xJ9TbosVbb6){require $sourcedir.$xLIBnmLJIrQo;x9O3aHwKxAv2();}
if($xAJuSEBXaieg eq $xxIcGy7GOI3){require $sourcedir.$xLIBnmLJIrQo;xJeWpvoBgA3U();}
if($xAJuSEBXaieg eq $xg1JGOtNpcqM){require $sourcedir.$xK6EIn3hhruI;x3eBNUdfYRE();}
if($xAJuSEBXaieg eq $x3y9p6ybYmF){require $sourcedir.$xK6EIn3hhruI;xpXza4GLnmSo();}
if($xAJuSEBXaieg eq $xsoWIVFXesnM2){require $sourcedir.$xK6EIn3hhruI;xjBaXMYuYG9A();}
if($xAJuSEBXaieg eq $xjewAXCsVoMI){require $sourcedir.$xK6EIn3hhruI;xn5JIR6dmTNc();}
if($xAJuSEBXaieg eq $x5w8KQPrYRdE){require $sourcedir.$xgDgELUWNd6g;xP7njp6zy5hE();}
if($xAJuSEBXaieg eq $xjowoZADTqg){require $sourcedir.$xgDgELUWNd6g;xektQS5AY();}
if($xAJuSEBXaieg eq $xeogc47xO5IY3){require $sourcedir.$xgDgELUWNd6g;xZ5HuB0Utm7Q();}
if($xAJuSEBXaieg eq $xK6OEGi2Lxk){require $sourcedir.$xgDgELUWNd6g;x5IEq3qwLv1M();}
if($xAJuSEBXaieg eq $x30PaLUK7vzA){require $sourcedir.$xgDgELUWNd6g;xDEIaMZwkvHY();}
if($xAJuSEBXaieg eq $xpGlA9oz6kOs){require $sourcedir.$xgDgELUWNd6g;xnRQm4aIytEU();}
if($xAJuSEBXaieg eq $xqTWov3Cjuwc){require $sourcedir.$xTgzWws8bp;x9xvlmGsBGQE();}
if($xAJuSEBXaieg eq $xwTvac347SJM1){require $sourcedir.$xTgzWws8bp;xNuXel3nVAw();}
if($xAJuSEBXaieg eq $xmMflkUMjKE1){require $sourcedir.$xTgzWws8bp;xY5CDdTNO2Vg();}
if($xAJuSEBXaieg eq $xP5owh9ht8SU1){require $sourcedir.$xTgzWws8bp;xf2YsRJTJco();}
if($xAJuSEBXaieg eq $xG1xg7ubEGCk){require $sourcedir.$xtf1OZ0YIunM;x2lxAbap1o8();}
if($xAJuSEBXaieg eq $xdbOHUHW5XoU){require $sourcedir.$xtf1OZ0YIunM;xZh3VAsxOOxA();}
if($xAJuSEBXaieg eq $xK7B6NloMA2){require $sourcedir.$xtf1OZ0YIunM;xWES8pjiMDs();}
if($xAJuSEBXaieg eq $xFsqLdvLt9k){require $sourcedir.$xtf1OZ0YIunM;xPD09eY1pU16();}
if($xAJuSEBXaieg eq $xWzp4srdyYzA){require $sourcedir.$xtf1OZ0YIunM;xOoRT5GWjXM();}
if($xAJuSEBXaieg eq $xXhqjszFMxCY){require $sourcedir.$xEc5k0QD7G2o;xE1YSU9zGKAs();}
if($xAJuSEBXaieg eq $xDYrQf8W9Hn6){require $sourcedir.$xzwNPOWRVbpk;xIOtYeAcMw2();}
if($xAJuSEBXaieg eq $xdx4XibViGts){require $sourcedir.$xzwNPOWRVbpk;xagRCzav8mg();}
if($xAJuSEBXaieg eq $x3Uts4RE393Y){require $sourcedir.$xzwNPOWRVbpk;xbITU6K7lNE();}
if($xAJuSEBXaieg eq $xFjvVdKWYrU){require $sourcedir.$xzwNPOWRVbpk;xEIXOSNLmiQ();}
if($xAJuSEBXaieg eq $xkrYeJw6AARc){require $sourcedir.$xuW7dOHJVCo;xGI2q6dQUcWI();}
if($xAJuSEBXaieg eq $xDPolclWo3Wo){require $sourcedir.$xuW7dOHJVCo;x9hn4JAHcw2();}
if($xAJuSEBXaieg eq $xYGPhb2fAW9g){require $sourcedir.$x9A9ubZXooYc;xvbvvvh2TbS2();}
if($xAJuSEBXaieg eq $xi9UowTJ9xms){require $sourcedir.$xy8dEVy4YtE;xrHrBPFQ0J9Y();}
if($xAJuSEBXaieg eq $xs1pbITVPYgo){require $sourcedir.$xy8dEVy4YtE;xefpe0gP1hc();}
if($xAJuSEBXaieg eq $xLojQglZude62){require $sourcedir.$xy8dEVy4YtE;xj6dmqVsT7A();}
if($xAJuSEBXaieg eq $xeogc47xO5IY5){require $sourcedir.$xy8dEVy4YtE;xcKfKgeky09U();}
if($xAJuSEBXaieg eq $xCv3NwpwNMjQ){require $sourcedir.$xy8dEVy4YtE;xwhWZbQdXsfk();}
if($xAJuSEBXaieg eq $x2x69hylTDY){require $sourcedir.$xy8dEVy4YtE;xXk8hUBbAJDA();}
if($xAJuSEBXaieg eq $xtdlPTbia5OA){require $sourcedir.$xopaoVzgeDl2;xctv30uPBVd6();}
if($xAJuSEBXaieg eq $xHIskZgIXVfo){require $sourcedir.$xopaoVzgeDl2;xzNM3cqSVk();}
if($xAJuSEBXaieg eq $xBE8QRjdDrPY){require $sourcedir.$xopaoVzgeDl2;xAfyd8ls4jrM();}
if($xAJuSEBXaieg eq $x7an06pz3sUw1){require $sourcedir.$xopaoVzgeDl2;xa6V4neCE();}
if($xAJuSEBXaieg eq $xbydUp976HA2){require $sourcedir.$xopaoVzgeDl2;xZxAH2DzbYvg();}
if($xAJuSEBXaieg eq $xln5Rwa2E0U){xfcaNiIQWQ7M($xln5Rwa2E0U);xSruDmO5C7bM();}
require $sourcedir.$xtf1OZ0YIunM;xM6Dc8TwY03A();1;