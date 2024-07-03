Extension { #name : 'ObservableValueHolder' }

{ #category : '*Jadeite-BaseExtensions' }
ObservableValueHolder >> value: anObject [
	"Handle circular references as explained in the class comment"

	| oldValue |
	lock ifTrue: [ ^ self ].

	[
	lock := true.
	oldValue := value.
	value := anObject.
	self valueChanged: oldValue ] ensure: [ lock := false ]
]
