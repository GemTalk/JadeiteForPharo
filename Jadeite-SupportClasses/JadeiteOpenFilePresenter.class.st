Class {
	#name : 'JadeiteOpenFilePresenter',
	#superclass : 'StOpenFilePresenter',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'showing' }
JadeiteOpenFilePresenter >> openDialog [

	(ProvideAnswerNotification signal: 'openFile') ifNotNil: [ :theAnswer |
		^ theAnswer ].
	^ super openDialog
]
