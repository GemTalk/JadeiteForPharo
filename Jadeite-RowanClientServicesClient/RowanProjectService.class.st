Class {
	#name : 'RowanProjectService',
	#superclass : 'RowanService',
	#instVars : [
		'rwProject',
		'name',
		'sha',
		'branch',
		'isSkew',
		'isDirty',
		'packages',
		'changes',
		'existsOnDisk',
		'isLoaded',
		'projectUrl',
		'rowanProjectsHome',
		'isDiskDirty',
		'projectOop',
		'specService',
		'componentServices',
		'packageGroups',
		'defaultSymbolDictionaryName',
		'packageConvention',
		'diskSha'
	],
	#category : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'constants' }
RowanProjectService class >> allPackagesGroupName [
	^'All Packages'
]

{ #category : 'private' }
RowanProjectService class >> defaultIconName [
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Collection' extension: 'ico'.
]

{ #category : 'private' }
RowanProjectService class >> icon [
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon
]

{ #category : 'instance creation' }
RowanProjectService class >> noneProject [
	| inst |
	inst := self new.
	inst
		name: self notRowanizedPackageName;
		isDirty: false;
		isSkew: false;
		sha: 'not a project'.
	^inst
]

{ #category : 'accessing' }
RowanProjectService class >> templateClassName [ 
	^#RowanProjectService
]

{ #category : 'comparing' }
RowanProjectService >> <= projectService [

	^ projectService isService and: [
		  projectService isProjectService and: [
			  name <= projectService name ] ]
]

{ #category : 'comparing' }
RowanProjectService >> = projectService [

	^ projectService isService and: [
		  projectService isProjectService and: [ name = projectService name ] ]
]

{ #category : 'accessing' }
RowanProjectService >> allClasses [
	"for testing"

	^packages inject: OrderedCollection new
		into: 
			[:coll :packageService |
			packageService classes ifNotNil: [:classes | coll addAll: classes].
			coll]
]

{ #category : 'presenter support' }
RowanProjectService >> basicChangesUsing: session [

	| operations |
	command := #changes.
	RowanServiceUpdater current
		issueCommands: (Array with: self)
		session: session
		onCompletion: nil.
	operations := OrderedCollection new.
	changes do: [ :changeString |
		operations addAll:
			(RowanPatch fromString: changeString session: session) operations ].
	^ operations
]

{ #category : 'presenter support' }
RowanProjectService >> basicChangesUsing: session onCompletion: completionBlock [

	| operations |
	command := #changes.
	RowanServiceUpdater current
		issueCommands: (Array with: self)
		session: session
		onCompletion: [ :unused |
			operations := OrderedCollection new.
			changes do: [ :changeString |
				operations addAll:
					(RowanPatch fromString: changeString session: session) operations ].
			changes := nil. "can be large, reclaim space"
			completionBlock value: operations ]
]

{ #category : 'presenter support' }
RowanProjectService >> basicCheckout: branchName using: presenter [

	self
		command: #checkout:;
		commandArgs: (Array with: (branchName copyWithout: $*)).
	presenter issueCommand: self onCompletion: nil.
	presenter refresh
]

{ #category : 'presenter support' }
RowanProjectService >> basicCheckoutTag: tag using: session [
	self
		command: #checkoutTag:;
		commandArgs: (Array with: tag).
	RowanServiceUpdater current issueCommand: self session: session
]

{ #category : 'presenter support' }
RowanProjectService >> basicCheckoutTag: tag using: session onCompletion: completionBlock [ 
	self
		command: #checkoutTag:;
		commandArgs: (Array with: tag).
	RowanServiceUpdater current issueCommand: self session: session onCompletion: completionBlock
]

{ #category : 'presenter support' }
RowanProjectService >> basicCheckoutUsing: presenter [

	| branches query branchString |
	query := RowanQueryService new
		         command: #projectBranches:;
		         commandArgs: (Array with: self name).
	branchString := (presenter issueCommand: query onCompletion: nil)
		                first answer.
	branches := (branchString subStrings: Character lf)
		            asOrderedCollection.
	branches := branches reject: [ :string | '*HEAD*' match: string ].
	branches := branches collect: [ :string |
		            string copyWithout: Character space ].
	^ branches
]

{ #category : 'accessing' }
RowanProjectService >> basicName: aString [
	"don't round trip to the server to get information" 
	name := aString
]

{ #category : 'accessing' }
RowanProjectService >> branch [
	^branch
]

{ #category : 'accessing' }
RowanProjectService >> branch: anObject [
	branch := anObject
]

{ #category : 'presenter support' }
RowanProjectService >> changesUsing: session [

	| operations |
	operations := self basicChangesUsing: session.
	changes isEmpty ifTrue: [ ^ MessageBox notify: 'No changes!' ].
	[ 
	^operations] ensure: [ 
		changes := nil "clean this up. no longer needed and can be large" ]
]

{ #category : 'public' }
RowanProjectService >> componentServices [

	^componentServices
]

{ #category : 'public' }
RowanProjectService >> componentsUpdate: presenter browser: browser [
	"componentServices will be a dictionary. 
	The key is the parent component.
	The value is an array of the children components.

	Example:
	nil -> #(A) - A is a top level component
	A -> #(B C) - B & C are children of A
	B -> #(D) - D is a child of B
	C -> nil
	D -> nil - neither C nor D have children"

	| treeModel parent topLevelComponents removals |
	
	wasUpdated ifFalse: [^self].
	presenter model class = TreeModel
		ifTrue: [^self	"not sure why the model starts out as a TreeModel, not a JadeiteTreeModel"].
	browser projectListPresenter
		ifNil: [^self]
		ifNotNil: 
			[:list |
			list selectionOrNil ifNil: [^self] ifNotNil: [:service | service name = name ifFalse: [^self]]].
	treeModel := self chooseModel: presenter using: browser.
	topLevelComponents := componentServices at: #nil ifAbsent: [^self].
	treeModel resetVisited.
	parent := nil.
	topLevelComponents do: 
			[:componentService |
			self
				possiblyAddComponent: componentService
				to: treeModel
				withParent: parent
				hierarchyServices: componentServices].
	removals := treeModel asBag reject: [:service | (treeModel getNodeFor: service) visited].
	removals do: [:service | treeModel remove: service ifAbsent: []].
	topLevelComponents do: [:component | presenter view expand: component].
	presenter view ensureSelectionVisible
]

{ #category : 'accessing' }
RowanProjectService >> defaultSymbolDictionaryName [
	^defaultSymbolDictionaryName
]

{ #category : 'accessing' }
RowanProjectService >> definition [

	"send back a copy of the definition"
]

{ #category : 'accessing' }
RowanProjectService >> diskSha [
	^diskSha
]

{ #category : 'accessing' }
RowanProjectService >> displayName [
	| displayName |
	name ifNil: [^String new].
	displayName := name.
	existsOnDisk == false ifTrue: [displayName := '(' , displayName , ')'].
	^displayName
]

{ #category : 'displaying' }
RowanProjectService >> displayStringFor: displayThing [
	name ifNil: [^self].
	self isDirty == true
		ifTrue: 
			[displayThing font beBold.
			displayThing forecolor: Color black].
	self isLoaded
		ifTrue: 
			[self isSkew
				ifTrue: [displayThing forecolor: Color red]
				ifFalse: [displayThing forecolor: Color black]]
		ifFalse: [displayThing forecolor: Color black].
	isDiskDirty ifTrue: [displayThing font beItalic]
]

{ #category : 'accessing' }
RowanProjectService >> existsOnDisk [
	name = self class notRowanizedPackageName ifTrue:[^false]. 
	^existsOnDisk
]

{ #category : 'presenter support' }
RowanProjectService >> gitBranches: session [

	| query branchString branches |
	query := RowanQueryService new
		         command: #projectBranches:;
		         commandArgs: (Array with: self name).
	RowanServiceUpdater current issueCommand: query session: session.
	branchString := query answer.
	branches := (branchString subStrings: {Character lf}).
	branches := branches
		            reject: [ :string | '*HEAD*' match: string ]
		            thenCollect: [ :string |
		            string copyWithout: Character space ].
	^ branches
]

{ #category : 'presenter support' }
RowanProjectService >> gitProjectLogUsing: parentPresenter session: session [

	| gitLog projectName queryService |
	projectName := self name.
	gitLog := JadeiteGitLog showOnSession: session.
	gitLog projectService: self.
	gitLog caption: (parentPresenter gciSession titleBarFor:
			 projectName , ' Project Git Log').
	queryService := RowanQueryService
		                command: #projectLog:
		                withArgs: (Array with: projectName).
	parentPresenter issueCommand: queryService onCompletion: nil.
	gitLog codePane documentPresenter value: queryService queryResults
]

{ #category : 'presenter support' }
RowanProjectService >> gitTags: session [
	| query |
	query := RowanQueryService new
				command: #gitTagListUsing:;
				commandArgs: (Array with: self).
	(RowanServiceUpdater current issueCommand: query session: session).
	^query answer
	
]

{ #category : 'comparing' }
RowanProjectService >> hash [
	^self name hash
]

{ #category : 'Init / Release' }
RowanProjectService >> initialize [
	super initialize.
	isDirty := false.
	isLoaded := false.
	isSkew := false.
	sha := 'not a project'.
	isDiskDirty := false. 
]

{ #category : 'accessing' }
RowanProjectService >> isDirty [
	^isDirty
]

{ #category : 'accessing' }
RowanProjectService >> isDirty: anObject [
	isDirty := anObject
]

{ #category : 'accessing' }
RowanProjectService >> isDiskDirty [
	^isDiskDirty
]

{ #category : 'public' }
RowanProjectService >> isLoaded [
	"Unpackaged project may have a nil sha"

	^sha isNil not and: [sha isEmpty not]
]

{ #category : 'public' }
RowanProjectService >> isProjectService [

	^true
]

{ #category : 'accessing' }
RowanProjectService >> isSkew [
	^isSkew ifNil: [ false ]
]

{ #category : 'accessing' }
RowanProjectService >> isSkew: anObject [
	isSkew := anObject
]

{ #category : 'printing' }
RowanProjectService >> logReceivedOn: aStream [
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: (name ifNil: [name printString])
]

{ #category : 'printing' }
RowanProjectService >> logSentOn: aStream [
	super logSentOn: aStream.
	aStream
		space;
		nextPutAll: (name ifNil: [name printString])
]

{ #category : 'accessing' }
RowanProjectService >> name [
	^name
]

{ #category : 'accessing' }
RowanProjectService >> name: aString [
	name := aString asString
]

{ #category : 'displaying' }
RowanProjectService >> newTextView: session using: parentPresenter [
	| edit shell |
	shell := JadeiteShell showOnSession: session.
	shell view
		layoutManager: BorderLayout new;
		hasMaximize: false;
		hasMinimize: false;
		extent: 800 @ 900;
		caption: 'About';
		addSubView: (edit := RichTextEdit new);
		contextMenu: parentPresenter view contextMenu;
		show.
	edit
		arrangement: #center;
		isReadOnly: true;
		canVScroll: true;
		font: (Font name: 'Arial' pointSize: 10);
		alignment: #center;
		contextMenu: parentPresenter view contextMenu.
	^edit
]

{ #category : 'accessing' }
RowanProjectService >> packageConvention [
	^packageConvention
]

{ #category : 'public' }
RowanProjectService >> packageGroupUpdate: presenter browser: browser [
	| treeModel allService |
	wasUpdated ifFalse: [^self].
	browser selectedProjectName = name ifFalse: [^self].
	treeModel := self chooseModel: presenter using: browser.
	allService := RowanPackageGroupService new
				name: self class allPackagesGroupName;
				projectName: name.
	treeModel isEmpty
		ifTrue: 
			[treeModel add: allService asChildOf: nil.
			packageGroups do: [:packageGroupService | treeModel add: packageGroupService asChildOf: allService]]
		ifFalse: 
			[(treeModel childrenOf: allService)
				do: [:displayedGroup | (packageGroups includes: displayedGroup) ifFalse: [treeModel remove: displayedGroup ifAbsent: []]].
			packageGroups do: 
					[:packageGroupService |
					((treeModel childrenOf: allService) includes: packageGroupService)
						ifFalse: [treeModel add: packageGroupService asChildOf: allService]]].
	presenter view ensureSelectionVisible.
	presenter view expandAll
]

{ #category : 'accessing' }
RowanProjectService >> packageServices [
	"really, packages are a RowanPackageService"
	packages ifNil: [ ^{self} ].
	^packages asSortedCollection: [ :x :y | x name < y name ]
]

{ #category : 'accessing' }
RowanProjectService >> packages [

	^packages
]

{ #category : 'presenter support' }
RowanProjectService >> performGitCommand: gitCommand with: argsString in: session [
	self
		command: #performGitCommand:with:;
		commandArgs: (Array with: gitCommand with: argsString).
	RowanServiceUpdater current issueCommand: self session: session
]

{ #category : 'public' }
RowanProjectService >> prepareForReplication [

	super prepareForReplication.
	packages := nil.
]

{ #category : 'accessing' }
RowanProjectService >> prettyPrintInstVar: instVarName [
	"for display on the project info tab"

	^instVarName ifNil: [String new] ifNotNil: [:iv | self printPrintInstVars at: iv]
]

{ #category : 'accessing' }
RowanProjectService >> printPrintInstVars [
	| pretty |
	pretty := Dictionary new.
	pretty
		at: 'rowanProjectsHome' put: 'Rowan Projects Home';
		at: 'name' put: 'Name';
		at: 'sha' put: 'Sha';
		at: 'diskSha' put: 'Disk Sha';
		at: 'branch' put: 'Branch';
		at: 'isSkew' put: 'Skew';
		at: 'isDirty' put: 'Dirty State';
		at: 'projectUrl' put: 'URL';
		at: 'packageConvention' put: 'Package Convention';
		yourself.
	^pretty
]

{ #category : 'public' }
RowanProjectService >> projectPackagesUpdate: presenter browser: browser [
	wasUpdated ifFalse: [^self].
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser projectListPresenter
]

{ #category : 'public' }
RowanProjectService >> projectSelectionUpdate: presenter [
	| newSelections |
	newSelections := presenter list select: [:service | self name = service name].
	presenter selections: newSelections
]

{ #category : 'accessing' }
RowanProjectService >> projectUrl [
	^projectUrl
]

{ #category : 'public' }
RowanProjectService >> projectsUpdate: presenter [
	| listProject |
	wasUpdated ifFalse: [^self].
	listProject := presenter list detect: [:listProj | listProj name = name] ifNone: [^self].
	listProject replicateFrom: self.
	presenter view invalidate
]

{ #category : 'must not strip' }
RowanProjectService >> remoteServiceName [
	^'Rowan projectServiceClass'
]

{ #category : 'public' }
RowanProjectService >> removedProject: presenter [
	| removedProject |
	updateType == #removedProject: ifFalse:[^self].
	removedProject := presenter list detect: [:projectService | projectService name = name] ifNone: [].
	removedProject ifNotNil: [presenter model remove: removedProject]
]

{ #category : 'public' }
RowanProjectService >> replicateFrom: newService [
	^self isProjectService ifTrue: [name isNil ifFalse: [super replicateFrom: newService]]
]

{ #category : 'Init / Release' }
RowanProjectService >> rowanPostUpdate [
	super rowanPostUpdate.
	packages ifNotNil: [packages do: [:service | service rowanPostUpdate]].
	componentServices := Dictionary new. 
]

{ #category : 'accessing' }
RowanProjectService >> rowanProjectsHome [
	^rowanProjectsHome
]

{ #category : 'accessing' }
RowanProjectService >> sha [
	^sha
]

{ #category : 'accessing' }
RowanProjectService >> sha: anObject [
	sha := anObject
]

{ #category : 'accessing' }
RowanProjectService >> sortAspect [

	^name
]

{ #category : 'accessing' }
RowanProjectService >> specService [
	^specService
]

{ #category : 'accessing' }
RowanProjectService >> specService: anObject [
	specService := anObject
]

{ #category : 'accessing' }
RowanProjectService >> toolTip [
	| writeStream crNeeded |
	writeStream := WriteStream on: String new.
	crNeeded := false.
	(isDiskDirty not and: 
			[isDirty not and: 
					[isSkew not
						and: [(existsOnDisk == false) not]]])
		ifTrue: 
			[writeStream nextPutAll: 'Disk/image consistent'.
			crNeeded := true].
	isDiskDirty
		ifTrue: 
			[writeStream nextPutAll: 'Dirty on disk '.
			crNeeded := true].
	isDirty
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Dirty in image '.
			crNeeded := true].
	isSkew
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Skew in sha '.
			crNeeded := true].
	(existsOnDisk == false or: [self displayName = RowanService notRowanizedPackageName])
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Does not exist on disk'.
			crNeeded := true].
	^writeStream contents
]
