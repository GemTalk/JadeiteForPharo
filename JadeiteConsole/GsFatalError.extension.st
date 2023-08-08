Extension { #name : 'GsFatalError' }

{ #category : '*JadeiteConsole' }
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
	JadeiteConsole allInstances do: [:transcript | transcript view destroy].	"should be only one"
	TerminateProcess signal
]
