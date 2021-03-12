GTChat 0.92 Copyright (c) 2001 by Wladimir Palant

Aktuelle Informationen finden Sie unter <http://www.gtchat.de>. Wenn
Ihnen dieses Programm gef�llt, lesen Sie sich bitte die
Registrierungsseite unter <http://www.gtchat.de/?register> durch.

Dieses Dokument ist eine Anleitung f�r die Installation/Update und
die Konfigurierung des Programms.



INHALT DIESER DATEI:

1. �berblick
2. Systemvoraussetzungen
3. Erstinstallation des Programms
4. Update von einer �lteren Version
5. Weiterleitungsadresse einstellen
6. Farben, Schriftarten und -gr��en anpassen
7. Templates bearbeiten
8. JavaScript-Einstellungen



1. �BERBLICK

Was ist GTChat?
Bei GTChat handelt es sich um einen schnellen und komfortablen Chat, der
prim�r mit der Server-Push-Technik arbeitet. Der Ressourcenverbrauch
des Chats ist sehr niedrig, was sich aber in keinster Weise auf die
Leistung auswirkt. F�r die Benutzer, die (meistens wegen einem schlecht
konfigurierten Proxy-Server) Server-Push nicht verwenden k�nnen, wird
ein alternatives Client-Pull-Modus bereitgestellt.


Was kostet GTChat?
GTChat ist Freeware, er darf auf nicht-kommerziellen Seiten kostenlos
eingesetzt werden. �nderungen am Programmtext (ausgenommen JavaScript)
sind jedoch _nicht_ gestattet.


Wie installiert man GTChat?
Wenn Sie diese Anleitung lesen, dann haben Sie wahrscheinlich bereits
das Archiv mit den Programm-Dateien bereits dekomprimiert. Sie m�ssen:

 - Falls eine andere Sprache als Deutsch verwendet werden soll, die
   Dateien durch die des entsprechenden Language Packs ersetzen
 - Den Upload der Daten auf Ihren Server vornehmen
 - Das Konfigurationsprogramm install.pl ausf�hren
 - Die Weiterleitungsadresse in index.html einstellen
 - Die Templates login.html und register.html f�r Ihre Seite anpassen
 - Sich mit Benutzername und Pa�wort admin einloggen, das Pa�wort f�r
   das Account sofort unter Profil �ndern, Einstellungen anpassen,
   R�ume erstellen und Chat-News festsetzen

Einige der Schritte sind im folgenden erkl�rt. Au�erdem
finden Sie eine Anleitung, wie Sie das Aussehen des Chats �ndern.
Bitte beachten Sie, da� Sie einen Editor benutzen m�ssen, der mit
UNIX-Zeilenumbr�chen klarkommt (also nicht Notepad).



2. SYSTEMVORAUSSETZUNGEN

Anforderungen an den Server:

 - Betriebssystem UNIX oder ein Derivat
 - Perl 5 oder h�her
 - Kein Zeitlimit f�r Perl-Prozesse (wenn der Proze� abgebrochen wird,
   mu� sich der Benutzer neu einloggen)
 - SysV IPC freigegeben (bei einigen Providern wird die maximale Anzahl
   der IPC-Ressourcen festgelegt, diese beschr�nkt dann die Zahl der
   Chat-Nutzer) 
 - Sch�tzungsweise etwa 4 MB Arbeitsspeicher pro Benutzer (ein HTTPD- und ein
   Perl-Proze� plus kurzzeitig Prozesse beim Schreiben) 

Anforderungen an den Client:

 - Internet Explorer ab 4.x oder Netscape Communicator ab 4.x. Opera
   im Client-Pull-Modus m�glich, aber nicht empfehlenswert. Andere
   Browser wurden bisher nicht getestet. 
 - JavaScript aktiviert
 - Sofortige Weiterleitung der Daten durch den Proxy-Server. Dies ist
   mit Ausnahme der T-Online-Proxies meistens der Fall. Bei T-Online
   ist der Internet-Zugang auch ohne Proxy-Server benutzbar. Ansonsten
   w�re nur Client-Pull-Modus m�glich. 
 - Keine Zeitbeschr�nkung f�r Verbindungen. Eine solche Zeitbeschr�nkung
   existiert bei Mannesmann Arcor, in diesem Fall ist der Client-Pull-Modus
   zu empfehlen. 



3. ERSTINSTALLATION DES PROGRAMMS

Erstellen Sie dann in Ihrem normalen HTML-Verzeichnis ein
Unterverzeichnis gtchat. Kopieren Sie dorthin mit Ihrem
FTP-Programm den Inhalt des Verzeichnisses www.

Erstellen Sie dann in Ihrem CGI-Verzeichnis auch ein Unterverzeichnis
gtchat und kopieren Sie den Inhalt des cgi-bin-Verzeichnisses
des Programms dorthin. Setzen Sie die Zugriffsrechte von install.pl
auf ausf�hrbar und starten Sie das Programm �ber Ihren Browser.
Das Programm setzt dann die Verzeichniseinstellungen und die
Zugriffsrechte. Allerdings kann es vorkommen, da� die
Servereinstellungen die �nderung der Zugriffsrechte nicht erlauben,
folgen Sie dann den Anweisungen des Programms.



4. UPDATE VON EINER �LTEREN VERSION

Es empfiehlt sich, vor dem Update das Chat-Verzeichnis zu sichern.

Folgende Dateien m�ssen kopiert/ersetzt werden:
 - cgi-bin/Sources (das komplette Verzeichnis)
 - cgi-bin/chat.pl
 - cgi-bin/install.pl (ausf�hrbar machen)
 - cgi-bin/german.descr
 - cgi-bin/german.lng (falls bereits �nderungen daran vorgenommen,
      kann auch der Teil angeh�ngt werden, der mit der Marke
      Version 0.92 anf�ngt)
 - cgi-bin/Templates/message.html
 - cgi-bin/Templates/messages.html
 - www/chat.js
 - www/images/question.gif
 - eventuell www/commands.html und www/faq.html

Machen Sie install.pl auf�hrbar und starten Sie es �ber Ihren Browser,
das Update der Daten wird dann durchgef�hrt.



5. WEITERLEITUNGSADRESSE EINSTELLEN

Erstmals, warum �berhaupt Weiterleitung? Ich empfehle, bei Verweisen
auf den Chat stets die Datei index.html in Ihrem GTChat-Verzeichnis
anzugeben. Von dort aus wird der Benutzer sofort per JavaScript an die
eigentliche Adresse weitergeleitet. Damit wird sichergestellt, da�
JavaScript aktiviert ist. Denn falls nicht, bleibt der Benutzer bei
index.html und liest die Mitteilung dort.

Die Weiterleitung soll auf chat.pl im CGI-Verzeichnis erfolgen. Passen
Sie die entsprechende Adresse im JavaScript und in der Mitteilung
an.



6. FARBEN, SCHRIFTARTEN und -GR��EN ANPASSEN

GTChat ist so programmiert worden, da� alle Anpassungen der Farben und
Schriften einfach in der Datei style.css vorgenommen werden k�nnen,
ohne die Templates zu bearbeiten. Hier folgt die Liste der CSS-Klassen
und ihrer Funktionen:

A                  Das sind die Definitionen f�r die Links, die sich
A:active           innerhalb von Tabellen befinden (active - aktiver
A:hover            Link, hover - Link, der unter dem Mauszeiger liegt).
                   Nicht angegebene Attribute werden vom Kontext �bernommen.
                   Man k�nnte auch A:visited festlegen, jedoch macht
                   eine unterschiedliche Darstellung besuchter Links bei
                   einem Chat keinen Sinn.

#stdlink           Diese Definitionen gelten f�r die Links, die sich
A#stdlink:active   au�erhalb von Tabellen befinden (active - aktiver
A#stdlink:hover    Link, hover - Link, der unter dem Mauszeiger liegt).
                   Wenn Sie die Templates �ndern und einen Link au�erhalb
                   einer Tabelle anbringen, sollte immer id=stdlink dabeistehen:
                          <a href="file.html" id=stdlink>
                   Falls sich diese nicht von den anderen Links unterscheiden
                   sollen, k�nnen diese Klassen gel�scht werden. Nicht
                   angegebene Attribute werden vom Kontext �bernommen.

TD                 Das sind die Standardeinstellungen f�r den Text innerhalb
#normaltext        von Tabellen. #normaltext sollte dasselbe wie TD sein, es
                   wird dazu benutzt, diese Formatierung zu erzwingen, falls
                   das nicht automatisch passiert.

#smalltext         Verkleinerte Version von TD, wird z.B. f�r die Anzeige des
                   Datums in der Liste der IP-Sperren benutzt. Alle nicht
                   angegebenen Attribute werden von TD �bernommen.

TH                 Definiert den Text und Hintergrundfarbe von
                   Tabellen�berschriften.

#table1            Definiert die Hintergrundfarbe von Tabellenzeilen, die
                   besonders hervorgehoben werden sollen, wie z.B. die
                   Raum-Namen auf der Login-Seite des Chats.

#table2            Standard-Hintergrundfarbe von Tabellenzeilen.

#lines             Linienfarbe f�r Tabellen. Bitte beachten: das Attribut,
                   das gesetzt werden mu�, ist nicht color, sondern
                   background-color!

#body              Hier werden die Standardwerte f�r Schriftart und Farben
                   festgelegt. Z.B. werden alle Chat-Meldungen in der Standardfarbe
                   angezeigt. Die Hintergrundfarbe gilt f�r den kompletten Chat.
                   Damit das funktioniert, mu� in s�mtlichen HTML-Dateien der Text
                   id=body beim BODY-Tag bleiben.

#headertext        Standardformatierung des Textes au�erhalb von Tabellen.
                   Falls Sie die Templates �ndern sollten und Text au�erhalb
                   von Tabellen anbringen, sollten Sie diesen mit <div> </div>
                   umschlie�en.

#bigheadertext     Vergr��erte Version von headertext, wird z.B. in der
                   Chat-Hilfe benutzt.



7. TEMPLATES BEARBEITEN

Die Chat-Templates sind normale HTML-Dateien, die aber bestimmte Marken
enthalten, die der Chat durch die eigenen Daten ersetzt. Drei der Marken
sind universell, k�nnen also in jedem Template vorkommen:

{CHATNAME}    Wird durch den Wert von $chatname aus Settings.dat ersetzt,
              wird normalerweise f�r die �berschrift der HTML-Datei
              verwendet.

{CGI}         Wird durch die URL von chat.pl ersetzt, wobei der Parameter
              id bereits enthalten ist. Wenn also zus�tzliche Parameter
              angeh�ngt werden sollen, schreibt man das z.B. so:
                     {CGI}&action=allusers

{HTMLURL}     Wird durch $htmlurl aus Settings.dat ersetzt. Diese Marke
              wird in fast allen Templates in folgender Form verwendet:
                     <base href="{HTMLURL}">
              Damit braucht man dann f�r die Dateien im HTML-Verzeichnis
              des Chats keinen Pfad mehr anzugeben.

Alle anderen Marken sind nur in bestimmten Templates definiert.
Zu beachten: alle au�er den universellen Marken _m�ssen_ in einer
eigenen Zeile stehen, ohne f�hrende und nachfolgende Leerzeichen.

Wenn man den Chat installiert, sollte man die Templates login.html
und register.html anpassen (Logo, Begr�ssungstext usw.). Falls man
in chat.html die Frames umordnet, sollte man auf jeden Fall die Namen
der Frames beibehalten. Eine detailierte Beschreibung der Templates
und der verwendeten Marken soll bald verf�gbar sein, f�r aktuelle
Informationen schauen Sie auf <http://www.gtchat.de>.



8. JAVASCRIPT-EINSTELLUNGEN

Am Anfang von chat.js k�nnen folgende Variablen gesetzt werden:

roomlistdelay          Zeitliche Verz�gerung (in Millisekunden), mit
Voreinstellung: 10000  der die Raumliste erscheinen soll. Die Standardvorlagen
                       von GTChat zeigen an der Stelle der Raumliste zuerst
                       das Logo an. Falls Sie das Logo nicht anzeigen
                       wollen oder es in ein anderes Frame plaziert haben,
                       k�nnen Sie hier 0 einstellen.

scrolldelay            Zeitlicher Abstand (in Millisekunden), in dem das
Voreinstellung: 150    Textfenster runtergescrollt wird (falls nicht vom
                       Benutzer deaktiviert).

aliveinterval          Zeitlicher Abstand (in Millisekunden), in dem der
Voreinstellung: 50000  Chat einen /alive-Befehl an den Server senden soll
                       um anzuzeigen, da� der Benutzer noch da ist. Der Server
                       pr�ft seinerseits in Abst�nden, die in Settings.dat durch
                       $alivetestrate festgelegt sind, ob seit der letzten
                       �berpr�fung ein solcher Befehl eingegangen ist. Ich
                       empfehle, aliveinterval auf etwas unter der H�lfte des
                       Wertes von $alivetestrate zu setzen - sicher ist sicher.

refreshdelay           Nur relevant f�r den Client-Pull-Modus. Legt den
Voreinstellung: 6000   zeitlicher Abstand (in Millisekunden) fest, in dem
                       der Chat neue Nachrichten vom Server anfordern soll.
                       Bemerkung: Neue Nachrichten werden au�erdem immer dann
                       angefordert, wenn der Benutzer einen Text sendet.

logoutpage             Fall angegeben, wird beim Logout nicht die Login-Seite
Voreinstellung: ""     des Chats, sondern die Seite unter dieser URL angezeigt.

autokick               Fall von Null verschieden, wird ein Benutzer, der l�nger
Voreinstellung: 0      als diese Anzahl von Sekunden nichts geschrieben hat,
                       automatisch aus dem Chat geschmissen (mit Vorwarnung).

Die korrekte Funktion des Chats ist wesentlich abh�ngig von einem korrekt
funktionierenden JavaScript. Deswegen sollten Sie nur dann �nderungen
an den JavaScript-Funktionen vornehmen, wenn Sie genau wissen, was Sie
tun. Bei Problemen, die aus solchen �nderungen resultieren, werde ich
wahrscheinlich keine Hilfe bieten k�nnen. Eine detailierte Beschreibung
der JavaScript-Funktionen soll bald verf�gbar sein, f�r aktuelle
Informationen schauen Sie auf <http://www.gtchat.de>.
