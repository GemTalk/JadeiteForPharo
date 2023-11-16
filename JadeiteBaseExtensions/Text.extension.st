Extension { #name : 'Text' }

{ #category : '*JadeiteBaseExtensions' }
Text >> copyToClipboard [

	Clipboard
		clipboardText: self asString
		informing: 'Text copied to clipboard'
]
