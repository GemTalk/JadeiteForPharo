Extension { #name : 'Text' }

{ #category : '*Jadeite-BaseExtensions' }
Text >> copyToClipboard [

	Clipboard
		clipboardText: self asString
		informing: 'Text copied to clipboard'
]
