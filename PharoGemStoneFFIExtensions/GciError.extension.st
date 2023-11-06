Extension { #name : 'GciError' }

{ #category : '*PharoGemStoneFFIExtensions' }
GciError >> message [

	^ message skinnyPrintOn: (WriteStream on: String new)
]
