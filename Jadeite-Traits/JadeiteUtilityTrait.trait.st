"
A landing spot for code that is used everywhere across models and presenters. 
Hopefully, with good design, behavior in this class will be limited.
"
Trait {
	#name : 'JadeiteUtilityTrait',
	#category : 'Jadeite-Traits',
	#package : 'Jadeite-Traits'
}

{ #category : 'ambiguous' }
JadeiteUtilityTrait >> fileoutFileSelection: defaultFileName [

	| filePath |
	filePath := JadeiteServerFileSaveDialog
		            showOnSession: GciSession current
		            defaultPath: JadePresenter lastSavePath
		            defaultFileName: defaultFileName.
	^ filePath ifNotNil: [
		  | service |
		  service := RowanFileServiceClient new
			             path: filePath;
			             session: self gciSession.
		  service extension isEmpty ifTrue: [
			  service path: filePath , '.gs' ].
		  JadePresenter lastSavePath: service directoryPath.
		  service path ]
]

{ #category : 'selecting' }
JadeiteUtilityTrait >> openPackageSelectionDialogFor: searchName onCompletion: completionBlock [

	| dialogWindow answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allPackageNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: [
			| selection |
			dialogWindow := ListDialogWindow new
				                getList: [ :rxMatcher |
					                answeringService answer select: [ :substring |
							                rxMatcher isString
								                ifTrue: [ rxMatcher , '*' match: substring ]
								                ifFalse: [ "If the expression entered isn't valid regex an error occurs and the string is passed into block not an RxMatcher"
									                rxMatcher matchesPrefix: substring ] ] ];
				                displayBlock: [ :e | e ];
				                doubleClickOk;
				                title: 'Jadeite Regex Find ' , searchName;
				                yourself.
			selection := dialogWindow chooseFromOwner: self currentWorld.
			completionBlock value: selection ]
]

{ #category : 'selecting' }
JadeiteUtilityTrait >> selectPackageOnCompletion: completionBlock [

	^ self
		  openPackageSelectionDialogFor: 'Package'
		  onCompletion: completionBlock
]

{ #category : 'updates' }
JadeiteUtilityTrait >> sortedFrom: theProjects [

	^ theProjects asSortedCollection: [ :x :y |
		  x name asLowercase < y name asLowercase ]
]
