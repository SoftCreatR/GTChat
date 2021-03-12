// This array determines which frames have to be reloaded if some attribute is changed
// 0 - don't reload
//
// 1 - reload frame users only if the current user was changed
// 2 - reload frame users only if the current room was changed (or a user in the current room)
// 4 - reload frame users on every change
//
// 8 - reload frame input only if the current user was changed
// 16 - reload frame input only if the current room was changed (or a user in the current room)
// 32 - reload frame input on every change
//
// The different conditions can be combined by adding.
var reloadOnChange = new Array();
reloadOnChange["online"] = 4;
reloadOnChange["room"] = 4;
reloadOnChange["away"] = 2;
reloadOnChange["nick"] = 2;
reloadOnChange["style"] = 9;
reloadOnChange["popup_privatemsg"] = 1;
reloadOnChange["tempgroup"] = 10;
reloadOnChange["rooms.created"] = 4;
reloadOnChange["rooms.deleted"] = 4;
reloadOnChange["rooms.closed"] = 4;
reloadOnChange["rooms.invited"] = 4;
reloadOnChange["rooms.owner"] = 2;
reloadOnChange["rooms.moderated"] = 2;
reloadOnChange["rooms.vips"] = 2;

// Opens a chat template in a new window with given size
// Needs the variable cgi either in the current frame or it's parent
function openWindow(template,width,height)
{
	return openCenteredWindow((window.cgi || parent.cgi)+'&template='+template,template.replace(/[^a-zA-Z0-9]/g,''),width,height);
}

// Opens a new window centered on the screen
function openCenteredWindow(url,name,width,height)
{
	var left = (screen.availWidth-width)/2;
	var top = (screen.availHeight-height)/2;
	var wnd = window.open(url,name,'resizable=yes,scrollbars=yes,width='+width+',height='+height+',left='+left+',top='+top);
	wnd.focus();
	parent.needFocus = 0;
	return wnd;
}

function postToTemplate(template,width,height,paramName,param)
{
	if (parent.input && parent.input.document && parent.input.document.auxForm)
	{
		var wndName = (template+'&'+paramName+'='+param).replace(/[^a-zA-Z0-9]/g,'');
		var wnd = openCenteredWindow('',wndName,width,height);

		parent.input.document.auxForm.target = wndName;
		parent.input.document.auxForm.template.value = template;
		parent.input.document.auxForm.param.value = param;
		parent.input.document.auxForm.param.name = paramName;
		parent.input.document.auxForm.submit();
		return wnd;
	}
}

// Changes the size of the window to the content's size
// IE 4+, Netscape 6+
function autosize(frame)
{
	if (!frame)
		frame = window;

	if (!frame.autosize)
		frame.autosize = autosize;

	// Disable for Netscape 4 to prevent reloading of the document
	if (frame.document.layers)
		return;

	var current = frame.innerHeight;
	if (!current && frame.document.body && frame.document.body.clientHeight)
		current = frame.document.body.clientHeight;
		
	var needed = frame.document.height;
	if (needed)
		needed+=20;    // +20 to correct Netscape 6 bug
	if (!needed && frame.document.body && frame.document.body.scrollHeight)
		needed = frame.document.body.scrollHeight+2;

	if (current && needed)
	{
		var changeBy = needed-current;

		var wndHeight = frame.top.outerHeight;
		if (!wndHeight && frame.top.document.body && frame.top.document.body.clientHeight)
			wndHeight = frame.top.document.body.clientHeight+50;

		if (wndHeight)
		{
			if (wndHeight+changeBy>screen.availHeight-40)
				changeBy = screen.availHeight-40-wndHeight;
				
			frame.top.moveBy(0,-changeBy/2);
			frame.top.resizeBy(0,changeBy);
		}
	}
}

// Stores current caret position of a text field or textarea to be used
// in replaceSelectedText() later
// Only necessary for IE 4+
function storeCaret(element)
{
	if (document.selection && document.selection.createRange)
		element.caretPos=document.selection.createRange().duplicate();
}

// Replaces the selected text of a text field or textarea
// IE 4+ (storeCaret() needs to be called in onselect, onclick, onkeyup), Netscape 6+
// All other browsers append the text to the existing
function replaceSelectedText(element,text)
{
	if (element && element.caretPos)
		element.caretPos.text=text;
	else if (element && element.selectionStart+1 && element.selectionEnd+1)
		element.value=element.value.substring(0,element.selectionStart)+text+element.value.substring(element.selectionEnd,element.value.length);
	else if (element)
		element.value+=text;
}

// Replaces the selected text in the text input field or
// inserts the text at the caret position if no text is selected
function addText(text,donotfocus)
{
	if (!donotfocus)
		parent.input.document.inputForm.text.focus();
	replaceSelectedText(parent.input.document.inputForm.text, " "+text+" ");
	storeCaret(parent.input.document.inputForm.text);
}

// Inserts the text at the start of the text input field
// except the case there is already a command
function insertText(text,donotfocus)
{
	if (!donotfocus)
		parent.input.document.inputForm.text.focus();
	if (parent.input.document.inputForm.text.value.replace(/^\s*/,"").substr(0,1)!='/')
		parent.input.document.inputForm.text.value = text+parent.input.document.inputForm.text.value;
	storeCaret(parent.input.document.inputForm.text);
}

// Adds the text from the text input field to the send buffer
// and empties the text input field
function doSend()
{
	text=parent.input.document.inputForm.text.value.replace(/\x01/g,'');
	if (parent.admin_mode && !text.match(/^\s*\//))
		text = "/admin "+text;
	parent.input.document.inputForm.text.value = "";

	parent.needFocus=1;
	sendText(text);
	if (parent.needFocus)
		parent.input.document.inputForm.text.focus();
}

// Adds a text to the send buffer and sends it if possible
function sendText(text)
{
	text=text.replace(/^\s+|\s+$/g,"");

	var list = text.split(" ");
	if (list.length>0 && parent.aliases && parent.aliases[' '+list[0]])
	{
		list[0]=parent.aliases[' '+list[0]];
		text = list.join(" ");
	}
	
	if (list.length>0 && parent.jscommands && parent.jscommands[' '+list[0]])
	{
		eval(parent.jscommands[' '+list[0]]);
		return;
	}

	if (!parent.sendBuffer)
		parent.sendBuffer = "";
	parent.sendBuffer += text+'\x01'
	
	if (parent.input && parent.input.document && parent.input.document.sendForm && parent.input.document.sendForm.text && parent.input.document.sendForm.textid && parent.textid != parent.lasttextid)
	{
		parent.lasttextid = parent.textid;

		parent.input.document.sendForm.text.value = parent.sendBuffer;
		parent.sendBuffer = "";
		parent.input.document.sendForm.textid.value = parent.textid;

		var aliveInterval = parent.aliveInterval;
		if (aliveInterval < parent.send_blocking_timeout*2)
			aliveInterval *= parent.delayFactor;
		parent.setTimeout("if (window.lasttextid == '"+parent.lasttextid+"' && window.input) window.input.sendText('/alive')", aliveInterval);
		
		submitForm();
	}
}

function submitForm()
{
	if (parent.input && parent.input.document && parent.input.document.sendForm)
	{
		parent.sendTime = (new Date).getTime();
		parent.input.document.sendForm.submit();
	
		var send_blocking_timeout = parent.send_blocking_timeout;
		send_blocking_timeout *= parent.delayFactor;
		parent.setTimeout("if (window.textid == '"+parent.textid+"'){ window.delayFactor *= 1.5;submitForm() }", send_blocking_timeout);
	}
}

// Generates a new text id for the next text to be sent
function setNewTextId(initial)
{
	var hex = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];

	if (!initial)
	{
		if (parent.averageTime)
			parent.averageTime = parent.averageTime*0.6+0.4*((new Date).getTime() - parent.sendTime);
		else
			parent.averageTime = (new Date).getTime() - parent.sendTime;
		parent.delayFactor = (parent.averageTime*2 < parent.send_blocking_timeout ? 1 : parent.averageTime*2/parent.send_blocking_timeout);
		parent.connectionPercent = 100 - parent.averageTime*100/parent.send_blocking_timeout;
		if (parent.delayFactor > 2)
			parent.delayFactor = 2;
		if (parent.connectionPercent < 0)
			parent.connectionPercent = 0;

		if (parent.input && parent.input.document)
		{
			var connectionCell;
			
			if (parent.input.document.all)
				connectionCell = parent.input.document.all.connection;
			if (parent.input.document.getElementById)
				connectionCell = parent.input.document.getElementById('connection');

			if (connectionCell)
			{
				var green, red;
				if (parent.connectionPercent>=50)
				{
					green = 'FF';
					red = (100-parent.connectionPercent)/50*0xFF;
					red = hex[parseInt(red/16)]+hex[parseInt(red)%16];
				}
				else
				{
					green = parent.connectionPercent/50*0xFF;
					green = hex[parseInt(green/16)]+hex[parseInt(green)%16];
					red = 'FF';
				}
				if (!connectionCell._tooltip)
					connectionCell._tooltip = connectionCell.title;
					
				var percent = parseInt(parent.connectionPercent);
				connectionCell.bgColor = '#'+red+green+'00';
				connectionCell.title = connectionCell._tooltip+": "+percent+"%";
				connectionCell.width = (percent>=1 ? percent : 1)+"%";
			}
		}
	}

	parent.textid = (new Date).getTime()+':'+Math.random();

	if (parent.sendBuffer)
		sendText("");
}

// Adds a private message code to the user's private messages window
// Opens a new window if it isn't open
function writePrivateMsg(user,nick,code)
{
	if (!parent.privateWindows)
		parent.privateWindows = new Array();
	if (!parent.messages)
		parent.messages = new Array();
		
	if (parent.messages[' '+user])
		parent.messages[' '+user] += code;
	else if (parent.privateWindows[' '+user] && !parent.privateWindows[' '+user].closed && parent.privateWindows[' '+user].messages && parent.privateWindows[' '+user].messages.document)
	{
		parent.privateWindows[' '+user].messages.document.writeln(code);
		if (parent.privateWindows[' '+user].updated)
			parent.privateWindows[' '+user].updated();
		if (code == '')
			parent.privateWindows[' '+user].focus();
	}
	else
	{
		parent.messages[' '+user] = code;
		parent.privateWindows[' '+user] = openWindow('private_frames&username='+user+'&nickname='+nick,600,400);
	}
}

// Checks if the users frame has to be reloaded after the changes
function changed(myname,changedname,myroom,changedroom,changedoldroom,changed)
{
	var mask=(changedname==myname?1:0)+(changedroom==myroom?2:0)+4;
	var reload=0;
	for (var i=0;i<changed.length;i++)
	{
		var current = reloadOnChange[changed[i]];

		if ((current & 7) && ((~current & 7) | mask) == 7)
			reload |= 1;
			
		current = reloadOnChange[changed[i]] >> 3;
		if ((current & 7) && ((~current & 7) | mask) == 7)
			reload |= 2;
	}
	
	if (reload & 1)
		parent.users.location.href=(window.cgi || parent.cgi)+'&template=users';

	if (reload & 2)
		parent.input.location.href=(window.cgi || parent.cgi)+'&template=input';
}

// Manages the output of HTML code in client pull mode.
// Proceeds the scripting parts enclosed by <script>...</script> (only one per line!)
function msgOutput(msg)
{
	var lines=msg.split("\n");
	var isScript=0;
	var script="";
	for (i=0;i<lines.length;i++)
	{
		if (!isScript && lines[i].match(/<script>/))
		{
			isScript = 1;
			script = "";
		}
		else if (isScript && lines[i].match(/<\/script>/))
		{
			setTimeout(script,0);
			isScript = 0;
		}
		else if (isScript)
			script += lines[i]+'\n';
		else if (!lines[i].match(/^\s*$/) && parent.messages.document)
		{
			if (parent.messages.document.all && parent.messages.document.all.dtext)
				parent.messages.document.all.dtext.innerHTML += lines[i]+'\n';
			else
				parent.messages.document.writeln(lines[i]);
		}
	}
}

// Scrolls down the messages frame if the user didn't scroll up before
// IE 4+, Netscape 4+, Opera 5+
function doScroll()
{
	if (parent.messages)
	{
		var scrolltop;
		var tolerance = 0;
		if (parent.messages.document && parent.messages.document.body)
		{
			scrolltop = parent.messages.document.body.scrollTop;
			if (parent.messages.document.body.clientHeight)
			{
				if (parent.clientHeight_)
					tolerance = Math.abs(parent.clientHeight_-parent.messages.document.body.clientHeight);
				parent.clientHeight_ = parent.messages.document.body.clientHeight;
			}
		}

		var yoffset = parent.messages.pageYOffset;
		if (parent.messages.innerHeight)
		{
			if (parent.innerHeight_)
				tolerance = Math.abs(parent.innerHeight_-parent.messages.innerHeight);
			parent.innerHeight_ = parent.messages.innerHeight;
		}
		
		if (!(yoffset+tolerance < parent.yoffset || scrolltop+tolerance < parent.scrolltop))
		{
			parent.messages.scrollBy(0,50000);
			parent.yoffset = yoffset;
			parent.scrolltop = scrolltop;
		}
	}
}

function resetScrollPos()
{
	if (document.body)
	{
		parent.scrolltop = document.body.scrollTop;
		parent.clientHeight_ = document.body.clientHeight;
	}

	parent.yoffset = window.pageYOffset;
	parent.innerHeight_ = window.innerHeight;
}

// Clears the messages frame
function clear()
{
	saveLog();
	
	parent.restore='';
	parent.exiting=1;
	parent.messages.location.href=(window.cgi || parent.cgi)+'&action=messages';
}

// Saves the input of the messages frame for the log before the frame is cleared
// IE 4+ and Netscape 6+
function saveLog()
{
	if (!parent.log)
		parent.log="";

	if (parent.messages && parent.messages.document)
	{
		var text = "";

		if (parent.messages.document.all && parent.messages.document.all.dtext && parent.messages.document.all.dtext.innerHTML)
			text = parent.messages.document.all.dtext.innerHTML;
		else if (parent.messages.document && parent.messages.document.body && parent.messages.document.body.innerHTML)
			text = parent.messages.document.body.innerHTML;

		if (text.indexOf('Wladimir Palant -->'))
			text=text.substr(text.indexOf('Wladimir Palant -->')+19);
		if (text.indexOf('Sascha Heldt -->'))
			text=text.substr(text.indexOf('Sascha Heldt -->')+16);

		parent.log+=text;
	}
}

// Resets the focus to the input field
function resetFocus()
{
	if (parent && parent.input && parent.input.document && parent.input.document.inputForm && parent.input.document.inputForm.text.setActive)
		parent.input.document.inputForm.text.setActive();
}

// Adds onfocus handlers to all links and input elements that call the resetFocus() function
// IE 4+ only
function addFocusHandlers()
{
	if (document.all)
	{
		for (var i=0;i<document.all.length;i++)
			if (document.all[i].tagName=="A" || document.all[i].tagName=="INPUT")
				document.all[i].onfocus = resetFocus;
	}
}

// Deactivates all imported styles but the last one
// IE 4+, Netscape 6+
function deactivateOldStyles()
{
	var list;
	if (document.getElementsByTagName)
		list = document.getElementsByTagName('LINK');
	else
		list = document.styleSheets;
		
	if (list)
	{
		for (var i=0;i<list.length-1;i++)
			list[i].disabled=true;
	}
}

function showModeratedTextsWindow()
{
	parent.moderationWnd = openWindow('moderated',500,200);
}

function addModeratedText(id, name, nick, color, text, to)
{
	if (!parent.moderatedTexts)
		parent.moderatedTexts = new Array();

	parent.moderatedTexts[parent.moderatedTexts.length] = [id, name, nick, color, text, to];
	
	if (!parent.disableModeration)
		showModeratedTextsWindow();
}

function removeModeratedText(id)
{
	if (!parent.moderatedTexts)
		return;

	for (var i=0;i<parent.moderatedTexts.length;i++)
	{
		if (parent.moderatedTexts[i][0] == id)
		{
			var newArray = [];          // cannot use slice() here - IE bug
			for (var j=0;j<parent.moderatedTexts.length;j++)
				if (j != i)
					newArray[newArray.length] = parent.moderatedTexts[j];
			parent.moderatedTexts = newArray;
			if (parent.moderationWnd && !parent.moderationWnd.closed)
				showModeratedTextsWindow();
			return;
		}
	}
}
