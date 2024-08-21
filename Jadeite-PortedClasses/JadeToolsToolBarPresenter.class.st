Class {
	#name : 'JadeToolsToolBarPresenter',
	#superclass : 'JadePresenter',
	#category : 'Jadeite-PortedClasses',
	#package : 'Jadeite-PortedClasses'
}

{ #category : 'Jade' }
JadeToolsToolBarPresenter >> abort [
	(parentPresenter class canUnderstand: #abortTransaction)
		ifTrue: [^parentPresenter abortTransaction	"include tool post-abort behavior"].
	super abortTransaction
]

{ #category : 'Jade' }
JadeToolsToolBarPresenter >> begin [
	(parentPresenter class canUnderstand: #beginTransaction)
		ifTrue: [^parentPresenter beginTransaction]
]

{ #category : 'public' }
JadeToolsToolBarPresenter >> commit [
	^super commitTransaction
]

{ #category : 'public' }
JadeToolsToolBarPresenter >> fileNew [
	JadeiteWorkspace showOnSession: gciSession.

]

{ #category : 'public' }
JadeToolsToolBarPresenter >> fileOpen [

	JadeiteWorkspace openOnSession: gciSession.

]

{ #category : 'public' }
JadeToolsToolBarPresenter >> queryCommand: query [
	super queryCommand: query.
	query commandSymbol = #begin
		ifTrue: 
			[query isEnabled: self isBeginTransactionEnabled.
			^true].
	query commandSymbol = #commit
		ifTrue: 
			[query isEnabled: self isCommitEnabled.
			^true].
]
