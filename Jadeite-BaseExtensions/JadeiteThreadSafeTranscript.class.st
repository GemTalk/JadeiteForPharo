Class {
	#name : 'JadeiteThreadSafeTranscript',
	#superclass : 'ThreadSafeTranscript',
	#traits : 'TTranscript',
	#classTraits : 'TTranscript classTrait',
	#category : 'Jadeite-BaseExtensions',
	#package : 'Jadeite-BaseExtensions'
}

{ #category : 'declare' }
JadeiteThreadSafeTranscript class >> install [
	"JadeiteThreadSafeTranscript install"

	^ super install
]

{ #category : 'accessing' }
JadeiteThreadSafeTranscript >> characterLimit [

	^ 200000
]
