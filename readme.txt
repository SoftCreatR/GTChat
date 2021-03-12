Anleitung auf Deutsch weiter unten

===========================================

Disclaimer: this release is ALPHA, it should be used
only for testing purposes. The program is still far
from being complete, there is no installation program
or real help. You should only start installing it if
you have experience with CGI and can do it with this
short instruction. If you cannot - just don't.

How to install:

 - upload the files to the server, the cgi-bin directory
   to some location where the files can be executed, the www
   directory to a normal HTML directory.
 - set permissions for the files in cgi-bin, executable for
   chat.pl and the subdirectories (700 schould be ok on most
   servers, sometimes you will need 777 however), writable for
   all other files (600 for most servers, on some 666).
 - adjust the perl path in the first line of chat.pl if necessary
 - adjust Settings.dat, typically you have to change to get the chat
   working:

	urls.htmlurl - URL of the directory with chat.js and style.css
	urls.chaturl - complete URL of chat.pl
	directories.wwwdir - path to the www directory of the chat,
			relative to the directory of chat.pl (this settings isn't
			used yet, but it will be in next versions)
	directories.imagesurl - path to the images directory of the chat
			(usually {wwwdir}/images), relative to the directory of
			chat.pl, e.g. '../../public_html/gtchat/images'

	lock_type - change to 2 if you have an Windows 9x/ME server

	custom_subs.sendMail - change to 'plugindir::MailModules/SMTPModule.pm'
			if you are using Windows or don't have Sendmail for any other
			reason. Change smpt_server as well then.

	custom_subs.createPipe, custom_subs.openPipe, custom_subs.removePipe -
			change to 'plugindir::PipeModules/Win32PipeModule.pm' if you are
			using a Windows NT/2000/XP server. You need the Perl module
			Win32::Pipe for this one, at least release 20020325! There is no
			working pipe module for Windows 9x/ME yet, use only safe mode then.

 - go to the chat URL and login with username 'admin' and password 'admin',
   change the password immediately.

Restrictions of this version:

 - Server push mode is not possible with Windows 9x/ME. The usage of this operating
   system is strongly discouraged anyway.
 - Bugs in Apache 1.3/Windows implementation make server push
   mode on Windows NT/2000/XP impossible as well. Only Apache 2.0
   (with mod_perl 2.0 or without it) allows it, but this one is still
   very unstable.
 - Furthermore there should be still an enourmous number of bug - again,
   this is an ALPHA release.

Credits:

 * Martin Mewes (www.mamemu.de), the project GTChat wouldn't exist now
   without his starting help
 * Christian Hacker (www.netdepot-is.net) provides the webspace and the
   domain for the project
 * Joerg H. Arnu (www.dreamlandresort.com) helped a lot with the translation
   to English
 * Frank Isemann created an inofficiall support forum
 * Luba Zelenskaya (www.wantbaby.ru) created the chat smileys
 * Marianne Kolodii (www.daretodream.kiev.ua) helped with design tips
 * and many, many others who helped to improve GTChat with their work and
   their suggestions


===========================================

Disclaimer: Das ist eine ALPHA-Version und ausschlie�lich
zum Testen gedacht. Wer diese Version f�r regul�ren Betrieb
einsetzt, ist selber Schuld! Das Programm ist noch weit davon
entfernt, komplett zu sein, eine Installationshilfe gibt es
nicht. Sie sollten nur dann mit der Installation anfangen, wenn
Sie Erfahrung mit CGI haben und mit dieser knappen Anleitung
klarkommen. Falls nicht - lassen Sie das einfach.

Wie man installiert:

 - die Dateien auf den Server hochladen, das Verzeichnis cgi-bin irgendwohin,
   wo Skripte ausgef�hrt werden d�rfen, und das Verzeichnis www
   in ein normales HTML-Verzeichnis.
 - Zugriffsrechte f�r die Dateien im cgi-bin-Verzeichnis setzen,
   ausf�hrbar f�r chat.pl und alle Verzeichnisse (700 funktioniert auf meisten Servern,
   manchmal braucht mal aber 777) und �nderbar f�r alle anderen
   Dateien (f�r gew�hnlich 600, auf manchen Servern 666).
 - Perl-Pfad in der ersten Zeile von chat.pl anpassen, falls n�tig
 - Settings.dat �ndern. Normalerweise sollten angepa�t werden, um
   den Chat zum Laufen zu bringen:

	urls.htmlurl - URL des Verzeichnisses mit chat.js und style.css
	urls.chaturl - komplette URL von chat.pl
	directories.wwwdir - Pfad zu dem www-Verzeichnis des Chats, mu�
			relativ zum Verzeichnis von chat.pl angegeben werden
			(diese Einstellung wird noch nicht nicht verwendet, wird
			aber in zuk�nftigen Versionen gebraucht werden)
	directories.imagesurl - Pfad zu dem images-Verzeichnis des Chats
			(normalerweise {wwwdir}/images), mu� relativ zum Verzeichnis
			von chat.pl angegeben werden, z.B. '../../public_html/gtchat/images'

	lock_type - f�r einen Windows 9x/ME-Server auf 2 setzen

	custom_subs.sendMail - auf 'plugindir::MailModules/SMTPModule.pm'
			�ndern, falls Windows benutzt wird, oder aus irgendeinem
			anderen Grund sendmail nicht verwendet werden kann. In diesem
			Fall mu� auch smpt_server angepa�t werden.

	custom_subs.createPipe, custom_subs.openPipe, custom_subs.removePipe -
			auf 'plugindir::PipeModules/Win32PipeModule.pm' �ndern, falls
			Windows NT/2000/XP benutzt wird. F�r diesen braucht man das
			Perl-Module Win32::Pipe, mindestens Release 20020325! Es gibt
			derzeit kein funktionierendes Pipe-Modul f�r Windows 9x/ME, dort
			kann also nur der sichere Modus verwendet werden.

 - sich im Chat mit dem Benutzernamen 'admin' und Pa�wort 'admin' einloggen,
   das Pa�wort sollte man sofort �ndern.

Einschr�nkungen dieser Version:

 - Server-Push-Modus ist mit Windows 9x/ME derzeit nicht m�glich. Auch
   allgemein wird die Benutzung dieses Betriebssystems nicht empfohlen.
 - Bugs in der Apache 1.3/Windows implementierung machen auch unter
   Windows NT/2000/XP den Server-Push-Modus unm�glich. Das geht erst mit
   Apache 2.0 (evtl. mit mod_perl 2.0), aber dieses ist noch sehr instabil.
 - Au�erdem sollte noch eine riesige Anzahl an Bugs drin sein - noch einmal,
   das ist eine ALPHA-Version.

Danksagungen:

 * Martin Mewes (www.mamemu.de), f�r die Starthilfe, ohne die das Projekt
   GTChat nie zustandegekommen w�re
 * Christian Hacker (www.netdepot-is.net), f�r die gro�zugige Bereitstellung
   von Webspace und der Domain f�r das Projekt
 * Joerg H. Arnu (www.dreamlandresort.com), f�r die st�ndige Hilfe bei der
   English-�bersetzung
 * Frank Isemann, f�r die Einrichtung eines inoffiziellen Support-Forums
 * Luba Zelenskaya (www.wantbaby.ru), f�r die ausgezeichneten Smileys
 * Marianne Kolodii (www.daretodream.kiev.ua), f�r ihre Design-Tipps
 * und die vielen, vielen anderen, die durch ihre Vorschl�ge und
   Beitr�ge das Projekt GTChat vorangebracht haben
