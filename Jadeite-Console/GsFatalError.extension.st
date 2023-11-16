Extension { #name : 'GsFatalError' }

{ #category : '*Jadeite-Console' }
GsFatalError >> defaultAction [
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: gciErrSType message;
		cr;
		nextPutAll: 'Shutting session down'.
	MessageBox errorMsg: ws contents caption: 'Fatal GemStone Error'.
	self gciSession beInvalidSession.
	self gciSession trigger: #forceJadeiteWindowClose.
	JadeiteConsole currentConsole close.
	TerminateProcess signal
]
