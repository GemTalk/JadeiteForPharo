Class {
	#name : 'JadeiteToolbarDisplayMode',
	#superclass : 'SpIconAndLabelToolbarDisplayMode',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
JadeiteToolbarDisplayMode class >> modeIconAndLabel [
	^ self uniqueInstance
]

{ #category : 'accessing' }
JadeiteToolbarDisplayMode >> extent [
	"Squeeze out a little more screen real estate than the default 45@45"
	^ (35@35) scaledByDisplayScaleFactor
]
