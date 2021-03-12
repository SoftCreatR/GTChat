GTChat 0.92 Copyright (c) 2001 by Wladimir Palant

You can find up to date information on <http://www.gtchat.de>. If
you like this program, please read my registration page on
<http://www.gtchat.de/main_en?register_en>.

This document should help you install/update GTChat.



CONTENTS:

1. Overview
2. System requirements
3. First installation
4. Updating older versions
5. Changing forwarding address
6. Changing colors and fonts
7. Modifying templates
8. JavaScript options



1. OVERVIEW

What is GTChat?
GTChat is a fast and comfortable webchat application. Due to use of
server push technology and working without a database like mySQL it
uses only little server resources, which of course won't affect the
performance. Some users have problems with server push because
of their proxy servers. For those users there is also a client pull
mode.


What does GTChat cost?
GTChat is freeware, it may be used for free on non-commercial
websites. However changing the program code (besides JavaScript)
is _not_ permitted. For more read license.txt.


How can I install GTChat?
If you can read this file you've probably already decompressed the
program files. Next steps you have to do:

 - replace the files by those of the according Language Pack if
   you want to have any other language than German
 - upload the files to the server
 - execute the configuration program install.pl
 - adjust the forwarding address in index.html
 - adjust the templates login.html and register.html to fit your
   website
 - login with username/password admin, change the password
   immediately in your profile, change the settings,
   create rooms und set chat news

Some of those are explained more detailed in the following.
Furthermore you will find instructions for changing the layout
of the chat in this file. You should use an editor which is able
to work with UNIX-style line breaks (which means not Notepad).



2. SYSTEM REQUIREMENTS

Requirements on the server's side:

 - UNIX or UNIX-like operating system 
 - Perl 5 or higher 
 - No time limit for Perl processes (if a process is killed, the
   user must login again) 
 - Tolerant IPC limits (some servers have 16 as the maximum number
   of IPC queues, this restricts the maximum number of chat users
   then)
 - Approximately 4 MB memory for every user (one HTTPD and one Perl process plus additional processes for a short time when writing) 

Requirements on the client's side:

 - Internet Explorer 4.x or higher, Netscape Communicator 4.x or higher.
   Opera only possible in client pull mode, but not advisable. Other
   browsers have not been tested yes.
 - JavaScript activated
 - Forwarding of the data by the proxy server without delay. In Germany
   most proxy servers do so besides T-Online. Fortunately using proxy
   server ist not mandatory for T-Online users. Otherwise only client
   pull mode would be possible.
 - No time limit for connection. Proxy servers of Mannesmann Arcor are
   configured this way, using client pull mode is advisable.



3. FIRST INSTALLATION

Create a subdirectory gtchat in you HTML directory. Copy
the contents of the directory www into that directory with you
FTP client.

Also create a subdirectory gtchat in your CGI directory and copy
the contents of the directory cgi-bin there. Set the execution
permissions of install.pl with your FTP client and start it
with your browser. The program will adjust directory settings
and file permisions. With some server configurations it is not
possible to adjust permissions automatically, follow the instructions
of the program then.



4. UPDATING OLDER VERSION

You should save your chat directory before doing an update.

Following files have to been updated:
 - cgi-bin/Sources (the complete directory)
 - cgi-bin/chat.pl
 - cgi-bin/install.pl (make it executable)
 - cgi-bin/english.descr (or other language files, depending on
      language pack)
 - cgi-bin/english.lng
 - cgi-bin/Templates/message.html
 - cgi-bin/Templates/messages.html
 - www/chat.js
 - www/images/question.gif
 - www/commands.html
 - www/faq.html

Make install.pl executable and start it with your browser,
the data files will be updated then.



5. CHANGING FORWARDING ADDRESS

First of all, why forwarding? I recommend to make the chat link
show to index.html in your GTChat HTML directory. This file
forwards the user to the chat script using JavaScript then.
This is a check if the user has his JavaScripts activated. 
If he doesn't he stays on index.html and gets the error message
on the screen.

The user should be forwarded to chat.pl in the CGI directory.
You should ajust this link in the JavaScript part and in the
message.



6. CHANGING COLORS AND FONTS

GTChat allows to do all the modifications in colors and fonts
in the file style.css. Here is the list of the CSS-classes and
their functions:

A                  Definitions for the links inside the tables
A:active           (active - active link, hover - Link underneath
A:hover            the mouse pointer). Non defined attributes will be
                   taken from the context of the link. A:visited
                   could be defined as well, but in a chat this is
                   is of no use, right?

#stdlink           These definitions are for the links outside the
A#stdlink:active   tables (active - active link, hover - Link
A#stdlink:hover    underneath the mouse pointer). When changing a
                   template, you should add the tag id=stdlink to
                   all links outside the tables like this:
                         <a href="file.html" id=stdlink>
                   If you don't need to distinct these links from
                   the normal ones, then you can erase these classes.
                   Non defined attributes will be taken from
                   context of the link. 

TD                 Standard settings for text inside of tables.
#normaltext        #normaltext should be the same as TD, it will be
                   used to force formatting of the text in the same way
                   if it doesn't happen automatically.

#smalltext         Smaller version of TD, for example used to display
                   the dates in the list of IP-bans. Not defined
                   attributes are taken from TD.

TH                 Defines text and background color of table headers.

#table1            Defines the background color of table cells which
                   have to be accentuated like for example the room
                   names at the login-page of the chat.

#table2            Default background color for the table cells.

#lines             Border color for the tables. Pay attention, the
                   attribute that has to be set is not color
                   but background-color!

#body              Here the standard settings for fonts and colors are
                   stored. For example all the chat messages are
                   displayed in this color. The background color is
                   used for the complete chat. It works only if you
                   have id=body in all BODY tags.

#headertext        Default style for the text outside the tables. If
                   you change the templates and add text outside the
                   tables, enclose it with <div id=headertext> </div>.

#bigheadertext     Bigger version of #headertext used for example in
                   the chat-help file.



7. MODIFYING TEMPLATES

The chat templates are plain HTML files, but they contain certain tags
which are replaced by the chat. Three tags are universal and can
be used in every template:

{CHATNAME}    Will be replaced by the name of the chat defined by
              $chatname in Settings.dat (or General Setting in the
              Administrator funktions), usually used as a title of
              the HTML-file.

{CGI}         Will be replaced by the URL of chat.pl, where the
              parameter id is allready included. If other parameters
              should added, you have to write it like this:
                     {CGI}&action=allusers

{HTMLURL}     Will be replaced by $htmlurl from Directories.dat. This
              tag is used in almost all templates to define the base
              address like this:
                     <base href="{HTMLURL}">
              Therefore you don't need to give the complete path to an
              HTML file when using it in a template.

All other tags will only be used in certain templates.
Warning: Every but the universal tags _must_ be written in their own
line, without a space in front or behind the tag.


If you install the chat, you should modify the templates login.html
and register.html (logo, welcome message and so on). If you adjust
the frames in chat.html, you should keep the names of the frames.
A detailed description of all templates and tags used there should
be avalable soon, for up to date information please visit
<http://www.gtchat.de>.



8. JAVASCRIPT OPTIONS

At the start of chat.js there are following variables defined:

roomlistdelay          Delay (in milliseconds) for the room list to
Default: 10000         appear. The default templates of GTChat show
                       the chat logo in the meantime. If you don't
                       have any logo or want to use an extra frame
                       for it, set this one to 0.

scrolldelay            Interval (in milliseconds) for the text frame
Default: 150           to scroll down (if not disabled by the user).

aliveinterval          Interval (in milliseconds) for sending the
Default: 50000         /alive command to show that the user is still
                       in the chat.

refreshdelay           Only relevant for the client pull mode. Sets
Default: 6000          interval (also in milliseconds) to check for new
                       messages. Remark: New messages will also be
                       retrieved when the user sends some text.

logoutpage             If set it defines the URL of the page to be
Default: ""            shown on logout instead of the login page.

autokick               If not zero it defines the number of milliseconds
Default: 0             the user is allowed to be idle. After this time
                       the user is automatically kicked out of the chat
                       (after being warned).

The correct functioning of the chat is vitally dependent on the
correct functioning of it's JavaScript part. That is why you should
only make changes on the JavaScript if you know exactly what you are
doing. I most likely won't support any problems caused by wrong
modification. A detailed description of the JavaScript functions
will available soon, for up to date information please visit
<http://www.gtchat.de>.