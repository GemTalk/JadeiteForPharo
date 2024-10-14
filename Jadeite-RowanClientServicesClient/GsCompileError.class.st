Class {
	#name : 'GsCompileError',
	#superclass : 'GsError',
	#instVars : [
		'gsArguments'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
GsCompileError class >> signal: gsArguments [

	| error |
	error := self new gsArguments: gsArguments. 
	^error signal

	
]

{ #category : 'as yet unclassified' }
GsCompileError >> descriptiveText [

	| writeStream |
	self todo: '
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: additionalArgs second;
		nextPutAll: ' >> ';
		nextPutAll: (additionalArgs first copyFrom: 2 to: list first second);
		space;
		nextPutAll: list first third;
		nextPutAll: ' >>>>> ';
		nextPutAll: (additionalArgs first copyFrom: list first second + 1 to: additionalArgs first size - 1).
	^writeStream contents'
]

{ #category : 'accessing' }
GsCompileError >> gsArguments [

	^ gsArguments
]

{ #category : 'accessing' }
GsCompileError >> gsArguments: anObject [

	gsArguments := anObject
]
