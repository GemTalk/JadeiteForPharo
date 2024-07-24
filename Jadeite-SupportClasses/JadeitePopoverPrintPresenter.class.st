Class {
	#name : 'JadeitePopoverPrintPresenter',
	#superclass : 'SpCodePopoverPrintPresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'private' }
JadeitePopoverPrintPresenter >> basicObjectAsString [
	
	^ [ object asString ]
		on: Error
		do: [ '<error in printString: try ''Inspect it'' to debug>' ]
]
