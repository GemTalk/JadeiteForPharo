"
A landing spot for code that is used everywhere across models and presenters. 
Hopefully, with good design, behavior in this class will be limited.
"
Trait {
	#name : 'JadeiteUtilityTrait',
	#category : 'Jadeite-Traits'
}

{ #category : 'ambiguous' }
JadeiteUtilityTrait >> fileoutFileSelection: defaultFileName [

	| filePath |
	filePath := JadeiteServerFileSaveDialog
		            showOnSession: GciSession current
		            defaultPath: JadePresenter lastSavePath
		            defaultFileName: defaultFileName.
	^ filePath ifNotNil: [
		  JadePresenter lastSavePath:
			  (FileReference / filePath) parent pathString.
		  filePath ]
]

{ #category : 'selecting' }
JadeiteUtilityTrait >> openPackageSelectionDialogFor: searchName [ 

	| dialogWindow answeringService |
	answeringService := RowanAnsweringService new
		                    command: #allPackageNames;
		                    commandArgs: Array new.
	RowanServiceUpdater current
		issueCommand: answeringService
		session: self gciSession
		onCompletion: nil.
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
	^dialogWindow chooseFromOwner: self currentWorld.
	
]

{ #category : 'selecting' }
JadeiteUtilityTrait >> selectPackage [

	^self openPackageSelectionDialogFor: 'Package'.
]

{ #category : 'updates' }
JadeiteUtilityTrait >> sortedProjectsFrom: theProjects [

	^ theProjects asSortedCollection: [ :x :y |
		  x name asLowercase < y name asLowercase ]
]
