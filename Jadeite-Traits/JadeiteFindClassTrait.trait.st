Trait {
	#name : 'JadeiteFindClassTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'queries' }
JadeiteFindClassTrait >> basicBrowseClassReferences: className session: session completionBlock: completionBlock [

	| service |
	service := RowanQueryService
		           command: #browseClassReferences:
		           withArgs: (Array with: className).
	RowanServiceUpdater current
		issueCommand: service
		session: session
		onCompletion: completionBlock.
	^ service
]

{ #category : 'queries' }
JadeiteFindClassTrait >> browseClassReferences: className [

	| shell |
	self
		basicBrowseClassReferences: className
		session: self gciSession
		completionBlock: [ :service |
			shell := self openMethodListOn: service selecting: className.
			shell updateCaptionFromSearchString:
				service queryResults size printString , ' Class References to '
				, className asString ]
]

{ #category : 'private' }
JadeiteFindClassTrait >> findClass [

	| selection answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			| classService |
			selection := self openClassSelectionDialogOn:
				             answeringService answer.
			selection ifNotNil: [
				classService := RowanClassService new
					                name: selection;
					                meta: false.
				self findClassService: classService ] ]
]

{ #category : 'private' }
JadeiteFindClassTrait >> findClassNamed: className [

	| classService |
	classService := RowanClassService new
		                name: className;
		                meta: false.
	self activePresenter
		updateAfterFindClass: classService
		methodService: nil
		onCompletion: [ self activePresenter updateSUnitTab ]
]

{ #category : 'private' }
JadeiteFindClassTrait >> findClassReferences [

	| selection answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allClassNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			selection := self openClassSelectionDialogOn:
				             answeringService answer.
			selection ifNotNil: [ self browseClassReferences: selection ] ]
]

{ #category : 'private' }
JadeiteFindClassTrait >> findClassService: classService [

	classService ifNil: [ ^ self ].

	self activePresenter
		updateAfterFindClass: classService
		methodService: nil
		onCompletion: [
				self activePresenter updateTabLabel.
				self activePresenter updateSUnitTab ]
]

{ #category : 'private' }
JadeiteFindClassTrait >> openClassSelectionDialogOn: classNames [

	| dialogWindow |
	RowanServiceUpdater current stopProgressBar.
	dialogWindow := JadeiteSearchDialogWindow new
		                getList: [ :rxMatcher |
				                classNames select: [ :substring |
							                rxMatcher isString
								                ifTrue: [ rxMatcher , '*' match: substring ]
								                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
									                rxMatcher matchesPrefix: substring ] ] ];
		                displayBlock: [ :e | e ];
		                doubleClickOk;
		                title: 'Jadeite Regex Find ' , 'Class';
		                yourself.
	^ dialogWindow chooseFromOwner: self currentWorld
]
