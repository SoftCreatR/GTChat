var main = window;
var isFocused = true;

var admin_mode = false;
var sendBuffer = '';
var sendTime = 0;
var textid = '';
var lasttextid = '';
var delayFactor = 1;
var averageTime = 0;

var messagesWidth = '';
var secondaryWidth = '';
var connectionTitle = '';

var connectionPercent = 100;

var oldHeight = 0;
var oldYOffset = 0;
var oldScrollTop = 0;

var exiting = false;
var restore = '';
var restoreWindow;
var log = '';

var aliases = new Array();
var jscommands = new Array();

var pressedButton = null;

setNewTextId(1);

function init()
{
	window.messages.location.href = cgi + ';action=messages';
	resetFocus();
	setTimeout("if (lasttextid == '"+lasttextid+"') sendText('/alive')", aliveInterval);

	// Disable image drag&drop on the toolbar
	var toolbar = document.getElementById('toolbar');
	if (typeof(toolbar.addEventListener) != 'undefined')    // bind Mozilla event handler
		toolbar.addEventListener('draggesture', function(e){e.stopPropagation()}, false);
	else                                                    // bind IE event handler
		toolbar.ondragstart = function(){return false};

	try
	{
		if (window.secondary.document.getElementById('rooms').style.display == 'none' && window.secondary.document.getElementById('users').style.display == 'none')
			minimizeSecondary();
	}
	catch (e) {}
}

function updateRooms(html)
{
	window.secondary.document.getElementById('rooms').innerHTML = html;
}

function updateUsers(html)
{
	window.secondary.document.getElementById('users').innerHTML = html;
}

function updateMenu(html)
{
	document.getElementById('menu').innerHTML = html;
}

// Stores current caret position of a text field or textarea to be used
// in replaceSelectedText() later
// Only necessary for IE 4+
function storeCaret(element)
{
	try
	{
		if (typeof(document.selection) != 'undefined')
			element.caretPos = document.selection.createRange().duplicate();
	}
	catch (e){}
}

// Replaces the selected text of a text field or textarea
// IE 4+ (storeCaret() needs to be called in onselect, onclick, onkeyup), Netscape 6+
// All other browsers append the text to the existing
function replaceSelectedText(element, text)
{
	if (typeof(element) == 'undefined')
		return;

	if (typeof(element.caretPos) != 'undefined')
		element.caretPos.text = text;
	else if (typeof(element.selectionStart) != 'undefined')
		element.value = element.value.substring(0, element.selectionStart) + text + element.value.substring(element.selectionEnd);
	else
		element.value += text;
}

// Replaces the selected text in the text input field or
// inserts the text at the caret position if no text is selected
function addText(text)
{
	resetFocus();
	replaceSelectedText(document.inputForm.text, ' '+text+' ');
	storeCaret(document.inputForm.text);
}

// Inserts the text at the start of the text input field
// except the case there is already a command
function insertText(text)
{
  if (!document.inputForm.text.value.match(/^\s*\//))
	{
		resetFocus();
		document.inputForm.text.value = text + document.inputForm.text.value;
		storeCaret(document.inputForm.text);
	}
}

// Adds the text from the text input field to the send buffer
// and empties the text input field
function doSend()
{
	var text = document.inputForm.text.value.replace(/\x01/g,'');
	if (admin_mode && !text.match(/^\s*\//))
		text = "/admin " + text;
	document.inputForm.text.value = "";

	sendText(text);
}

// Adds a text to the send buffer and sends it to the server if possible
function sendText(text)
{
	if (typeof(text) != 'undefined')
	{
		text = text.replace(/^\s+|\s+$/g,"");
	
		var params = text.split(' ');
		if (params.length > 0 && typeof(aliases[' '+params[0]]) != 'undefined')
		{
			params[0] = aliases[' '+params[0]];
			text = params.join(' ');
		}
		
		if (params.length > 0 && typeof(jscommands[' '+params[0]]) != 'undefined')
		{
			eval(jscommands[' '+params[0]]);
			return;
		}
	
		sendBuffer += text+'\x01'
	}

	if (textid != lasttextid)
	{
		lasttextid = textid;

		document.sendForm.textid.value = textid;
		document.sendForm.text.value = sendBuffer;
		sendBuffer = '';

		var interval = aliveInterval;
		if (interval * delayFactor < send_blocking_timeout * 2)
			aliveInterval *= delayFactor;
		setTimeout("if (lasttextid == '"+lasttextid+"') sendText('/alive')", aliveInterval);

		submitForm();
	}
}

function submitForm()
{
	sendTime = new Date().getTime();
	document.sendForm.submit();

	var timeout = send_blocking_timeout;
	timeout *= delayFactor;
	setTimeout("if (textid == '"+textid+"'){ delayFactor *= 1.5;submitForm() }", timeout);
}

// Generates a new text id for the next text to be sent
function setNewTextId(initial)
{
	if (!initial)
	{
		if (averageTime)
			averageTime = averageTime*0.6 + (new Date().getTime() - sendTime)*0.4;
		else
			averageTime = new Date().getTime() - sendTime;
		delayFactor = (averageTime * 2 < send_blocking_timeout ? 1 : averageTime*2/send_blocking_timeout);
		connectionPercent = 100 - averageTime*100/send_blocking_timeout;
		if (delayFactor > 2)
			delayFactor = 2;
		if (connectionPercent < 0)
			connectionPercent = 0;

		var connectionCell = document.getElementById('connection');
		if (connectionCell)
		{
			var green, red;
			if (connectionPercent >= 50)
			{
				green = 'ff';
				red = (100-connectionPercent)/50*0xFF;
				red = parseInt(red).toString(16);
				while (red.length < 2)
					red = '0' + red;
			}
			else
			{
				red = 'ff';
				green = connectionPercent/50*0xFF;
				green = parseInt(green).toString(16);
				while (green.length < 2)
					green = '0' + green;
			}
			if (connectionTitle == '')
				connectionTitle = connectionCell.title;
				
			var percent = parseInt(connectionPercent);
			connectionCell.style.backgroundColor = '#'+red+green+'00';
			connectionCell.title = connectionTitle + ": " + percent + "%";

			if (typeof(document.images.connection1) != 'undefined' && typeof(document.images.connection2) != 'undefined')
			{
				document.images.connection1.width = (parseInt(percent/2) > 0 ? parseInt(percent/2) : 1);
				document.images.connection2.width = 50 - document.images.connection1.width;
				document.images.connection1.title = connectionCell.title;
				document.images.connection2.title = connectionCell.title;
			}
		}
	}

	textid = new Date().getTime()+':'+Math.random();

	if (sendBuffer != '')
		sendText();
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
		parent.privateWindows[' '+user] = openWindow('private_frames;username='+user+';nickname='+nick,600,400);
	}
}

// Manages the output of HTML code in client pull mode.
// Proceeds the scripting parts enclosed by <script>...</script>
function msgOutput(msg)
{
	var lines = msg.split("\n");
	var isScript = 0;
	var script = '';
	var html = '';
	for (var i=0; i<lines.length; i++)
	{
		if (!isScript && lines[i].match(/<script[^>]*>/))
		{
			isScript = 1;
			script = '';
		}
		else if (isScript && lines[i].match(/<\/script>/))
		{
			window.messages.setTimeout(script, 0);
			isScript = 0;
		}
		else if (isScript)
			script += lines[i]+'\n';
		else if (lines[i].replace(/<!--.*-->/).match(/\S/))
			html += lines[i];
	}

	if (html != '')
	{
		try
		{
			var div = window.messages.document.createElement('div');
			div.innerHTML = html;
			window.messages.document.body.appendChild(div);
		}
		catch (e) {}
	}
}

// Resets the focus to the input field
function resetFocus()
{
	if (typeof(document.inputForm.text.setActive) != 'undefined')
	{
		document.inputForm.text.setActive();
	}
	else if (isFocused)
	{
		document.inputForm.text.focus();
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
		for (var i=0; i<list.length-1; i++)
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

	for (var i=0; i<parent.moderatedTexts.length; i++)
	{
		if (parent.moderatedTexts[i][0] == id)
		{
			var newArray = [];          // cannot use slice() here - IE bug
			for (var j=0; j<parent.moderatedTexts.length; j++)
				if (j != i)
					newArray[newArray.length] = parent.moderatedTexts[j];
			parent.moderatedTexts = newArray;
			if (parent.moderationWnd && !parent.moderationWnd.closed)
				showModeratedTextsWindow();
			return;
		}
	}
}

function keyHandler(e)
{
	if (e.keyCode == 13 && e.ctrlKey)
	{
		doSend();
		return false;
	}
	return true;
}

function doLogout()
{
	if (!window.exiting)
	{
		window.exiting = 1;
		openCenteredWindow(cgi + ';action=send;text=%2Fquit;textid=' + new Date().getTime() + ':' + Math.random() + ';template=message;message=error_logout;image=error','_blank',480,150);
	}
}

function getLog()
{
	var toDo = log;
	
	try
	{
		toDo += window.messages.getMessages();
	}
	catch (e) {}

	var ret = '';
	var lines = toDo.split("\n");
	var isScript = 0;
	for (var i=0; i<lines.length; i++)
	{
		if (!isScript && lines[i].match(/<script[^>]*>/i))
			isScript = 1;
		else if (isScript && lines[i].match(/<\/script>/i))
			isScript = 0;
		else if (!isScript)
		{
			lines[i] = lines[i].replace(/ onclick=\"[^\"]*\"/ig,"").replace(/ href=\"javascript:[^\"]*\"/ig," href=\"javascript:void(0)\"");
			ret += lines[i]+'\n';
		}
	}

	return ret;
}

function onToolbarMouseOver(e)      // img:hover doesn't work in IE
{
	var target = e.target || e.srcElement;

	if (target.className.match(/\bbutton\b/) && !target.className.match(/\bpointed\b/))
		target.className += ' pointed';
}

function onToolbarMouseOut(e)      // img:hover doesn't work in IE
{
	var target = e.target || e.srcElement;

	if (target.className.match(/\bbutton\b/))
		target.className = target.className.replace(/\s?\bpointed\b/,'');
	if (pressedButton != null)
	{
		pressedButton.className = pressedButton.className.replace(/\s?\bpressed\b/,'');
		pressedButton = null;
	}
}

function onToolbarMouseDown(e)
{
	var target = e.target || e.srcElement;

	if (target.className.match(/\bbutton\b/) && !target.className.match(/\bpressed\b/))
	{
		pressedButton = target;
		pressedButton.className += ' pressed';
	}
}

function onToolbarMouseUp(e)
{
	var target = e.target || e.srcElement;

	if (target == pressedButton)
	{
		pressedButton.className = pressedButton.className.replace(/\s?\bpressed\b/,'');
		pressedButton = null;
	}
}

function getToolbarButton(className)
{
	var toolbar = document.getElementById('toolbar');
	if (!toolbar)
		return null;

	var regexp = new RegExp('\\b' + className + '\\b');
	for (var child = toolbar.firstChild; child; child = child.nextSibling)
		if (child.nodeType == 1 && regexp.test(child.className))
			return child;

	return null;
}

function pressToolbarButton(className, press)
{
	var button = getToolbarButton(className);
	if (button)
	{
		if (press && !button.className.match(/\bpressed\b/))
			button.className += ' pressed';
		else if (!press)
			button.className = button.className.replace(/\s?\bpressed\b/,'');
	}
}

function setColor(color)
{
	sendText('/color ' + color);
}

function setShowTime(newValue)
{
	pressToolbarButton('img_menu_showtime', newValue);
	show_time = newValue;
}

function setNoSmileys(newValue)
{
	pressToolbarButton('img_menu_nosmileys', newValue);
	nosmileys = newValue;
}

function setAdminMode(newValue)
{
	pressToolbarButton('img_menu_adminmode', newValue);
	admin_mode = newValue;
}

function minimizeMenu()
{
	document.getElementById('menu').style.display = 'none';
	document.getElementById('restore_menu').style.display = '';
	sendText('/menuminimized 1');
}

function restoreMenu()
{
	document.getElementById('restore_menu').style.display = 'none';
	document.getElementById('menu').style.display = '';
	sendText('/menuminimized 0');
}

function minimizeSecondary()
{
	if (typeof(window.opera) != 'undefined')
		return;

	var messages = document.getElementById('messagesCell');
	var secondary = document.getElementById('secondaryCell');

	if (!messages || !secondary)
		return;

	if (messagesWidth == '')
	{
		messagesWidth = messages.width;
		secondaryWidth = secondary.width;
	}

	secondary.width = 40;
	messages.width = '';
}

function restoreSecondary()
{
	if (typeof(window.opera) != 'undefined')
		return;

	var messages = document.getElementById('messagesCell');
	var secondary = document.getElementById('secondaryCell');

	if (!messages || !secondary)
		return;

	messages.width = messagesWidth;
	secondary.width = secondaryWidth;
}

function minimizeUsers()
{
	try
	{
		window.secondary.document.getElementById('users').style.display = 'none';
		window.secondary.document.getElementById('restore_users').style.display = '';
		if (window.secondary.document.getElementById('rooms').style.display == 'none')
			minimizeSecondary();
		sendText('/usersminimized 1');
	}
	catch (e) {}
}

function restoreUsers()
{
	try
	{
		window.secondary.document.getElementById('restore_users').style.display = 'none';
		window.secondary.document.getElementById('users').style.display = '';
		if (window.secondary.document.getElementById('rooms').style.display == 'none')
			restoreSecondary();
		sendText('/usersminimized 0');
	}
	catch (e) {}
}

function minimizeRooms()
{
	try
	{
		window.secondary.document.getElementById('rooms').style.display = 'none';
		window.secondary.document.getElementById('restore_rooms').style.display = '';
		if (window.secondary.document.getElementById('users').style.display == 'none')
			minimizeSecondary();
		sendText('/roomsminimized 1');
	}
	catch (e) {}
}

function restoreRooms()
{
	try
	{
		window.secondary.document.getElementById('restore_rooms').style.display = 'none';
		window.secondary.document.getElementById('rooms').style.display = '';
    if (window.secondary.document.getElementById('users').style.display == 'none')
		  restoreSecondary();
		sendText('/roomsminimized 0');
	}
	catch (e) {}
}

// Clears the messages frame
function clear()
{
	exiting = 1;
	restore = '';

	try
	{
		log += window.messages.getMessages();
	}
	catch (e) {}

	window.messages.location.href = cgi + ';action=messages';
}
