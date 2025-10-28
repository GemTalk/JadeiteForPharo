Extension { #name : 'JadeitePreferences' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeitePreferences class >> createShowProgressBarRow [

	^ Smalltalk ui theme newRowIn: self for: {
			  self stopProgressBarButton }
]
