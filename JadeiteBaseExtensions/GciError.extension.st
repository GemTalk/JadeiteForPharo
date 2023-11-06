Extension { #name : 'GciError' }

{ #category : '*JadeiteBaseExtensions' }
GciError >> message [

	^ message skinnyPrintOn: (WriteStream on: String new)
]
