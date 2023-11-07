Class {
	#name : 'JadeiteGciError',
	#superclass : 'GciError',
	#category : 'JadeitePharoGemStoneFFIExtensions'
}

{ #category : 'exceptioninstantiator' }
JadeiteGciError class >> signal: aString [

	^ super signal: (aString skinnyPrintOn: (WriteStream on: String new))
]

{ #category : 'accessing' }
JadeiteGciError >> message [

	^ message skinnyPrintOn: (WriteStream on: String new)
]
