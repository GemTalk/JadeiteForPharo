Class {
	#name : 'RowanProjectDefinitionService',
	#superclass : 'RowanDefinitionService',
	#instVars : [
		'definitionOop',
		'componentDefinitions',
		'packageDefinitions',
		'specService',
		'comment',
		'conditionalAttributes',
		'platformProperties',
		'packageGroups',
		'showLoadedPackageGroupsOnly',
		'allPackagesGroupService',
		'definition'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'accessing' }
RowanProjectDefinitionService class >> templateClassName [

	^#RowanProjectDefinitionService
]

{ #category : 'commands' }
RowanProjectDefinitionService >> addComponentNamed: componentName [
	command := #addComponent:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> addPackageGroupNamed: packageGroupName condition: newCondition [
	command := #addPackageGroupNamed:condition:comment:.
	commandArgs := Array
				with: packageGroupName
				with: newCondition
				with: comment.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> addPackageNamed: packageName toComponentNamed: componentName [
	command := #addPackageNamed:toComponentNamed:.
	commandArgs := Array with: packageName with: componentName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> addPackagesNamed: packageNames toPackageGroup: packageGroupName [
	command := #addPackagesNamed:toPackageGroupNamed:.
	commandArgs := Array with: packageNames with: packageGroupName.
	self issueCommand: self session: session.
]

{ #category : 'commands' }
RowanProjectDefinitionService >> addSubcomponentNamed: subcomponentName toComponentNamed: componentName [
	command := #addSubcomponentNamed:toComponentNamed:.
	commandArgs := Array with: subcomponentName with: componentName.
	self issueCommand: self session: session
]

{ #category : 'constants' }
RowanProjectDefinitionService >> allPackagesGroupName [
	^'All Packages'
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> allPackagesGroupService [
	"special package group to display all packages"

	^allPackagesGroupService
		ifNil: 
			[allPackagesGroupService := RowanPackageGroupService new
						name: self allPackagesGroupName;
						condition: String new;
						projectDefinitionService: self]
]

{ #category : 'public' }
RowanProjectDefinitionService >> basicPrepareForReplication [
	componentDefinitions := nil. 
	packageDefinitions :=nil.
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> comment [
	^comment
]

{ #category : 'commands' }
RowanProjectDefinitionService >> comment: proejctComment [
	command := #comment:.
	commandArgs := Array with: proejctComment.
	self issueCommand: self session: session
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> componentDefinitions [
	^componentDefinitions
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> componentDefinitions: anObject [
	componentDefinitions := anObject
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> conditionalAttributes [
	^conditionalAttributes
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> conditionalAttributes: anObject [
	conditionalAttributes := anObject
]

{ #category : 'public' }
RowanProjectDefinitionService >> excludedInstVars [
	"I'm not sure this is the right thing but since packageGroups does not need to be used on the server, we'll try it"

	^super excludedInstVars , #('packageGroups' 'allPackagesGroupService' 'definition')
]

{ #category : 'commands' }
RowanProjectDefinitionService >> export [
	command := #export.
	commandArgs := Array new.
	self issueCommand: self session: session
]

{ #category : 'initialization' }
RowanProjectDefinitionService >> initialize [
	super initialize.
	showLoadedPackageGroupsOnly := true
]

{ #category : 'commands' }
RowanProjectDefinitionService >> movePackageNamed: packageName toComponentNamed: componentName [
	command := #movePackageNamed:toComponentNamed:.
	commandArgs := Array with: packageName with: componentName.
	self issueCommand: self session: session
]

{ #category : 'public' }
RowanProjectDefinitionService >> packageGroupUpdate: presenter browser: browser [
	| treeModel allService |
	wasUpdated ifFalse: [^self].
	browser selectedProjectName = name ifFalse: [^self].
	treeModel := self chooseModel: presenter using: browser.
	session := browser gciSession.
	allService := self allPackagesGroupService.
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
RowanProjectDefinitionService >> packageGroups [
	^packageGroups
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> packageGroups: anObject [
	packageGroups := anObject
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> platformProperties [
	^platformProperties
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> platformProperties: anObject [
	platformProperties := anObject
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removeComponentNamed: componentName [
	command := #removeComponentNamed:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removeCondition: condition inSubcomponentNamed: subcomponentName [
	command := #removeCondition:inSubcomponentNamed:.
	commandArgs := Array with: condition with: subcomponentName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removePackageGroups: packageGroupServices [
	command := #removePackageGroupsNamed:.
	commandArgs := Array
				with: (packageGroupServices collect: [:packageGroupService | packageGroupService name]).
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removePackageGroupsNamed: packageGroupNames [
	command := #removePackageGroupsNamed:.
	commandArgs := Array with: packageGroupNames.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removePackagesFromProjectDefinition: packageNames [
	"package groups and component names are treated similarly in some cases, hence the oddly named command"

	command := #removePackagesFromProjectDefinition:.
	commandArgs := Array with: packageNames.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> removePackagesNamed: packageNames fromPackageGroupNamed: packageGroupName [
	"package groups and component names are treated similarly in some cases, hence the oddly named command"

	command := #removePackagesNamed:fromPackageGroupNamed:.
	commandArgs := Array with: packageNames with: packageGroupName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> renameComponentNamed: componentPath to: newName [
	command := #renameComponent:to:.
	commandArgs := Array with: componentPath with: newName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> renamePackage: packageName to: newPackageName [
	command := #renamePackageNamed:to:.
	commandArgs := Array with: packageName with: newPackageName.
	self issueCommand: self session: session
]

{ #category : 'commands' }
RowanProjectDefinitionService >> renamePackageGroup: packageGroupName to: newPackageGroupName [
	command := #renamePackageGroup:to:.
	commandArgs := Array with: packageGroupName with: newPackageGroupName.
	self issueCommand: self session: session
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> showLoadedPackageGroupsOnly [
	^showLoadedPackageGroupsOnly
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> showLoadedPackageGroupsOnly: anObject [
	showLoadedPackageGroupsOnly := anObject
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> specService [
	^specService
]

{ #category : 'accessing' }
RowanProjectDefinitionService >> specService: anObject [
	specService := anObject
]

{ #category : 'commands' }
RowanProjectDefinitionService >> subcomponentNamed: subcomponentName condition: condition [
	command := #subcomponentNamed:condition:.
	commandArgs := Array with: subcomponentName with: condition.
	self issueCommand: self session: session
]
