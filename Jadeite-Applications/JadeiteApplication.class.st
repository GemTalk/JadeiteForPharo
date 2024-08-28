Class {
	#name : 'JadeiteApplication',
	#superclass : 'StPharoApplication',
	#instVars : [
		'gciSession',
		'classToInstantiate',
		'theInstance'
	],
	#classVars : [
		'InTransaction'
	],
	#category : 'Jadeite-Applications',
	#package : 'Jadeite-Applications'
}

{ #category : 'actions' }
JadeiteApplication class >> abortTransactionInSession: session [

	| browserService services |
	self todo: 'use instance method #abortTransaction?'.
	services := (RowanServiceUpdater current
		             selectedServicesForConnection: session library) asSet
		            asArray.
	browserService := RowanBrowserService new
		                  command: #abortTransactionAndUpdateServices:;
		                  commandArgs: (Array with: services).
	RowanServiceUpdater current
		issueCommand: browserService
		session: session
		onCompletion: [
			self
				setInTransaction: RowanAnsweringServiceClient newInCompletionBlock
				session: session
				onCompletion: [
					JadePresenter trigger: #abortedTransaction.
					UIManager default inform: 'Abort succeeded'.
					JadeiteSound informationBeep ] ]
]

{ #category : 'constants' }
JadeiteApplication class >> changedTextBackgroundColor [ 

	^Color r: 0.96 g: 1 b: 0.8
]

{ #category : 'actions' }
JadeiteApplication class >> commitTransactionInSession: session onCompletion: completionBlock [
	"Even if it takes a windy path, try to make sure
	all aborts in Jadeite pass through here"

	| browserService commitResult |
	browserService := RowanBrowserService new
		                  command: #commitTransaction;
		                  commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: browserService
		session: session
		onCompletion: [
			commitResult := browserService updates first answer. "should only get one update back"
			commitResult
				ifTrue: [
					UIManager default inform: 'Commit succeeded'.
					JadeiteSound informationBeep ]
				ifFalse: [
				UIManager default alert: 'Commit failure' title: 'Jaded warning' ].
			completionBlock value ]
]

{ #category : 'constants' }
JadeiteApplication class >> defaultBackgroundColor [  

	^Color r: 0.9803921568627451 g: 0.9490196078431372 b: 0.8156862745098039
]

{ #category : 'public' }
JadeiteApplication class >> inTransaction [

	^InTransaction
]

{ #category : 'added manually from Dolphin' }
JadeiteApplication class >> inTransaction: aBoolean [
	InTransaction := aBoolean
]

{ #category : 'instance creation' }
JadeiteApplication class >> openOn: aSymbol [

	| inst | 
	inst := self new classToInstantiate: aSymbol. 
	^inst start

	
]

{ #category : 'added manually from Dolphin' }
JadeiteApplication class >> setInTransaction: answeringService session: session onCompletion: completionBlock [

	answeringService
		exec: 'System inTransaction'
		in: session
		onCompletion: [
		self inTransaction: answeringService answer = 'true'. 
		completionBlock value ]
]

{ #category : 'instance creation' }
JadeiteApplication class >> showOnSession: aConnection [

	| inst |
	inst := self new gciSession: GciSession current.
	inst gciSession library: aConnection.
	^inst start.
	
]

{ #category : 'actions' }
JadeiteApplication >> abortTransaction [
	"Even if it takes a windy path, try to make sure
	all aborts in Jadeite pass through here"

	| browserService services |
	services := (RowanServiceUpdater current
		             selectedServicesForConnection: gciSession library)
		            asSet asArray.
	browserService := RowanBrowserService new
		                  command: #abortTransactionAndUpdateServices:;
		                  commandArgs: (Array with: services).
	RowanServiceUpdater current
		issueCommand: browserService
		session: gciSession
		onCompletion: [
			self
				setInTransaction: RowanAnsweringServiceClient newInCompletionBlock
				session: gciSession
				onCompletion: [
					self triggerEvent: #abortedTransaction.
					UIManager default inform: 'Abort succeeded'.
					JadeiteSound informationBeep ] ]
]

{ #category : 'constants' }
JadeiteApplication >> changedTextBackgroundColor [ 

	^self class changedTextBackgroundColor
]

{ #category : 'accessing' }
JadeiteApplication >> classToInstantiate [

	^ classToInstantiate
]

{ #category : 'accessing' }
JadeiteApplication >> classToInstantiate: anObject [

	classToInstantiate := anObject
]

{ #category : 'public' }
JadeiteApplication >> commitTransaction [
	"Even if it takes a windy path, try to make sure
	all commits in Jadeite pass through here"

	self class commitTransactionInSession: gciSession onCompletion: nil
]

{ #category : 'constants' }
JadeiteApplication >> defaultBackgroundColor [ 

	^self class defaultBackgroundColor
]

{ #category : 'showing' }
JadeiteApplication >> defaultWindowPresenterClass [
		
	^ JadeiteWindowPresenter
]

{ #category : 'accessing' }
JadeiteApplication >> gciSession [

	^ gciSession
]

{ #category : 'accessing' }
JadeiteApplication >> gciSession: anObject [

	gciSession := anObject
]

{ #category : 'public' }
JadeiteApplication >> inTransaction [

	^self class inTransaction
]

{ #category : 'public' }
JadeiteApplication >> inTransaction: aBoolean [
	self class inTransaction: aBoolean
]

{ #category : 'initialize' }
JadeiteApplication >> initialize [
	super initialize.
	self initializeStyleSheet. 
]

{ #category : 'initialize' }
JadeiteApplication >> initializeStyleSheet [

	| classStyle |
	classStyle := SpStyle newJadeiteApplication.
	classStyle
		addClass: 'jadeiteTextBackgroundColor'
		with: [ :theClass |
			theClass addPropertyDrawWith: [ :draw |
				draw backgroundColor: self defaultBackgroundColor ] ].
	classStyle addClass: 'jadeiteRedBackgroundColor' with: [ :theClass |
		theClass addPropertyDrawWith: [ :draw |
			draw backgroundColor: Color lightRed ] ].
	classStyle
		addClass: 'jadeiteChangedTextBackgroundColor'
		with: [ :theClass |
			theClass addPropertyDrawWith: [ :draw |
				draw backgroundColor: self changedTextBackgroundColor ] ].
	self addStyleSheet: classStyle.
	^ classStyle
]

{ #category : 'initialize' }
JadeiteApplication >> registerBrowserEventsFor: browserPresenter [

	self
		when: #abortedTransaction
		send: #abortedTransaction
		to: browserPresenter.
	self
		when: #packageAdded:
		send: #selectNewPackage:
		to: browserPresenter.
]

{ #category : 'added manually from Dolphin' }
JadeiteApplication >> setInTransaction: answeringService session: session onCompletion: completionBlock [

	^ self class
		  setInTransaction: answeringService
		  session: session
		  onCompletion: completionBlock
]

{ #category : 'actions' }
JadeiteApplication >> start [

	"return self so the sender can apply styles"

	theInstance := (Smalltalk at: classToInstantiate) new.
	theInstance application: self. 
	theInstance open.
	theInstance window extent: 1000 @ 1000.
]

{ #category : 'accessing' }
JadeiteApplication >> theInstance [

	^ theInstance
]

{ #category : 'accessing' }
JadeiteApplication >> theInstance: anObject [

	theInstance := anObject
]
