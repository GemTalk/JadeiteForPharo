Extension { #name : 'StOpenDirectoryPresenter' }

{ #category : '*JadeiteForPharo-Pharo-13' }
StOpenDirectoryPresenter >> windowTitle [

	^ title ifNil: [ title := 'Select Directory To Open' ]
]
