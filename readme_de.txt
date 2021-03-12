GTChat 0.92 Copyright (c) 2001 by Wladimir Palant

Aktuelle Informationen finden Sie unter <http://www.gtchat.de>. Wenn
Ihnen dieses Programm gefällt, lesen Sie sich bitte die
Registrierungsseite unter <http://www.gtchat.de/?register> durch.

Dieses Dokument ist eine Anleitung für die Installation/Update und
die Konfigurierung des Programms.



INHALT DIESER DATEI:

1. Überblick
2. Systemvoraussetzungen
3. Erstinstallation des Programms
4. Update von einer älteren Version
5. Weiterleitungsadresse einstellen
6. Farben, Schriftarten und -größen anpassen
7. Templates bearbeiten
8. JavaScript-Einstellungen



1. ÜBERBLICK

Was ist GTChat?
Bei GTChat handelt es sich um einen schnellen und komfortablen Chat, der
primär mit der Server-Push-Technik arbeitet. Der Ressourcenverbrauch
des Chats ist sehr niedrig, was sich aber in keinster Weise auf die
Leistung auswirkt. Für die Benutzer, die (meistens wegen einem schlecht
konfigurierten Proxy-Server) Server-Push nicht verwenden können, wird
ein alternatives Client-Pull-Modus bereitgestellt.


Was kostet GTChat?
GTChat ist Freeware, er darf auf nicht-kommerziellen Seiten kostenlos
eingesetzt werden. Änderungen am Programmtext (ausgenommen JavaScript)
sind jedoch _nicht_ gestattet.


Wie installiert man GTChat?
Wenn Sie diese Anleitung lesen, dann haben Sie wahrscheinlich bereits
das Archiv mit den Programm-Dateien bereits dekomprimiert. Sie müssen:

 - Falls eine andere Sprache als Deutsch verwendet werden soll, die
   Dateien durch die des entsprechenden Language Packs ersetzen
 - Den Upload der Daten auf Ihren Server vornehmen
 - Das Konfigurationsprogramm install.pl ausführen
 - Die Weiterleitungsadresse in index.html einstellen
 - Die Templates login.html und register.html für Ihre Seite anpassen
 - Sich mit Benutzername und Paßwort admin einloggen, das Paßwort für
   das Account sofort unter Profil ändern, Einstellungen anpassen,
   Räume erstellen und Chat-News festsetzen

Einige der Schritte sind im folgenden erklärt. Außerdem
finden Sie eine Anleitung, wie Sie das Aussehen des Chats ändern.
Bitte beachten Sie, daß Sie einen Editor benutzen müssen, der mit
UNIX-Zeilenumbrüchen klarkommt (also nicht Notepad).



2. SYSTEMVORAUSSETZUNGEN

Anforderungen an den Server:

 - Betriebssystem UNIX oder ein Derivat
 - Perl 5 oder höher
 - Kein Zeitlimit für Perl-Prozesse (wenn der Prozeß abgebrochen wird,
   muß sich der Benutzer neu einloggen)
 - SysV IPC freigegeben (bei einigen Providern wird die maximale Anzahl
   der IPC-Ressourcen festgelegt, diese beschränkt dann die Zahl der
   Chat-Nutzer) 
 - Schätzungsweise etwa 4 MB Arbeitsspeicher pro Benutzer (ein HTTPD- und ein
   Perl-Prozeß plus kurzzeitig Prozesse beim Schreiben) 

Anforderungen an den Client:

 - Internet Explorer ab 4.x oder Netscape Communicator ab 4.x. Opera
   im Client-Pull-Modus möglich, aber nicht empfehlenswert. Andere
   Browser wurden bisher nicht getestet. 
 - JavaScript aktiviert
 - Sofortige Weiterleitung der Daten durch den Proxy-Server. Dies ist
   mit Ausnahme der T-Online-Proxies meistens der Fall. Bei T-Online
   ist der Internet-Zugang auch ohne Proxy-Server benutzbar. Ansonsten
   wäre nur Client-Pull-Modus möglich. 
 - Keine Zeitbeschränkung für Verbindungen. Eine solche Zeitbeschränkung
   existiert bei Mannesmann Arcor, in diesem Fall ist der Client-Pull-Modus
   zu empfehlen. 



3. ERSTINSTALLATION DES PROGRAMMS

Erstellen Sie dann in Ihrem normalen HTML-Verzeichnis ein
Unterverzeichnis gtchat. Kopieren Sie dorthin mit Ihrem
FTP-Programm den Inhalt des Verzeichnisses www.

Erstellen Sie dann in Ihrem CGI-Verzeichnis auch ein Unterverzeichnis
gtchat und kopieren Sie den Inhalt des cgi-bin-Verzeichnisses
des Programms dorthin. Setzen Sie die Zugriffsrechte von install.pl
auf ausführbar und starten Sie das Programm über Ihren Browser.
Das Programm setzt dann die Verzeichniseinstellungen und die
Zugriffsrechte. Allerdings kann es vorkommen, daß die
Servereinstellungen die Änderung der Zugriffsrechte nicht erlauben,
folgen Sie dann den Anweisungen des Programms.



4. UPDATE VON EINER ÄLTEREN VERSION

Es empfiehlt sich, vor dem Update das Chat-Verzeichnis zu sichern.

Folgende Dateien müssen kopiert/ersetzt werden:
 - cgi-bin/Sources (das komplette Verzeichnis)
 - cgi-bin/chat.pl
 - cgi-bin/install.pl (ausführbar machen)
 - cgi-bin/german.descr
 - cgi-bin/german.lng (falls bereits Änderungen daran vorgenommen,
      kann auch der Teil angehängt werden, der mit der Marke
      Version 0.92 anfängt)
 - cgi-bin/Templates/message.html
 - cgi-bin/Templates/messages.html
 - www/chat.js
 - www/images/question.gif
 - eventuell www/commands.html und www/faq.html

Machen Sie install.pl auführbar und starten Sie es über Ihren Browser,
das Update der Daten wird dann durchgeführt.



5. WEITERLEITUNGSADRESSE EINSTELLEN

Erstmals, warum überhaupt Weiterleitung? Ich empfehle, bei Verweisen
auf den Chat stets die Datei index.html in Ihrem GTChat-Verzeichnis
anzugeben. Von dort aus wird der Benutzer sofort per JavaScript an die
eigentliche Adresse weitergeleitet. Damit wird sichergestellt, daß
JavaScript aktiviert ist. Denn falls nicht, bleibt der Benutzer bei
index.html und liest die Mitteilung dort.

Die Weiterleitung soll auf chat.pl im CGI-Verzeichnis erfolgen. Passen
Sie die entsprechende Adresse im JavaScript und in der Mitteilung
an.



6. FARBEN, SCHRIFTARTEN und -GRÖßEN ANPASSEN

GTChat ist so programmiert worden, daß alle Anpassungen der Farben und
Schriften einfach in der Datei style.css vorgenommen werden können,
ohne die Templates zu bearbeiten. Hier folgt die Liste der CSS-Klassen
und ihrer Funktionen:

A                  Das sind die Definitionen für die Links, die sich
A:active           innerhalb von Tabellen befinden (active - aktiver
A:hover            Link, hover - Link, der unter dem Mauszeiger liegt).
                   Nicht angegebene Attribute werden vom Kontext übernommen.
                   Man könnte auch A:visited festlegen, jedoch macht
                   eine unterschiedliche Darstellung besuchter Links bei
                   einem Chat keinen Sinn.

#stdlink           Diese Definitionen gelten für die Links, die sich
A#stdlink:active   außerhalb von Tabellen befinden (active - aktiver
A#stdlink:hover    Link, hover - Link, der unter dem Mauszeiger liegt).
                   Wenn Sie die Templates ändern und einen Link außerhalb
                   einer Tabelle anbringen, sollte immer id=stdlink dabeistehen:
                          <a href="file.html" id=stdlink>
                   Falls sich diese nicht von den anderen Links unterscheiden
                   sollen, können diese Klassen gelöscht werden. Nicht
                   angegebene Attribute werden vom Kontext übernommen.

TD                 Das sind die Standardeinstellungen für den Text innerhalb
#normaltext        von Tabellen. #normaltext sollte dasselbe wie TD sein, es
                   wird dazu benutzt, diese Formatierung zu erzwingen, falls
                   das nicht automatisch passiert.

#smalltext         Verkleinerte Version von TD, wird z.B. für die Anzeige des
                   Datums in der Liste der IP-Sperren benutzt. Alle nicht
                   angegebenen Attribute werden von TD übernommen.

TH                 Definiert den Text und Hintergrundfarbe von
                   Tabellenüberschriften.

#table1            Definiert die Hintergrundfarbe von Tabellenzeilen, die
                   besonders hervorgehoben werden sollen, wie z.B. die
                   Raum-Namen auf der Login-Seite des Chats.

#table2            Standard-Hintergrundfarbe von Tabellenzeilen.

#lines             Linienfarbe für Tabellen. Bitte beachten: das Attribut,
                   das gesetzt werden muß, ist nicht color, sondern
                   background-color!

#body              Hier werden die Standardwerte für Schriftart und Farben
                   festgelegt. Z.B. werden alle Chat-Meldungen in der Standardfarbe
                   angezeigt. Die Hintergrundfarbe gilt für den kompletten Chat.
                   Damit das funktioniert, muß in sämtlichen HTML-Dateien der Text
                   id=body beim BODY-Tag bleiben.

#headertext        Standardformatierung des Textes außerhalb von Tabellen.
                   Falls Sie die Templates ändern sollten und Text außerhalb
                   von Tabellen anbringen, sollten Sie diesen mit <div> </div>
                   umschließen.

#bigheadertext     Vergrößerte Version von headertext, wird z.B. in der
                   Chat-Hilfe benutzt.



7. TEMPLATES BEARBEITEN

Die Chat-Templates sind normale HTML-Dateien, die aber bestimmte Marken
enthalten, die der Chat durch die eigenen Daten ersetzt. Drei der Marken
sind universell, können also in jedem Template vorkommen:

{CHATNAME}    Wird durch den Wert von $chatname aus Settings.dat ersetzt,
              wird normalerweise für die Überschrift der HTML-Datei
              verwendet.

{CGI}         Wird durch die URL von chat.pl ersetzt, wobei der Parameter
              id bereits enthalten ist. Wenn also zusätzliche Parameter
              angehängt werden sollen, schreibt man das z.B. so:
                     {CGI}&action=allusers

{HTMLURL}     Wird durch $htmlurl aus Settings.dat ersetzt. Diese Marke
              wird in fast allen Templates in folgender Form verwendet:
                     <base href="{HTMLURL}">
              Damit braucht man dann für die Dateien im HTML-Verzeichnis
              des Chats keinen Pfad mehr anzugeben.

Alle anderen Marken sind nur in bestimmten Templates definiert.
Zu beachten: alle außer den universellen Marken _müssen_ in einer
eigenen Zeile stehen, ohne führende und nachfolgende Leerzeichen.

Wenn man den Chat installiert, sollte man die Templates login.html
und register.html anpassen (Logo, Begrüssungstext usw.). Falls man
in chat.html die Frames umordnet, sollte man auf jeden Fall die Namen
der Frames beibehalten. Eine detailierte Beschreibung der Templates
und der verwendeten Marken soll bald verfügbar sein, für aktuelle
Informationen schauen Sie auf <http://www.gtchat.de>.



8. JAVASCRIPT-EINSTELLUNGEN

Am Anfang von chat.js können folgende Variablen gesetzt werden:

roomlistdelay          Zeitliche Verzögerung (in Millisekunden), mit
Voreinstellung: 10000  der die Raumliste erscheinen soll. Die Standardvorlagen
                       von GTChat zeigen an der Stelle der Raumliste zuerst
                       das Logo an. Falls Sie das Logo nicht anzeigen
                       wollen oder es in ein anderes Frame plaziert haben,
                       können Sie hier 0 einstellen.

scrolldelay            Zeitlicher Abstand (in Millisekunden), in dem das
Voreinstellung: 150    Textfenster runtergescrollt wird (falls nicht vom
                       Benutzer deaktiviert).

aliveinterval          Zeitlicher Abstand (in Millisekunden), in dem der
Voreinstellung: 50000  Chat einen /alive-Befehl an den Server senden soll
                       um anzuzeigen, daß der Benutzer noch da ist. Der Server
                       prüft seinerseits in Abständen, die in Settings.dat durch
                       $alivetestrate festgelegt sind, ob seit der letzten
                       Überprüfung ein solcher Befehl eingegangen ist. Ich
                       empfehle, aliveinterval auf etwas unter der Hälfte des
                       Wertes von $alivetestrate zu setzen - sicher ist sicher.

refreshdelay           Nur relevant für den Client-Pull-Modus. Legt den
Voreinstellung: 6000   zeitlicher Abstand (in Millisekunden) fest, in dem
                       der Chat neue Nachrichten vom Server anfordern soll.
                       Bemerkung: Neue Nachrichten werden außerdem immer dann
                       angefordert, wenn der Benutzer einen Text sendet.

logoutpage             Fall angegeben, wird beim Logout nicht die Login-Seite
Voreinstellung: ""     des Chats, sondern die Seite unter dieser URL angezeigt.

autokick               Fall von Null verschieden, wird ein Benutzer, der länger
Voreinstellung: 0      als diese Anzahl von Sekunden nichts geschrieben hat,
                       automatisch aus dem Chat geschmissen (mit Vorwarnung).

Die korrekte Funktion des Chats ist wesentlich abhängig von einem korrekt
funktionierenden JavaScript. Deswegen sollten Sie nur dann Änderungen
an den JavaScript-Funktionen vornehmen, wenn Sie genau wissen, was Sie
tun. Bei Problemen, die aus solchen Änderungen resultieren, werde ich
wahrscheinlich keine Hilfe bieten können. Eine detailierte Beschreibung
der JavaScript-Funktionen soll bald verfügbar sein, für aktuelle
Informationen schauen Sie auf <http://www.gtchat.de>.
