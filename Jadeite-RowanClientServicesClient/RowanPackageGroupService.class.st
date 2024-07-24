Class {
	#name : 'RowanPackageGroupService',
	#superclass : 'RowanComponentDefinitionService',
	#instVars : [
		'condition',
		'packageServices',
		'projectName'
	],
	#category : 'Jadeite-RowanClientServicesClient',
	#package : 'Jadeite-RowanClientServicesClient'
}

{ #category : 'instance creation' }
RowanPackageGroupService class >> allPackageGroupForProjectDefinition: projectDef [ 
	"special package group for displaying all packages in the project" 
	^self new allPackageGroupForProjectDefinition: projectDef 
]

{ #category : 'instance creation' }
RowanPackageGroupService >> allPackageGroupForProjectDefinition: projectDef [
	command := #computePackageNames.
	commandArgs := Array new.
	self issueCommand: self session: session
]

{ #category : 'public' }
RowanPackageGroupService >> componentPackagesUpdate: presenter browser: browser [
	wasUpdated ifFalse:[^self].
	packageServices isEmpty ifTrue:[^self]. 
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser packageGroupPresenter
]

{ #category : 'accessing' }
RowanPackageGroupService >> condition [
	^condition
]

{ #category : 'accessing' }
RowanPackageGroupService >> condition: anObject [
	condition := anObject
]

{ #category : 'public' }
RowanPackageGroupService >> indexOfProjectDefinitionService [
	^14
]

{ #category : 'accessing' }
RowanPackageGroupService >> packageServices [
	^packageServices
]

{ #category : 'accessing' }
RowanPackageGroupService >> projectName: anObject [
	projectName := anObject
]

{ #category : 'commands' }
RowanPackageGroupService >> renamePackageGroupTo: newPackageGroupName [
	projectDefinitionService renamePackageGroup: name to: newPackageGroupName.
	name := newPackageGroupName
]

{ #category : 'commands' }
RowanPackageGroupService >> setCondition: newCondition [
	condition := newCondition. 
	projectDefinitionService addPackageGroupNamed: name condition: newCondition.
]

{ #category : 'public' }
RowanPackageGroupService >> shouldReplicateInstVarAtIndex: index newService: newService [
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfProjectDefinitionService = index ifTrue: [^false].
	^true
]
